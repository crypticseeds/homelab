# Traefik v3 Secure Homelab Setup

This setup uses Traefik v3 as a reverse proxy with Cloudflare DNS challenge for automatic Wildcard SSL certificates. It uses **Docker Secrets** for sensitive data, ensuring full compatibility with Portainer/Dockhand.

## Quick Start (Recreate Everything)

Run the following script to create all necessary configuration files and folders in the current directory. This is useful when moving to a new VM.

```bash
#!/bin/bash

# 1. Create Docker Network (required for Traefik to communicate with other containers)
docker network create proxy

# 2. Create Directories
mkdir -p traefik
mkdir -p traefik/dynamic

# 3. Create acme.json with correct permissions
touch traefik/acme.json
chmod 600 traefik/acme.json

# 4. Create Empty Configuration Files (Populate these with your actual config!)
touch traefik/traefik.yml
touch traefik/docker-compose.yaml
touch traefik/dynamic/middlewares.yml
touch traefik/dynamic/tls.yml
touch traefik/.env

echo "Traefik directory structure created. Copy your existing configs into the created files."
```

## Features
- **Traefik v3.6**: Latest stable version.
- **Docker Secrets**: Sensitive keys (`cf_dns_token`, `basic_auth_credentials`) are managed externally.
- **Secure by Default**: 
  - HTTP to HTTPS redirection.
  - Strict security headers.
  - File-based Middleware for Auth (`dynamic/middlewares.yml`).

## Prerequisites
1. **Docker & Docker Compose** installed.
2. **Secrets Manager** (Portainer, Dockhand, or manual Docker Swarm/Secrets).
3. **Cloudflare Account**:
   - API Token with DNS Edit permissions.

## Setup Instructions

### 1. Create Secrets (External)

You must create the following secrets in your environment (Portainer/Dockhand) named **exactly** as follows:

| Secret Name | Content |
|-------------|---------|
| `cf_dns_token` | Your Cloudflare DNS API Token |
| `basic_auth_credentials` | `user:hashed_password` (see below) |

#### Generate Basic Auth Password Hash

**Option 1: Using htpasswd (if installed)**
```bash
htpasswd -nb admin yourpassword
```

**Option 2: Using Docker (if htpasswd not available)**
```bash
docker run --rm httpd:alpine htpasswd -nb admin yourpassword
```

This will output something like: `admin:$apr1$xyz...`

Copy the **entire output** and create a secret named `basic_auth_credentials` with this value.

### 2. Configuration (.env)

Edit `.env` for non-sensitive config:
```bash
vim .env
```
- `CLOUDFLARE_EMAIL`: Your Cloudflare email.

### 3. Running
Ensure you are in the directory where you ran the setup script:
```bash
docker compose up -d
```
*Traefik will read the `CF_DNS_API_TOKEN` from `/run/secrets/cf_dns_token`.*

## Adding New Services

Use the following labels for apps behind Traefik (internal + Tailscale only). Replace `myapp` with your service name in router and rule, and ensure the service is on the `proxy` network.

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myapp.rule=Host(`myapp.internal.devopsfoundry.com`)"
  - "traefik.http.routers.myapp.entrypoints=https"
  - "traefik.http.routers.myapp.tls=true"
  - "traefik.http.routers.myapp.tls.certresolver=cloudflare"
  - "traefik.http.routers.myapp.middlewares=security-headers@file,internal-ip-whitelist@file"
  - "traefik.http.routers.myapp.service=myapp@internal"
```

Add to your service (same name as in the router):

```yaml
networks:
  - proxy
```

And at the bottom of the compose file:

```yaml
networks:
  proxy:
    external: true
```
