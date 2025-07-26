# Use an official Golang image to build the binary
FROM golang:1.22-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build a static binary to ensure it runs on a minimal base image
RUN CGO_ENABLED=0 go build -o /server .

# Use a minimal, non-root "distroless" base image for security and size
FROM gcr.io/distroless/static-debian11

# Copy the static assets and the compiled server from the builder stage
COPY --from=builder /server /
COPY --from=builder /app/static /static
COPY --from=builder /app/test_data_dir /test_data_dir

# Expose the port the server will run on. Cloud Run uses this PORT env var.
ENV PORT 8080

# Command to run the executable
CMD ["/server"]