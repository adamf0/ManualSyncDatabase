# Gunakan Go dengan Alpine sebagai base image
FROM golang:1.20-alpine

# Install dependencies yang diperlukan
RUN apk add --no-cache git gcc g++ make

# Set working directory dalam container
WORKDIR /app

# Copy file go.mod dan go.sum terlebih dahulu untuk caching dependencies
COPY go.mod go.sum ./

# Download dan cache dependencies sebelum copy source code (agar lebih efisien)
RUN go mod download

# Copy seluruh project ke dalam container
COPY . .

# Build aplikasi
RUN go build -o main .

# Jalankan aplikasi
CMD ["/app/main"]
