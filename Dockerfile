# Build the Go app
FROM golang:1.24-alpine AS go-builder

# Install git
RUN apk add --no-cache git

# Set working directory
WORKDIR /app
RUN mkdir /app/bin

# Clone the repo
RUN git clone https://github.com/musixal/backhaul.git && \
    cd backhaul && \
    go build -o /app/bin/backhaul

RUN git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird.git && \
    cd lyrebird && \
    CGO_ENABLED=0 go build -ldflags="-X main.lyrebirdVersion=0.6.1" ./cmd/lyrebird && \
    mv lyrebird /app/bin/lyrebird

RUN git clone https://github.com/Diniboy1123/usque.git && \
    cd usque && \
    go build -o usque -ldflags="-s -w" . && \
    mv usque /app/bin/usque

RUN git clone https://repo.or.cz/dnstt.git && \
    cd dnstt/dnstt-server && \
    go build && \
    mv dnstt-server /app/bin/dnstt-server && \
    cd ../dnstt-client && \
    go build && \
    mv dnstt-client /app/bin/dnstt-client

# Build cmake
FROM ubuntu:24.04 AS cmake-builder

RUN apt-get update && \
    apt-get install -y git curl cmake ninja-build build-essential libssl-dev zlib1g-dev

WORKDIR /app
RUN mkdir /app/bin

RUN git clone https://github.com/radkesvat/WaterWall.git && \
    cd WaterWall && \
    cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXE_LINKER_FLAGS="-static" \
    -DCMAKE_C_FLAGS="-static" \
    -DCMAKE_CXX_FLAGS="-static" && \
    cmake --build build && \
    mv build/Waterwall /app/bin


RUN git clone https://github.com/TelegramMessenger/MTProxy && \
    cd MTProxy && \
    make && \
    mv objs/bin/mtproto-proxy /app/bin

FROM rust:1.88-alpine AS rust-builder

# Install dependencies
RUN apk add --no-cache bash git musl-dev openssl-dev pkgconf cmake build-base

WORKDIR /app
RUN mkdir /app/bin

# Enable static OpenSSL linking
ENV OPENSSL_STATIC=1
ENV OPENSSL_DIR=/usr

# Build slipstream
RUN git clone https://github.com/Mygod/slipstream-rust.git && \
    cd slipstream-rust && \
    git submodule update --init --recursive && \
    cargo build --release --target x86_64-unknown-linux-musl -p slipstream-client -p slipstream-server && \
    mv target/x86_64-unknown-linux-musl/release/slipstream-server /app/bin && \
    mv target/x86_64-unknown-linux-musl/release/slipstream-client /app/bin && \
    cd .. && rm -rf slipstream-rust

# Build rstun
RUN git clone https://github.com/neevek/rstun.git && \
    cd rstun && \
    cargo build --target x86_64-unknown-linux-musl --all-features --release && \
    mv target/x86_64-unknown-linux-musl/release/rstunc /app/bin && \
    mv target/x86_64-unknown-linux-musl/release/rstund /app/bin && \
    cd .. && rm -rf rstun

# Run the app
FROM alpine:latest

RUN apk add --no-cache ca-certificates
# Set working directory
WORKDIR /app

# Copy the built binary from builder stage
COPY --from=go-builder /app/bin/* .
COPY --from=cmake-builder /app/bin/* .
COPY --from=rust-builder /app/bin/* .

# Add /app to PATH
ENV PATH="/app:${PATH}"

# Expose port (update to match the app's port if needed)
EXPOSE 8080

ENTRYPOINT []

