# Gunakan multi-stage build untuk menghasilkan binary kecil
FROM golang:1.24-alpine AS builder

# Set working directory dalam container
WORKDIR /app

# Copy file go.mod dan go.sum terlebih dahulu
COPY go.mod go.sum ./

# Download dependencies terlebih dahulu
RUN go mod download

# Copy seluruh source code
COPY . .

# Build aplikasi Go tanpa dependency system (CGO disabled)
RUN CGO_ENABLED=0 go build -o main .

# Stage kedua: gunakan image yang lebih kecil untuk menjalankan aplikasi
FROM alpine:latest

# Set working directory
WORKDIR /app

# Copy hasil build dari stage sebelumnya
COPY --from=builder /app/main .

# Ekspos port sesuai aplikasi Fiber
EXPOSE 3000

# Jalankan aplikasi
CMD ["/app/main"]