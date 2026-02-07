# Pi-hole + Unbound Docker Setup

This setup provides a private, recursive DNS solution using Pi-hole for ad-blocking and Unbound as a recursive DNS resolver. No queries are sent to third-party DNS providers like Google or Cloudflare - all DNS queries are resolved directly from root DNS servers.

## Overview

- **Pi-hole**: Network-wide ad blocking and local DNS management
- **Unbound**: Recursive DNS resolver for enhanced privacy
- **Traefik Integration**: Secure web UI access via reverse proxy

## Architecture

```
Client Device
    ↓
Pi-hole (172.30.0.7:53) ← DNS queries
    ↓
Unbound (172.30.0.8:53) ← Recursive resolution
    ↓
Root DNS Servers
```

## Prerequisites

- Docker and Docker Compose installed
- Traefik network already created (external network)
- Port 53 (TCP/UDP) available on host
- Port 8080 (TCP) available on host for web UI (or use Traefik proxy)

## Directory Structure

```
pihole/
├── docker-compose.yaml       # Main Docker Compose configuration
├── README.md                  # This file
├── unbound/
│   └── unbound.conf          # Unbound DNS configuration
└── pihole/
    ├── etc-pihole/           # Pi-hole configuration (auto-created)
    └── etc-dnsmasq.d/        # DNSmasq configuration (auto-created)
```

## Setup Instructions

### 1. Create Directory Structure

From the `homelab/pihole` directory, create the necessary folders:

```bash
# Create the pihole data directories
mkdir -p pihole/etc-pihole pihole/etc-dnsmasq.d

# The unbound directory already exists with unbound.conf
```

### 2. Verify Traefik Network Exists

The setup requires an external Traefik network. Verify it exists:

```bash
docker network ls | grep traefik
```

If it doesn't exist, create it:

```bash
docker network create traefik
```

### 3. Configure Pi-hole Password

Edit the `docker-compose.yaml` file and replace `PI_HOLE_PASSWORD` with your desired password:

```yaml
WEBPASSWORD: "your_secure_password_here"
```

Or use an environment variable:

```bash
export PIHOLE_PASSWORD="your_secure_password_here"
```

And update docker-compose.yaml:

```yaml
WEBPASSWORD: "${PIHOLE_PASSWORD}"
```

### 4. Deploy the Stack

Start the containers:

```bash
docker compose up -d
```

Check the logs to ensure everything is running:

```bash
# Check both containers
docker compose logs -f

# Or check individually
docker logs pihole
docker logs unbound
```

### 5. Configure Your Network

#### Option A: Router-level DNS (Recommended)
Configure your router's DHCP settings to use your Pi-hole IP as the primary DNS server.

#### Option B: Per-device DNS
On each device, manually set the DNS server to your Docker host's IP address.

### 6. Verify DNS Resolution

Test that DNS queries are working:

```bash
# Test DNS resolution through Pi-hole
nslookup google.com <your-docker-host-ip>

# Or using dig
dig @<your-docker-host-ip> google.com
```

### 7. Access Pi-hole Web Interface

Access the Pi-hole admin interface:

- **Direct access**: `http://<docker-host-ip>:8080/admin`
- **Via Traefik**: Configure a Traefik route to `pihole.local` (see Traefik configuration)

Login with the password you set in step 3.

## Verification Checklist

After deployment, verify:

- [ ] Both containers are running: `docker ps | grep -E 'pihole|unbound'`
- [ ] Pi-hole can reach Unbound: `docker exec pihole nslookup google.com 172.30.0.8`
- [ ] DNS queries work from host: `nslookup google.com <docker-host-ip>`
- [ ] Web interface is accessible
- [ ] Ad blocking is working (test with: http://flurry.com)

## Key Configuration Details

### Network Configuration

- **Internal Network**: `172.30.0.0/24`
  - Pi-hole: `172.30.0.7`
  - Unbound: `172.30.0.8`
- **Traefik Network**: External, for web UI access
- **No port conflicts**: Internal communication uses Docker DNS

### Volumes

The following directories are bind-mounted and will persist data:

- `./pihole/etc-pihole`: Pi-hole configuration, blocklists, and custom DNS records
- `./pihole/etc-dnsmasq.d`: DNSmasq configuration files
- `./unbound`: Unbound configuration (read-only)

**Note**: You do NOT need to manually create Docker volumes. The directories will be auto-created when the containers start.

### DNS Flow

1. Client sends DNS query to Pi-hole (172.30.0.7:53)
2. Pi-hole checks:
   - Local DNS records
   - Blocklists (returns 0.0.0.0 if blocked)
3. If not blocked, forwards to Unbound (172.30.0.8:53)
4. Unbound performs recursive resolution from root servers
5. Response sent back through Pi-hole to client

## Troubleshooting

### Containers won't start

```bash
# Check if port 53 is already in use
sudo lsof -i :53

# If systemd-resolved is using it (common on Ubuntu):
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
```

### DNS queries not working

```bash
# Check if Unbound is reachable from Pi-hole
docker exec pihole nslookup google.com 172.30.0.8

# Check Unbound logs
docker logs unbound

# Check Pi-hole logs
docker logs pihole
```

### Web interface not accessible

```bash
# Verify Pi-hole is running
docker ps | grep pihole

# Check if port 8080 is listening
sudo lsof -i :8080

# Check Pi-hole logs for errors
docker logs pihole --tail 50
```

### Reset Pi-hole password

```bash
docker exec -it pihole pihole -a -p
```

## Updating

To update the containers to the latest versions:

```bash
# Pull latest images
docker compose pull

# Recreate containers with new images
docker compose up -d

# Remove old images
docker image prune -f
```

## Backup

Important files to backup:

```bash
# Backup Pi-hole configuration
tar -czf pihole-backup-$(date +%F).tar.gz pihole/

# Or use Pi-hole's built-in teleporter feature via web UI
```

## Uninstall

To completely remove the setup:

```bash
# Stop and remove containers
docker compose down

# Remove data (CAUTION: This deletes all configuration!)
rm -rf pihole/etc-pihole pihole/etc-dnsmasq.d

# Remove networks (if no longer needed)
docker network rm pihole_internal
```

## Security Notes

- Pi-hole web interface should ideally be accessed via Traefik with authentication
- The internal network (172.30.0.0/24) is isolated from external access
- DNS queries from LAN are accepted; configure firewall rules if exposing to WAN
- Keep containers updated regularly for security patches

## References

- [Pi-hole Documentation](https://docs.pi-hole.net/)
- [Pi-hole + Unbound Guide](https://docs.pi-hole.net/guides/dns/unbound/)
- [Unbound Documentation](https://unbound.docs.nlnetlabs.nl/)
- [klutchell/unbound Docker Image](https://hub.docker.com/r/klutchell/unbound)

## Support

For issues specific to this setup, check:
1. Container logs: `docker compose logs`
2. Pi-hole query log: Web interface → Tools → Query Log
3. Unbound stats: `docker exec unbound unbound-control stats`
