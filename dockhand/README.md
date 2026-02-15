# Dockhand

Dockhand is a lightweight, modern, and user-friendly management UI for Docker. It provides a web interface to easily manage your containers, images, volumes, networks, and Docker Compose stacks.

This setup includes configuration for running Dockhand behind a Traefik reverse proxy with automatic SSL via Cloudflare.

## Features

- **Container Management**: Start, stop, restart, and remove containers.
- **Image Management**: Pull, tag, and remove Docker images.
- **Volume & Network Management**: Create and manage volumes and networks.
- **Stack Visualization**: View and manage Docker Compose stacks.
- **Secure Access**: Configured with Traefik for secure HTTPS access.

## Prerequisites

- Docker and Docker Compose installed.
- An external Docker network named `proxy` created (for Traefik integration).
  ```bash
  docker network create proxy
  ```

## Installation

1. **Clone the repository** (if applicable) or navigate to the directory.

2. **Create the Data Directory**
   
   To ensure proper permissions when using a bind mount, create the data directory on your host machine before starting the container:
   ```bash
   mkdir dockhand_data
   ```

3. **Start the Service**

   Run the following command to start Dockhand:
   ```bash
   docker-compose up -d
   ```

## Access

Once the container is up and running, you can access the Dockhand dashboard via:

- **Web Interface (Traefik)**: [https://dockhand.internal.devopsfoundry.com](https://dockhand.internal.devopsfoundry.com)
- **Local Fallback**: `http://localhost:3000`

## Configuration Details

### Docker Compose

The `docker-compose.yaml` file configures the `dockhand` service with the following key settings:

- **Image**: `fnsys/dockhand:latest`
- **Volumes**:
  - `/var/run/docker.sock`: Mounted to allow Dockhand to communicate with the Docker daemon.
  - `./dockhand_data`: Bind mount for persisting application data.
- **Networks**: Connected to the `proxy` network for Traefik routing.
- **Traefik Labels**: Configured to route traffic from `dockhand.internal.devopsfoundry.com` via HTTPS.

### Security Note

Ensure your `.env` file lists sensitive credentials and is **never committed** to version control.
