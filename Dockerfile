# Stage 1: Build the Go app
FROM golang:1.23-alpine AS builder

# Install git
RUN apk add --no-cache git

# Set working directory
WORKDIR /app
RUN mkdir /app/bin

# Clone the repo
RUN git clone https://github.com/musixal/backhaul.git &&\
    cd backhaul &&\
    go build -o /app/bin/backhaul
RUN git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird.git &&\
    cd lyrebird &&\
    CGO_ENABLED=0 go build -ldflags="-X main.lyrebirdVersion=0.6.1" ./cmd/lyrebird &&\
    mv lyrebird /app/bin/lyrebird

# Stage 2: Run the app
FROM alpine:latest

# Set working directory
WORKDIR /app

# Copy the built binary from builder stage
COPY --from=builder /app/bin/* .

# Add /app to PATH
ENV PATH="/app:${PATH}"

# Expose port (update to match the app's port if needed)
EXPOSE 8080

ENTRYPOINT []

