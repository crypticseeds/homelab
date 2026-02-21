# Pi-hole + Unbound + Gluetun VPN

A privacy-focused, network-wide ad-blocking solution with a recursive DNS resolver routed through a VPN tunnel. This setup ensures your DNS queries are private, secure, and independent of your ISP or third-party DNS providers.

## 🚀 Overview

- **Pi-hole**: Network-wide ad blocking and local DNS management.
- **Unbound**: A recursive, caching DNS resolver that talks directly to root servers.
- **Gluetun**: A lightweight VPN client that tunnels Unbound's traffic, protecting your DNS activity from your ISP.
- **Traefik Integration**: Secure HTTPS access to the Pi-hole web interface.

## 🏗 Architecture

```mermaid
graph TD
    Client[Client Device] -->|DNS Query (Port 53)| Pihole[Pi-hole (172.30.0.7)]
    Pihole -->|Upstream Query (Port 5335)| Unbound[Unbound Resolver via Gluetun]
    
    subgraph VPN_Namespace [Gluetun VPN Namespace (172.30.0.9)]
        Unbound
    end

    Unbound -->|Recursive Lookup| VPN[VPN Tunnel Interface]
    VPN -->|Encrypted Traffic| Internet((Root DNS Servers))
```

## 📂 Project Structure

```text
pihole/
├── .env                    # Environment variables (VPN keys, passwords)
├── docker-compose.yaml      # Container orchestration
├── etc-pihole/             # Pi-hole configuration and databases (persisted)
├── etc-dnsmasq.d/          # Pi-hole DNS settings (persisted)
├── gluetun/                # Gluetun configuration data
├── ubuntu_port_53_fix.md   # Fix for systemd-resolved port 53 conflict
└── unbound/
    └── unbound.conf        # Custom recursive DNS configuration
```

## 🛠 Prerequisites

1.  **Docker & Docker Compose**: Installed and running.
2.  **External Network**: A Docker network named `proxy` (used by Traefik) must exist.
    ```bash
    docker network create proxy
    ```

3.  **Data directories**: Create the directories used for Pi-hole, Gluetun, and dnsmasq config (Docker volume mounts). From the `pihole/` directory:
    ```bash
    mkdir -p etc-pihole gluetun etc-dnsmasq.d
    ```

4.  **Port 53 Availability**: On Ubuntu/Debian, `systemd-resolved` often occupies port 53.
    - Refer to `ubuntu_port_53_fix.md` for the solution.

## ⚙️ Configuration

### 1. Environment Variables (`.env`)
Create a `.env` file in the root directory (copy the example below and fill in your details):

```bash
# copy the example directly
cp .env.example .env 2>/dev/null || touch .env
```
Add the following content to `.env`:

```ini
# VPN Configuration (ProtonVPN/Wireguard example)
# Get your Wireguard config from your VPN provider
WIREGUARD_PRIVATE_KEY='your_private_key_here'
WIREGUARD_ADDRESSES='10.2.0.2/32'
SERVER_COUNTRIES='United Kingdom'

# Pi-hole Configuration
# This password is used to log in to the Pi-hole web interface
PIHOLE_WEBPASSWORD='your_secure_password'
TZ='Europe/London'
```

### 2. Unbound Preparation
Unbound runs as a non-root user (often UID 101 or 102). The configuration directory must be accessible.

```bash
# Set permissions for the unbound directory
sudo chown -R 101:102 ./unbound
```

## 🚀 Deployment

Start the stack:
```bash
docker compose up -d
```

Monitor logs to ensure Gluetun connects successfully and Pi-hole starts without errors:
```bash
docker compose logs -f
```

### Common Startup Issues
- **Gluetun unhealthy**: Check your `WIREGUARD_PRIVATE_KEY` and ensure it is valid for the `SERVER_COUNTRIES` selected.
- **Pi-hole FTL failed**: Check if port 53 is already in use (`sudo lsof -i :53`).

## 🔍 Verification & Testing

### 1. Test DNS Resolution
Check if Pi-hole can resolve queries through the chain:

```bash
# 1. Test from the host (targeting the Pi-hole container IP)
dig @172.30.0.7 google.com

# 2. Test internally from Pi-hole to Unbound
docker exec pihole dig @172.30.0.9 -p 5335 cloudflare.com
```

### 2. Test DNSSEC Validation
Verify that DNSSEC is validating signatures.

```bash
# Should return SERVFAIL (broken signature)
docker exec pihole dig @172.30.0.9 -p 5335 sigfail.erne.ch +dnssec

# Should return NOERROR with 'ad' (Authenticated Data) flag
docker exec pihole dig @172.30.0.9 -p 5335 sigok.erne.ch +dnssec
```

## 🌐 Web Interface
Access the Pi-hole admin dashboard:
- **URL**: `https://pihole.internal.devopsfoundry.com` (Requires Traefik & DNS entry)
- **Direct IP**: `http://<host-ip>:80/admin` (Only if you map port 80 in docker-compose, which is currently commented out in favor of Traefik)

## 🛡 Security & Maintenance

- **Updating**:
  ```bash
  docker compose pull
  docker compose up -d
  docker image prune -f
  ```
- **Backup**:
  - `etc-pihole/`: Main config and stats.
  - `etc-dnsmasq.d/`: Custom DNS entries.

---
*Reference: [Pi-hole Documentation](https://docs.pi-hole.net/) | [Unbound Guide](https://docs.pi-hole.net/guides/dns/unbound/) | [Gluetun Wiki](https://github.com/qdm12/gluetun-wiki)*
