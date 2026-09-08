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

`hbbs`, `hbbr`, nginx and certbot use host networking, so they bind on every interface.

| Port | Protocol | Service | Internet | Purpose |
| --- | --- | --- | --- | --- |
| 80 | TCP | certbot | yes | ACME http-01, bound only while issuing or renewing |
| 443 | TCP | nginx | yes | WebSocket over TLS |
| 21115 | TCP | hbbs | yes | NAT type test |
| 21116 | TCP + UDP | hbbs | yes | ID registration, rendezvous, hole punching |
| 21117 | TCP | hbbr | yes | relay |
| 21118 | TCP | hbbs | **no** | WebSocket, nginx only |
| 21119 | TCP | hbbr | **no** | WebSocket, nginx only |

**You must block 21118 and 21119 from the internet.** They are plaintext listeners whose `X-Real-IP` / `X-Forwarded-For` headers RustDesk Server trusts verbatim, so anyone reaching them directly can forge a source IP.

Example, with ufw:

```bash
ufw allow 80,443/tcp
ufw allow 21115:21117/tcp
ufw allow 21116/udp
ufw deny 21118/tcp
ufw deny 21119/tcp
```

## Updating

```bash
docker compose pull
docker compose up -d
```

`docker compose up -d` alone won't update `nginx:stable` — Compose's default `missing` pull policy only re-pulls `latest`.
