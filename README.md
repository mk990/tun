# Tun - Multi-arch Tunneling Tools

A Docker image containing a collection of tunneling and anti-censorship tools, built for both amd64 and arm64 architectures.

## Included Tools

- **backhaul**: A high-performance multiplexed relay tool.
- **lyrebird**: A pluggable transport that provides a bridge between different network protocols.
- **usque**: A fast and lightweight tunneling tool.
- **dnstt-server**: DNS tunnel server.
- **dnstt-client**: DNS tunnel client.
- **WaterWall**: A tool for bypassing network restrictions.
- **slipstream-server**: High-performance TCP/UDP over UDP/Websocket server.
- **slipstream-client**: High-performance TCP/UDP over UDP/Websocket client.
- **rstun**: A simple STUN client and server implementation.
- **psiphon**: A console client for the Psiphon circumvention system.

## How to Build

To build the Docker image for multiple platforms using `docker buildx`:

```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t your-tag --push .
```

## How to Run

To run the container and access the tools:

```bash
docker run -it --rm your-tag sh
```

All tools are located in `/app` and added to the `PATH`.
