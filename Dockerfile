# Multi-stage build for Terraform with migration tools
FROM golang:1.24-alpine AS migration-builder

# Install build dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /build

# Copy migration source
COPY migrations/ ./migrations/

# Build migration tool
WORKDIR /build/migrations
RUN go mod download && \
    go build -o migrate .

# Final stage
FROM hashicorp/terraform:latest

# Install additional tools
RUN apk add --no-cache \
    bash \
    git \
    make \
    aws-cli \
    ca-certificates

# Install Go for running migrations
COPY --from=golang:1.24-alpine /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Copy migration tool
COPY --from=migration-builder /build/migrations/migrate /usr/local/bin/migrate

# Copy project files
COPY . .

# Make scripts executable
RUN chmod +x migrate.sh set-user-password.sh 2>/dev/null || true

# Set default command
ENTRYPOINT ["/bin/bash"]
