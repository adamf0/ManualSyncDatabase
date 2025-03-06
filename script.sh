#!/bin/bash

# Daftar tabel yang ingin disinkronisasi
TABLES=("table1" "table2" "table3")  # Ganti dengan nama tabel yang sesuai

# Loop melalui setiap tabel dan jalankan curl
for table in "${TABLES[@]}"; do
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:81/sync/$table")

    # Log hasil request
    if [[ "$RESPONSE" -eq 200 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Sync berhasil untuk tabel: $table" >> /var/log/sync.log
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Gagal sync tabel: $table (HTTP $RESPONSE)" >> /var/log/sync_error.log
    fi
done
