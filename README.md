# tun

A multi-stage Docker image that compiles and bundles a collection of tunneling and anti-censorship tools into a single Alpine-based image.

## Included Tools

| Tool | Source | Description |
|------|--------|-------------|
| [backhaul](https://github.com/musixal/backhaul) | Go | Reverse tunneling tool for bypassing NAT/firewall |
| [lyrebird](https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird) | Go | Tor pluggable transport (obfs4 and others) |
| [usque](https://github.com/Diniboy1123/usque) | Go | Cloudflare WARP tunnel client |
| [vaydns-server / vaydns-client](https://github.com/net2share/vaydns) | Go | DNS-based VPN |
| [dnstt-server / dnstt-client](https://repo.or.cz/dnstt.git) | Go | DNS tunnel over TLS |
| [sni-spoof](https://github.com/selfishblackberry177/sni-spoof) | Go | SNI spoofing proxy |
| [masterdnsvpn-server / masterdnsvpn-client](https://github.com/masterking32/MasterDnsVPN) | Go | DNS VPN server and client |
| [Waterwall](https://github.com/radkesvat/WaterWall) | C/C++ (CMake) | Advanced tunneling framework |
| [slipstream-server / slipstream-client](https://github.com/Mygod/slipstream-rust) | Rust | TCP slipstreaming tool |
| [rstun](https://github.com/neevek/rstun) | Rust | QUIC-based reverse tunnel |
| [psiphon-tunnel-core](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries) | Binary | Psiphon censorship circumvention client |

All binaries are available on `PATH` inside the container (`/app`).

## Build

```bash
docker build -t tun .
```

> The build uses three separate builder stages (Go, CMake/C++, Rust) before assembling the final Alpine image, so it may take a while on first run.

## Usage

Run an interactive shell to access any of the included tools:

```bash
docker run --rm -it tun sh
```

Run a specific tool directly:

```bash
docker run --rm tun backhaul --help
docker run --rm tun lyrebird --help
docker run --rm tun rstun --help
```

## Image Structure

```
go-builder    (golang:1.26-alpine)   → backhaul, lyrebird, usque, vaydns-*, dnstt-*, sni-spoof, masterdnsvpn-*
cmake-builder (debian:trixie-slim)   → Waterwall
rust-builder  (rust:1.88-alpine)     → slipstream-*, rstun
final         (alpine:latest)        → all binaries + psiphon-tunnel-core-x86_64
```

All binaries are statically linked where possible for maximum portability.

## Port

The image exposes port `8080` by default. Override as needed when running a specific tool:

```bash
docker run --rm -p 1080:1080 tun <tool> <args>
```
