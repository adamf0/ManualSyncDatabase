package main

import (
	"database/sql"
	"fmt"
	"log"
	"runtime"
	"strings"
	"sync"
	"os"

	"github.com/gofiber/fiber/v2"
	_ "github.com/go-sql-driver/mysql"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var dbSource *sql.DB
var dbSinkron *gorm.DB

func init() {
	var err error

	// Load environment variables
	dbSourceDSN := os.Getenv("ConnectionString__SOURCE")
	dbSinkronDSN := os.Getenv("ConnectionString__TARGET")
	// dbSourceDSN := "root:@tcp(localhost:3306)/sync_db?charset=utf8mb4&parseTime=True&loc=Local"
	// dbSinkronDSN := "root:251423@tcp(host.docker.internal:3307)/sync_simak?charset=utf8mb4&parseTime=True&loc=Local"

	// Koneksi ke database source
	dbSource, err = sql.Open("mysql", dbSourceDSN)
	if err != nil {
		log.Fatal(err)
	}

	// Koneksi ke database sinkron (target)
	dbSinkron, err = gorm.Open(mysql.Open(dbSinkronDSN), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}
}

func convertColumnType(colType string) string {
	colTypeLower := strings.ToLower(colType)
	switch {
	case strings.Contains(colTypeLower, "enum"),
		strings.Contains(colTypeLower, "date"),
		strings.Contains(colTypeLower, "timestamp"),
		strings.Contains(colTypeLower, "time"),
		strings.Contains(colTypeLower, "datetime"),
		strings.Contains(colTypeLower, "char"),
		strings.Contains(colTypeLower, "int"):
		return "VARCHAR(255)"
	case strings.Contains(colTypeLower, "json"):
		return "TEXT"
	default:
		return colType
	}
}

// Handler untuk sinkronisasi tabel
func syncTable(c *fiber.Ctx) error {
	tbName := c.Params("tb_name")

	// Ambil struktur tabel dari source
	columns, primaryKey, err := getTableStructure(tbName)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	// Sesuaikan struktur tabel di database sinkron tanpa DROP TABLE
	err = adjustTableStructure(tbName, columns, primaryKey)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	// Sinkronisasi data dengan concurrency
	err = syncTableData(tbName, columns, primaryKey)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"message": "Sync berhasil"})
}

// Fungsi untuk mendapatkan struktur tabel
func getTableStructure(table string) (map[string]string, string, error) {
	query := fmt.Sprintf("DESCRIBE %s", table)
	rows, err := dbSource.Query(query)
	if err != nil {
		return nil, "", err
	}
	defer rows.Close()

	columns := make(map[string]string)
	var primaryKey string
	var field, colType, null, key, extra string
	var defaultVal sql.NullString

	for rows.Next() {
		if err := rows.Scan(&field, &colType, &null, &key, &defaultVal, &extra); err != nil {
			return nil, "", err
		}
		columns[field] = convertColumnType(colType)

		// Simpan Primary Key jika ada
		if key == "PRI" {
			primaryKey = field
		}
	}

	return columns, primaryKey, nil
}

// Fungsi untuk menyesuaikan struktur tabel tanpa DROP TABLE
func adjustTableStructure(table string, columns map[string]string, primaryKey string) error {
	existingColumns, err := getTableStructureFromSinkron(table)
	if err != nil {
		return err
	}

	alterQueries := []string{}

	// Tambahkan kolom yang belum ada
	for colName, colType := range columns {
		if _, exists := existingColumns[colName]; !exists {
			alterQueries = append(alterQueries, fmt.Sprintf("ADD COLUMN %s %s", colName, colType))
		} else if existingColumns[colName] != colType { // Modifikasi tipe kolom jika berbeda
			alterQueries = append(alterQueries, fmt.Sprintf("MODIFY COLUMN %s %s", colName, colType))
		}
	}

	// Hapus kolom yang tidak ada di sumber
	for colName := range existingColumns {
		if _, exists := columns[colName]; !exists {
			alterQueries = append(alterQueries, fmt.Sprintf("DROP COLUMN %s", colName))
		}
	}

	if len(alterQueries) > 0 {
		alterQuery := fmt.Sprintf("ALTER TABLE %s %s", table, strings.Join(alterQueries, ", "))
		log.Println(alterQuery)

		if err := dbSinkron.Exec(alterQuery).Error; err != nil {
			return err
		}
	}

	return nil
}

