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

# 3. Create acme.json with correct permissions (Traefik requires 600; 664 will be rejected)
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

### 2. acme.json permissions

Traefik will not use the ACME resolver if `acme.json` is readable by others. It must be **mode 600** (owner read/write only).

**If the file already exists with wrong permissions (e.g. 664):**
```bash
chmod 600 traefik/acme.json
```

Then restart Traefik: `docker compose up -d` (or restart the container).

### 3. Configuration (.env)

Edit `.env` (do not commit this file):
```bash
vim .env
```
- `CLOUDFLARE_EMAIL`: Your Cloudflare account email.
- `CF_DNS_API_TOKEN`: Your Cloudflare API token (Zone → DNS → Edit). Required for ACME DNS challenge.

### 4. Running
Ensure you are in the directory where you ran the setup script:
```bash
docker compose up -d
```
*Traefik reads the Cloudflare token from the `CF_DNS_API_TOKEN` variable in your `.env` file.*

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

## Troubleshooting

- **"permissions 664 for acme.json are too open, please use 600"** — Run `chmod 600 traefik/acme.json` and restart Traefik.
- **"Router uses a nonexistent certificate resolver"** — Usually caused by the ACME resolver being skipped (e.g. due to the `acme.json` permission error above). Fix `acme.json` permissions and restart.
