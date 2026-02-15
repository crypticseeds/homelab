# Homelab Infrastructure Repository

Welcome to my self-hosted homelab repository. This codebase serves as the central configuration hub for my home infrastructure, focusing on reproducibility, documentation, and security.

The stack is designed to be modular, with each service contained in its own directory along with its specific documentation.

## 🚀 Quick Links & Service Integration

Most services have their own detailed `README.md` within their respective directories. Please refer to those for specific setup, configuration, and maintenance instructions.

| Service | Directory | Description | Dependencies |
| :--- | :--- | :--- | :--- |
| **OS Hardening** | [`./HARDENING.md`](./HARDENING.md) | Initial server security setup (SSH, Fail2Ban, etc.) | N/A |
| **Docker** | System | Container runtime (foundation) | OS |
| **Tailscale** | [`./taillscale`](./taillscale) | Secure remote access & mesh VPN | Docker |
| **Traefik** | [`./traefik`](./traefik) | Reverse proxy & SSL termination | Docker, `proxy` network |
| **Pi-hole + Unbound** | [`./pihole`](./pihole) | DNS ad-blocking & recursive resolver | Docker |
| **Authelia** | [`./authelia`](./authelia) | SSO & Authentication portal | Traefik |
| **Uptime Kuma** | [`./uptime-kuma`](./uptime-kuma) | Service monitoring & status pages | Traefik |
| **Dockhand** | [`./dockhand`](./dockhand) | Docker container management UI | Traefik |
| **n8n** | [`./n8n`](./n8n) | Workflow automation tool | Traefik |
| **Portainer** | [`./portainer`](./portainer) | Alternative Docker management UI | Traefik |

## 🛠️ Deployment Workflow

The recommended deployment order ensures dependencies (like networking and authentication) are available for dependent services.

1.  **Fundamental Security**: Apply configurations from [`HARDENING.md`](./HARDENING.md).
2.  **Network Layer**: Deploy **Tailscale** for remote management.
3.  **Proxy Layer**: Deploy **Traefik** to establish the ingress and `proxy` network.
4.  **Core Services**:
    *   Deploy **Pi-hole + Unbound** for DNS.
    *   Deploy **Authelia** for security (optional).
5.  **Applications**: Deploy **Uptime Kuma**, **Dockhand**, **n8n**, etc.

## 📂 Repository Structure

-   Each directory typically contains:
    -   `compose.yaml` (or `docker-compose.yml`): The service definition.
    -   `.env.example`: Template for environment variables.
    -   `README.md`: Service-specific documentation.

## 🤝 Contributing & Maintenance

-   **Updates**: Check individual service directories for update procedures.
-   **Backups**: Ensure persistent volumes (often mapped to `./data` or similar in service dirs) are backed up regularly.

---
*Note: This overview is kept lightweight. For deep dives into specific configurations, please navigate to the service's directory.*
