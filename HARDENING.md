# OS & SSH Hardening Guide

This guide covers the initial setup steps to secure the host before deploying services.

## 1. OS Hardening

### Create Non-Root User

```bash
# Create the user (replace 'yourusername' with your actual username)
sudo adduser yourusername

# Add user to sudo group
sudo usermod -aG sudo yourusername

# Optional: Enable passwordless sudo (use with caution)
sudo visudo
# Add this line:
# yourusername ALL=(ALL) NOPASSWD:ALL
```

---

## 2. SSH Hardening

### Backup and Configure

```bash
# Backup original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit SSH daemon config
sudo vim /etc/ssh/sshd_config
```

**Paste the hardened config below** (see full config in next section)

### Create Login Banner

```bash
sudo vim /etc/ssh/banner.txt
```

Add:
```

╔══════════════════════════════════════════╗
║   AUTHORIZED ACCESS ONLY                 ║
║   Unauthorized access is prohibited      ║
╚══════════════════════════════════════════╝
```

### Hardened SSH Server Config

**File:** `/etc/ssh/sshd_config`

```bash
# /etc/ssh/sshd_config - Hardened SSH Server Configuration

# Network
Port 22
AddressFamily inet
ListenAddress 0.0.0.0

# Authentication
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
UsePAM yes

# Allow specific user only (replace with your username)
AllowUsers yourusername

# Disable unused authentication methods
GSSAPIAuthentication no
HostbasedAuthentication no
IgnoreRhosts yes

# Session settings
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 10
LoginGraceTime 60

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

# Cryptography - Modern and secure only
# Host Keys (Ed25519 only, remove RSA/ECDSA/DSA)
HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com

# MACs (Encrypt-Then-MAC only)
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Key Exchange Algorithms
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# Public Key Algorithms
PubkeyAcceptedAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256

# Security hardening
StrictModes yes
PermitUserEnvironment no
Compression no
UseDNS no
AllowAgentForwarding no
AllowTcpForwarding yes # Allows Coding IDE
PermitTunnel yes # Allows Coding IDE
Banner /etc/ssh/banner.txt
```

### Test and Apply

```bash
# Test config for syntax errors
sudo sshd -t

# If no errors, restart SSH (keep current session open!)
sudo systemctl restart sshd

# In a NEW terminal, test login before closing current session
ssh yourusername@your-server-ip
```

### Optional: Remove Old Host Keys

```bash
# Keep only Ed25519, remove RSA/ECDSA/DSA
sudo rm /etc/ssh/ssh_host_rsa_key*
sudo rm /etc/ssh/ssh_host_ecdsa_key*
sudo rm /etc/ssh/ssh_host_dsa_key*
```

---

## 3. Install Fail2Ban (Optional but Recommended)

```bash
# Install
sudo apt update
sudo apt install fail2ban -y

# Configure
sudo vim /etc/fail2ban/jail.local
```

Add:
```ini
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
```

```bash
# Enable and start
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status sshd

# Manually unban an IP
sudo fail2ban-client set sshd unbanip 203.0.113.50
```
