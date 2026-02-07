#!/bin/bash

# Pi-hole + Unbound Setup Script
# This script creates the necessary directory structure for the Docker setup

set -e

echo "🐳 Creating Pi-hole directory structure..."

# Create Pi-hole data directories
mkdir -p pihole/etc-pihole
mkdir -p pihole/etc-dnsmasq.d

echo "✅ Directory structure created:"
echo "   📁 pihole/etc-pihole/"
echo "   📁 pihole/etc-dnsmasq.d/"
echo ""

# Check if Traefik network exists
echo "🔍 Checking for Traefik network..."
if docker network ls | grep -q traefik; then
    echo "✅ Traefik network found"
else
    echo "⚠️  Traefik network not found"
    read -p "   Create Traefik network? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker network create traefik
        echo "✅ Traefik network created"
    else
        echo "⚠️  You'll need to create the Traefik network before starting the stack"
    fi
fi
echo ""

# Check if port 53 is available
echo "🔍 Checking if port 53 is available..."
if sudo lsof -i :53 > /dev/null 2>&1; then
    echo "⚠️  Port 53 is already in use:"
    sudo lsof -i :53
    echo ""
    echo "   You may need to stop systemd-resolved:"
    echo "   sudo systemctl disable systemd-resolved"
    echo "   sudo systemctl stop systemd-resolved"
else
    echo "✅ Port 53 is available"
fi
echo ""

# Check if port 8080 is available
echo "🔍 Checking if port 8080 is available..."
if sudo lsof -i :8080 > /dev/null 2>&1; then
    echo "⚠️  Port 8080 is already in use:"
    sudo lsof -i :8080
else
    echo "✅ Port 8080 is available"
fi
echo ""

echo "🎉 Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Edit docker-compose.yaml and set your WEBPASSWORD"
echo "   2. Run: docker compose up -d"
echo "   3. Access Pi-hole at: http://$(hostname -I | awk '{print $1}'):8080/admin"
echo ""
