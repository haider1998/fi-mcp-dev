# Use the official Golang image to build the application
FROM golang:1.22-alpine as builder

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum to download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go application
# CGO_ENABLED=0 is important for creating a static binary
# -o /server builds the executable to the /server path
RUN CGO_ENABLED=0 go build -o /server .

# Use a minimal, non-root base image for the final container
FROM gcr.io/distroless/static-debian11

# Copy the static assets and the compiled server from the builder stage
COPY --from=builder /server /
COPY --from=builder /app/static /static
COPY --from=builder /app/test_data_dir /test_data_dir

# Set the port the server will run on
ENV PORT 8080

# Command to run the executable
CMD ["/server"]