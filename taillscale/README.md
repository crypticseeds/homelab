# Tailscale

Secure remote access and mesh VPN for your homelab. Tailscale creates a private network (tailnet) so you can reach services and SSH into machines from anywhere without opening ports.

## Overview

- **Zero-config VPN**: WireGuard-based mesh; no port forwarding or dynamic DNS.
- **Remote SSH**: Use `tailscale up --ssh` to SSH into machines by hostname.
- **Custom DNS**: Point your tailnet at private Pi-hole/Unbound for ad blocking and local resolution (see [Use Pi-hole/Unbound as DNS](#use-pi-holeunbound-as-dns)).

## Prerequisites

- A [Tailscale account](https://login.tailscale.com/start) (free Personal plan supports 3 users, 100 devices).
- One device (phone or laptop) to create the tailnet and approve new nodes.

---

## Installation

### Option A: Generic install (any Linux)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

Then start and authenticate:

```bash
sudo tailscale up
```

Open the URL shown in the terminal in a browser and log in to add the machine to your tailnet.

### Option B: Ubuntu (Debian) via APT

Add Tailscale’s signing key and repo, then install:

```bash
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

sudo apt-get update
sudo apt-get install -y tailscale
```

Authenticate:

```bash
sudo tailscale up
```

For other distros and versions, see [Tailscale’s install docs](https://tailscale.com/download/linux).

---

To allow SSH access to this machine by Tailscale hostname:

```bash
sudo tailscale up --ssh
```

Clients must have [Use Tailscale DNS settings](https://tailscale.com/docs/features/client/manage-preferences#use-tailscale-dns-settings) enabled (or use MagicDNS) to resolve hostnames.

### Check status and IP

```bash
# Connection status
tailscale status

# This machine’s Tailscale IPv4 (e.g. 100.x.x.x)
tailscale ip -4
```

### Always-on machines (e.g. servers)

To avoid re-auth prompts, disable key expiry in the [Admin console → Machines](https://login.tailscale.com/admin/machines): click the machine → **Disable key expiry**. Only do this for trusted devices.

---

## Use Pi-hole/Unbound as DNS

You can make all devices on your tailnet use your homelab’s Pi-hole (and Unbound) for DNS so ad blocking and local resolution work when you’re away from home.

### 1. Run Tailscale on the host that serves Pi-hole

Install Tailscale on the same host that runs Pi-hole (see [Installation](#installation)). Bring the node up **without** using Tailscale for DNS on this host (so it doesn’t try to use itself):

```bash
sudo tailscale up --accept-dns=false
```

Optional: enable SSH on that host:

```bash
sudo tailscale up --accept-dns=false --ssh
```

### 2. Get the Pi-hole host’s Tailscale IP

- Open [Tailscale Admin → Machines](https://login.tailscale.com/admin/machines).
- Find the machine that runs Pi-hole and note its **Tailscale IPv4** (e.g. `100.64.x.x`).

### 3. Add Pi-hole as a custom nameserver in Tailscale

- Go to [Tailscale Admin → DNS](https://login.tailscale.com/admin/dns).
- Under **Nameservers**, click **Add nameserver** → **Custom**.
- Enter the Pi-hole host’s Tailscale IPv4 (from step 2).
- Click **Save**.

### 4. Override local DNS (optional but recommended)

So that devices always use your Pi-hole when on the tailnet:

- On the same [DNS](https://login.tailscale.com/admin/dns) page, enable **Override local DNS** (or “Override DNS servers”).
- Save.

Devices that have [Use Tailscale DNS settings](https://tailscale.com/docs/features/client/manage-preferences#use-tailscale-dns-settings) enabled will then use Pi-hole for DNS whenever they’re connected to the tailnet.

### 5. Pi-hole: allow queries from Tailscale

Pi-hole must accept DNS queries from Tailscale. If Pi-hole is in Docker:

- Ensure the host’s Tailscale interface can reach Pi-hole (e.g. Pi-hole listening on `0.0.0.0:53` or on the host network).
- In Pi-hole’s web UI: **Settings → DNS**; switch to **Expert** and under **Interface settings** enable **Permit all origins** so queries from Tailscale (100.x.x.x) are allowed.

Use a strong Pi-hole admin password and keep the host firewalled.

### Notes

- If Pi-hole is not on a Tailscale IP (e.g. only on a private LAN), you need a [subnet router](https://tailscale.com/docs/features/subnet-routers) so the tailnet can reach that LAN; then you can use the subnet router’s Tailscale IP or the Pi-hole LAN IP depending on your setup.
- Some users see occasional DNS timeouts with “Override local DNS” on Linux/macOS; if that happens, you can turn Override off and rely on client-side “Use Tailscale DNS” where needed.

---

## Useful links

- [Tailscale Admin Console](https://login.tailscale.com/admin)
- [DNS in Tailscale](https://tailscale.com/kb/1054/dns)
- [Pi-hole + Tailscale (official)](https://tailscale.com/kb/1114/pi-hole)
- [Tailscale SSH](https://tailscale.com/docs/features/ssh)
- [Subnet routers](https://tailscale.com/docs/features/subnet-routers) (access LAN devices without Tailscale on each one)
