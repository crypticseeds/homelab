# Pi-hole + Unbound Quick Reference

## 🚀 Quick Start

```bash
# 1. Create directories
mkdir -p pihole/etc-pihole pihole/etc-dnsmasq.d

# 2. Set password in docker-compose.yaml or create .env file
cp .env.example .env
nano .env  # Edit PIHOLE_PASSWORD

# 3. Start the stack
docker compose up -d

# 4. Check logs
docker compose logs -f
```

## 📁 File Structure

```
pihole/
├── docker-compose.yaml       # Main configuration ✅
├── README.md                  # Full documentation
├── QUICKSTART.md             # This file
├── setup.sh                   # Automated setup script
├── .env.example              # Example environment variables
├── .env                       # Your environment variables (create this)
├── unbound/
│   └── unbound.conf          # Unbound config ✅
└── pihole/
    ├── etc-pihole/           # Auto-created by Docker
    └── etc-dnsmasq.d/        # Auto-created by Docker
```

## 🔧 Common Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f
docker logs pihole
docker logs unbound

# Restart services
docker compose restart

# Update to latest images
docker compose pull
docker compose up -d

# Reset Pi-hole password
docker exec -it pihole pihole -a -p
```

## 🧪 Testing

```bash
# Test DNS resolution
nslookup google.com <your-docker-host-ip>
dig @<your-docker-host-ip> google.com

# Test from inside Pi-hole container
docker exec pihole nslookup google.com 172.30.0.8

# Test ad blocking
nslookup flurry.com <your-docker-host-ip>
# Should return 0.0.0.0 or similar blocked response
```

## 🌐 Access Points

- **Web UI (Direct)**: `http://<docker-host-ip>:8080/admin`
- **Web UI (Traefik)**: Configure route to `pihole.local`
- **DNS Service**: `<docker-host-ip>:53`

## 🔍 Verification

```bash
# Check both containers are running
docker ps | grep -E 'pihole|unbound'

# Check network connectivity
docker exec pihole ping -c 3 172.30.0.8

# Check DNS from Pi-hole to Unbound
docker exec pihole nslookup google.com 172.30.0.8

# Check Unbound stats
docker exec unbound unbound-control stats_noreset
```

## ⚠️ Troubleshooting

### Port 53 in use?
```bash
# Check what's using it
sudo lsof -i :53

# If systemd-resolved:
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
```

### Can't reach web interface?
```bash
# Check if container is running
docker ps | grep pihole

# Check if port is listening
sudo lsof -i :8080

# View recent logs
docker logs pihole --tail 50
```

### DNS not working?
```bash
# Verify Unbound is reachable
docker exec pihole nslookup google.com 172.30.0.8

# Check Unbound logs
docker logs unbound --tail 50
```

## 📊 Key Configuration

| Component | IP Address | Port | Purpose |
|-----------|------------|------|---------|
| Pi-hole | 172.30.0.7 | 53 | DNS filtering |
| Unbound | 172.30.0.8 | 53 | Recursive DNS |
| Pi-hole Web | Host IP | 8080 | Admin UI |

## 🔐 Security Checklist

- [ ] Changed default WEBPASSWORD
- [ ] Configured firewall rules (if needed)
- [ ] Set up Traefik authentication for web UI (recommended)
- [ ] Scheduled regular backups
- [ ] Configured update notifications

## 💾 Backup

```bash
# Backup configuration
tar -czf pihole-backup-$(date +%F).tar.gz pihole/

# Or use Pi-hole Teleporter: Web UI → Settings → Teleporter
```

## 🔄 Updates

```bash
# Pull latest images
docker compose pull

# Recreate with new images
docker compose up -d

# Clean up old images
docker image prune -f
```

## 📚 More Info

See `README.md` for complete documentation including:
- Detailed setup instructions
- Network architecture
- Advanced troubleshooting
- Security best practices
