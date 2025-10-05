# rustdesk-server-docker
Docker Compose configuration for RustDesk Server OSS with WebSocket support

## Usage

```bash
git clone https://github.com/Nerahikada/rustdesk-server-docker.git rustdesk-server
cd rustdesk-server/

# Replace placeholders in configuration files
sed -i 's/YOUR_EMAIL_ADDRESS_HERE/your_email_address[at]example.com/g' compose.yaml
sed -i 's/RUSTDESK_SERVER_DOMAIN_HERE/rustdesk.example.com/g' compose.yaml https.conf

docker compose up -d
```