// Fungsi untuk mendapatkan struktur tabel di database sinkron
func getTableStructureFromSinkron(table string) (map[string]string, error) {
	query := fmt.Sprintf("DESCRIBE %s", table)
	rows, err := dbSinkron.Raw(query).Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	columns := make(map[string]string)
	var field, colType, null, key, extra string
	var defaultVal sql.NullString

	for rows.Next() {
		if err := rows.Scan(&field, &colType, &null, &key, &defaultVal, &extra); err != nil {
			return nil, err
		}
		columns[field] = colType
	}

	return columns, nil
}

// Fungsi untuk sinkronisasi data dengan concurrency
func syncTableData(table string, columns map[string]string, primaryKey string) error {
	columnNames := make([]string, 0, len(columns))
	for col := range columns {
		columnNames = append(columnNames, col)
	}
	columnList := strings.Join(columnNames, ", ")

	query := fmt.Sprintf("SELECT %s FROM %s", columnList, table)
	rows, err := dbSource.Query(query)
	if err != nil {
		return err
	}
	defer rows.Close()

	values := make([]interface{}, len(columnNames))
	scanArgs := make([]interface{}, len(columnNames))
	for i := range values {
		scanArgs[i] = new([]byte) // Menghindari type mismatch saat Scan
	}

	var wg sync.WaitGroup
	maxGoroutines := runtime.NumCPU() * 2
	sem := make(chan struct{}, maxGoroutines)

	for rows.Next() {
		if err := rows.Scan(scanArgs...); err != nil {
			return err
		}

		for i := range values {
			values[i] = string(*(scanArgs[i].(*[]byte)))
		}

		wg.Add(1)
		sem <- struct{}{}

		go func(values []interface{}) {
			defer wg.Done()
			defer func() { <-sem }()

			tx := dbSinkron.Begin()
			defer tx.Rollback()

			var count int
			checkQuery := fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE %s = ?", table, primaryKey)
			log.Println(checkQuery)
			log.Println(values[0])

			if err := tx.Raw(checkQuery, values[0]).Scan(&count).Error; err != nil {
				log.Println(err)
				return
			}

			log.Println(count)
			if count == 0 {
				insertQuery := fmt.Sprintf("INSERT INTO %s (%s) VALUES (%s)", table, columnList, strings.Repeat("?, ", len(columnNames)-1)+"?")
				log.Println(insertQuery)
				log.Println(values)

				if err := tx.Exec(insertQuery, values...).Error; err != nil {
					log.Println(err)
					return
				}
			} else {
				updateFields := []string{}
				for col := range columns {
					if col != primaryKey {
						updateFields = append(updateFields, fmt.Sprintf("%s = ?", col))
					}
				}
				updateQuery := fmt.Sprintf("UPDATE %s SET %s WHERE %s = ?", table, strings.Join(updateFields, ", "), primaryKey)
				valuesToUpdate := append(values[1:], values[0]) // Primary key harus ada di akhir
				log.Println(updateQuery)
				log.Println(valuesToUpdate)

				if err := tx.Exec(updateQuery, valuesToUpdate...).Error; err != nil {
					log.Println(err)
					return
				}
			}

			tx.Commit()
		}(append([]interface{}{}, values...))
	}

	wg.Wait()
	
	return nil
}

func hello(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"message": "hello world"})
}

func main() {
	app := fiber.New()
	app.Get("/", hello)
	app.Get("/sync/:tb_name", syncTable)
	log.Fatal(app.Listen(":3000"))
}
