package main

import (
	"database/sql"
	"fmt"
	"log"
	"runtime"
	"strings"
	"sync"

	"github.com/gofiber/fiber/v2"
	_ "github.com/go-sql-driver/mysql"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var dbSimak *sql.DB
var dbSinkron *gorm.DB

func init() {
	var err error

	// Load environment variables
	dbSimakDSN := os.Getenv("ConnectionString__SIMAK")
	dbSinkronDSN := os.Getenv("ConnectionString__SOURCE")

	// Koneksi ke database simak (source)
	dbSimak, err = sql.Open("mysql", dbSimakDSN)
	if err != nil {
		log.Fatal(err)
	}

	// Koneksi ke database sinkron (target)
	dbSinkron, err = gorm.Open(mysql.Open(dbSinkronDSN), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}
}

// Handler untuk sinkronisasi tabel
func syncTable(c *fiber.Ctx) error {
	tbName := c.Params("tb_name")

	// Ambil struktur tabel dari simak
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
	rows, err := dbSimak.Query(query)
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
		columns[field] = colType

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
	rows, err := dbSimak.Query(query)
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
			if err := tx.Raw(checkQuery, values[0]).Scan(&count).Error; err != nil {
				log.Println(err)
				return
			}

			if count == 0 {
				insertQuery := fmt.Sprintf("INSERT INTO %s (%s) VALUES (%s)", table, columnList, strings.Repeat("?, ", len(columnNames)-1)+"?")
				if err := tx.Exec(insertQuery, values...).Error; err != nil {
					log.Println(err)
					return
				}
			} else {
				updateQuery := fmt.Sprintf("UPDATE %s SET %s WHERE %s = ?", table, columnList, primaryKey)
				if err := tx.Exec(updateQuery, values...).Error; err != nil {
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

func main() {
	app := fiber.New()
	app.Get("/sync/:tb_name", syncTable)
	log.Fatal(app.Listen(":3000"))
}
