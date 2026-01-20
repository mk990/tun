# Stage 1: Build the Go app
FROM golang:1.24-alpine AS builder

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

# Stage 2: Build WaterWall
FROM ubuntu:24.04 AS waterwall-builder

RUN apt-get update && \
    apt-get install -y git cmake ninja-build build-essential

WORKDIR /waterwall
RUN git clone https://github.com/radkesvat/WaterWall.git && \
    cd WaterWall && \
    cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXE_LINKER_FLAGS="-static" \
    -DCMAKE_C_FLAGS="-static" \
    -DCMAKE_CXX_FLAGS="-static" && \
    cmake --build build

# Stage 3: Build rstun
FROM rust:1.88-slim AS rstun-builder

RUN apt-get update && \
    apt-get install -y git musl-tools && \
    rustup target add x86_64-unknown-linux-musl

RUN git clone https://github.com/Mygod/slipstream-rust.git slipstream-rust && \
    cd slipstream-rust && \
    git submodule update --init --recursive && \
    cargo build -p slipstream-client -p slipstream-server --target x86_64-unknown-linux-musl --all-features --release && \
    mkdir -p slipstream-rust-linux-x86_64

WORKDIR /rstun
RUN git clone https://github.com/neevek/rstun.git && \
    cd rustun && \
    cargo build --target x86_64-unknown-linux-musl --all-features --release && \
    mkdir -p rstun-linux-x86_64 && \
    mv target/x86_64-unknown-linux-musl/release/rstunc ./rstun-linux-x86_64/ && \
    mv target/x86_64-unknown-linux-musl/release/rstund ./rstun-linux-x86_64/



# Stage 4: Run the app
FROM alpine:latest

# Set working directory
WORKDIR /app

# Copy the built binary from builder stage
COPY --from=builder /app/bin/* .
COPY --from=waterwall-builder /waterwall/WaterWall/build/Waterwall .
COPY --from=rstun-builder /rstun/rstun/rstun-linux-x86_64/* .


# Add /app to PATH
ENV PATH="/app:${PATH}"

# Expose port (update to match the app's port if needed)
EXPOSE 8080

ENTRYPOINT []

