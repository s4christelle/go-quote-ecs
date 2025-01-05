# Step 1: Build stage
FROM golang:1.23 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the application source code into the container
COPY . .

# Build the Go application for Linux with static linking
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o main .

# Step 2: Runtime stage
FROM scratch

# Copy the statically built binary from the builder stage
COPY --from=builder /app/main .

# Expose the port the application will run on
EXPOSE 8080

# Run the application
CMD ["./main"]