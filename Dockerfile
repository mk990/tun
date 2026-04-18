# Build Go binaries
FROM golang:1.26-alpine AS go-builder

RUN apk add --no-cache git

WORKDIR /app
RUN mkdir /app/bin

RUN git clone https://github.com/musixal/backhaul.git && \
    cd backhaul && \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o /app/bin/backhaul && \
    cd .. && rm -rf backhaul

RUN git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird.git && \
    cd lyrebird && \
    CGO_ENABLED=0 go build -ldflags="-s -w -X main.lyrebirdVersion=0.6.1" ./cmd/lyrebird && \
    mv lyrebird /app/bin/lyrebird && \
    cd .. && rm -rf lyrebird

RUN git clone https://github.com/Diniboy1123/usque.git && \
    cd usque && \
    CGO_ENABLED=0 go build -o /app/bin/usque -ldflags="-s -w" . && \
    cd .. && rm -rf usque

RUN git clone https://github.com/net2share/vaydns.git && \
    cd vaydns/vaydns-server && \
    CGO_ENABLED=0 go build -ldflags="-s -w" && \
    mv vaydns-server /app/bin/vaydns-server && \
    cd ../vaydns-client && \
    CGO_ENABLED=0 go build -ldflags="-s -w" && \
    mv vaydns-client /app/bin/vaydns-client && \
    cd ../.. && rm -rf vaydns

RUN git clone https://repo.or.cz/dnstt.git && \
    cd dnstt/dnstt-server && \
    CGO_ENABLED=0 go build -ldflags="-s -w" && \
    mv dnstt-server /app/bin/dnstt-server && \
    cd ../dnstt-client && \
    CGO_ENABLED=0 go build -ldflags="-s -w" && \
    mv dnstt-client /app/bin/dnstt-client && \
    cd ../.. && rm -rf dnstt

RUN git clone https://github.com/selfishblackberry177/sni-spoof.git && \
    cd sni-spoof && \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o /app/bin/sni-spoof . && \
    cd .. && rm -rf sni-spoof

RUN git clone https://github.com/masterking32/MasterDnsVPN.git && \
    cd MasterDnsVPN && \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o /app/bin/masterdnsvpn-client ./cmd/client && \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o /app/bin/masterdnsvpn-server ./cmd/server && \
    cd .. && rm -rf MasterDnsVPN

# Build Rust binaries
FROM rust:1.88-alpine AS rust-builder

RUN apk add --no-cache bash git musl-dev openssl-dev openssl-libs-static pkgconf cmake build-base

WORKDIR /app
RUN mkdir /app/bin

ENV OPENSSL_STATIC=1
ENV OPENSSL_DIR=/usr

RUN git clone https://github.com/Mygod/slipstream-rust.git && \
    cd slipstream-rust && \
    git submodule update --init --recursive && \
    cargo build --release --target x86_64-unknown-linux-musl -p slipstream-client -p slipstream-server && \
    mv target/x86_64-unknown-linux-musl/release/slipstream-server /app/bin && \
    mv target/x86_64-unknown-linux-musl/release/slipstream-client /app/bin && \
    cd .. && rm -rf slipstream-rust

RUN git clone https://github.com/neevek/rstun.git && \
    cd rstun && \
    cargo build --target x86_64-unknown-linux-musl --all-features --release && \
    mv target/x86_64-unknown-linux-musl/release/rstun /app/bin && \
    cd .. && rm -rf rstun

# Download pre-built binaries
FROM alpine:3.21 AS downloader

RUN apk add --no-cache wget ca-certificates && \
    wget -O /psiphon-tunnel-core-x86_64 \
    https://raw.githubusercontent.com/Psiphon-Labs/psiphon-tunnel-core-binaries/refs/heads/master/linux/psiphon-tunnel-core-x86_64 && \
    chmod 755 /psiphon-tunnel-core-x86_64

# Final image
FROM alpine:3.21

RUN apk add --no-cache ca-certificates

WORKDIR /app

COPY --from=go-builder /app/bin/* .
COPY --from=rust-builder /app/bin/* .
COPY --from=downloader /psiphon-tunnel-core-x86_64 .

ENV PATH="/app:${PATH}"

EXPOSE 8080

ENTRYPOINT []
