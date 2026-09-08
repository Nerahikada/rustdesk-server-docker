# rustdesk-server-docker
Docker Compose configuration for RustDesk Server OSS with WebSocket support

## Usage

```bash
git clone https://github.com/Nerahikada/rustdesk-server-docker.git rustdesk-server
cd rustdesk-server/

# Set your domain and email
cp .env.example .env
$EDITOR .env

docker compose up -d
```

## Firewall

All services use host networking, so `hbbs` and `hbbr` bind on every interface. These are the ports they open:

| Port | Protocol | Service | Reachable from |
| --- | --- | --- | --- |
| 80 | TCP | nginx | internet (ACME http-01 only) |
| 443 | TCP | nginx | internet (WebSocket over TLS) |
| 21115 | TCP | hbbs | internet (NAT type test) |
| 21116 | TCP + UDP | hbbs | internet (ID registration, rendezvous, hole punching) |
| 21117 | TCP | hbbr | internet (relay) |
| 21118 | TCP | hbbs | **nginx only — block externally** |
| 21119 | TCP | hbbr | **nginx only — block externally** |

**You must block 21118 and 21119 from the internet.** They are the plaintext WebSocket listeners that nginx proxies `/ws/id` and `/ws/relay` to, and RustDesk Server adopts the `X-Real-IP` / `X-Forwarded-For` headers on them verbatim. Anyone who can reach them directly can claim any source IP, which defeats blocklists and corrupts logged addresses, and can also skip TLS entirely. Upstream documents this in `relay_server.rs` and `rendezvous_server.rs`: *"Do not expose the WebSocket port directly to untrusted networks."*

`hbbs` and `hbbr` apply `-b` to every listener at once, so the WebSocket ports cannot be bound to loopback without also moving rendezvous and relay off the public interfaces. Use a firewall instead:

```bash
ufw allow 80,443/tcp
ufw allow 21115:21117/tcp
ufw allow 21116/udp
ufw deny 21118/tcp
ufw deny 21119/tcp
```

Host networking is what makes this work: Docker only installs the `DOCKER` iptables chain that bypasses ufw for *published* ports, and this stack publishes none. If you run behind a cloud firewall or security group, express the same rules there instead.

## Updating

Pull before bringing the stack back up:

```bash
docker compose pull
docker compose up -d
```

`docker compose up -d` on its own is not enough. Compose defaults to the `missing` pull policy, which re-pulls only the `latest` tag, so `nginx:stable` stays at whatever version you first pulled. Because the containers restart on their own, an nginx and OpenSSL with known vulnerabilities would otherwise keep terminating TLS indefinitely.
