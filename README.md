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

`hbbs`, `hbbr` and both nginx services use host networking, so they bind on every interface.

| Port | Protocol | Service | Internet | Purpose |
| --- | --- | --- | --- | --- |
| 80 | TCP | nginx | yes | ACME http-01 |
| 443 | TCP | nginx | yes | WebSocket over TLS |
| 21115 | TCP | hbbs | yes | NAT type test |
| 21116 | TCP + UDP | hbbs | yes | ID registration, rendezvous, hole punching |
| 21117 | TCP | hbbr | yes | relay |
| 21118 | TCP | hbbs | **no** | WebSocket, nginx only |
| 21119 | TCP | hbbr | **no** | WebSocket, nginx only |

**You must block 21118 and 21119 from the internet.** They are the plaintext listeners behind `/ws/id` and `/ws/relay`, and RustDesk Server trusts their `X-Real-IP` / `X-Forwarded-For` headers verbatim, so anyone reaching them directly can forge a source IP or skip TLS entirely. Upstream is explicit about it: *"Do not expose the WebSocket port directly to untrusted networks."*

Loopback binding is not an option — `-b` applies to every listener at once — so use a firewall:

```bash
ufw allow 80,443/tcp
ufw allow 21115:21117/tcp
ufw allow 21116/udp
ufw deny 21118/tcp
ufw deny 21119/tcp
```

This stack publishes no ports, so Docker never installs the `DOCKER` iptables chain that would bypass ufw. Behind a cloud firewall or security group, apply the same rules there.

## Updating

```bash
docker compose pull
docker compose up -d
```

`docker compose up -d` alone is not enough: Compose's default `missing` pull policy re-pulls only the `latest` tag, so `nginx:stable` would keep terminating TLS with whatever OpenSSL you first pulled.
