#!/bin/bash

# Daftar tabel yang ingin disinkronisasi (pisahkan dengan spasi jika ada lebih dari satu tabel)
TABLES=("e_jafung")  # Tambahkan lebih banyak tabel jika diperlukan

# Loop melalui setiap tabel dan jalankan curl
for table in "${TABLES[@]}"; do
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:82/sync/$table")

    # Log hasil request
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    if [[ "$RESPONSE" -eq 200 ]]; then
        echo "$TIMESTAMP - Sync berhasil untuk tabel: $table" | tee -a /var/log/sync.log
    else
        echo "$TIMESTAMP - Gagal sync tabel: $table (HTTP $RESPONSE)" | tee -a /var/log/sync_error.log
    fi
done
