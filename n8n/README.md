# n8n Workflow Automation

Self-hosted [n8n](https://n8n.io/) instance running in Docker, configured with Traefik for reverse proxying and SSL termination.

## Overview

This setup provides a persistent n8n instance accessible via a custom domain. It includes configuration for:
- **Reverse Proxy**: Integration with Traefik via Docker labels.
- **Persistence**: Bind mounts for data and local files.
- **Security**: Middleware for security headers and internal IP whitelisting.

## Prerequisites

- Docker & Docker Compose
- Traefik reverse proxy running on the `proxy` external network.
- `local-files` directory for file manipulations within workflows.
- `n8n_data` directory for persisting n8n data.

## Configuration

### Environment Variables (.env)
Create a `.env` file in this directory with the following variables:

```bash
TZ=Europe/London
GENERIC_TIMEZONE=Europe/London
```

### Docker Compose Overrides
Key configuration in `docker-compose.yaml`:
- **Domain**: `n8n.internal.devopsfoundry.com`
- **Webhook URL**: `https://n8n.internal.devopsfoundry.com/` (Crucial for webhook triggers to work correctly behind the proxy)
- **Timezone**: Syncs with host/env settings.

## Directory Structure

Ensure the following directories exist in the project root to maintain persistence and functionality:

- `./n8n_data`: Stores the n8n database, workflows, and credentials. (Bind mounted to `/home/node/.n8n`)
- `./local-files`: A directory accessible by n8n for reading/writing files during workflows. (Bind mounted to `/files`)

## Usage

1. **Create Data Directories** (if they don't exist):
   ```bash
   mkdir n8n_data local-files
   ```

2. **Start the Service**:
   ```bash
   docker compose up -d
   ```

3. **Access**:
   - Web Interface: [https://n8n.internal.devopsfoundry.com](https://n8n.internal.devopsfoundry.com)
   - Local Port: `5678`

## Network & Traefik Basic Auth/Middleware
This service expects a `proxy` external docker network to exist.
It applies the following Traefik middlewares:
- `security-headers`
- `internal-ip-whitelist` (Restricts access to internal network IP ranges)

## Documentation
- [Official n8n Docker Documentation](https://docs.n8n.io/hosting/installation/server-setups/docker-compose/)
