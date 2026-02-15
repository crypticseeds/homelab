# Uptime Kuma

Self-hosted monitoring for services and endpoints, with a simple web UI and alerting.

## Prerequisites

- Docker and Docker Compose
- Traefik running with an external network named `proxy`
- (Optional) `TZ` set in your environment or in a `.env` file in this directory (e.g. `TZ=Europe/London`) so timestamps and schedules are correct

## Data directory

**Create the data directory before first run.** The compose file uses `./data` for persistent storage (SQLite DB and config).

```bash
mkdir data
```

**If the container fails with permission errors** (e.g. cannot create database), the app runs as UID 1000 inside the container. Make the directory writable by that user:

```bash
sudo chown -R 1000:1000 data
```

This is needed if the directory was created with `sudo mkdir` (owned by root) or if your host user’s UID is not 1000. If you created `data` with plain `mkdir` and your user UID is 1000, you usually don’t need `chown`.

## Usage

```bash
cd /path/to/homelab/uptime-kuma
docker compose up -d
```

## Access

- **Via Traefik:** https://uptime-kuma.internal.devopsfoundry.com (requires Traefik, DNS, and the middlewares `security-headers@file` and `internal-ip-whitelist@file`)
- **Direct:** http://localhost:3001 (or http://&lt;host-ip&gt;:3001)

On first visit, create an admin account; credentials are stored in the data directory.

## Configuration

- **Timezone:** Set `TZ` in `.env` or in the environment (e.g. `TZ=Europe/London`).
- **Logging:** Container logs are limited to 3 × 10MB (json-file driver) to avoid unbounded disk use.

## Compose notes

- Uses external network `proxy` for Traefik; ensure it exists (`docker network create proxy` if you manage it manually).
- Restart policy is `always` so the container comes back after reboots.
