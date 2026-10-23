#!/bin/bash
# One-time setup on a fresh Ubuntu 22.04/24.04 ARM64 server (Oracle Ampere, Hetzner CAX, AWS Graviton...).
# Usage:  sudo ./deploy/setup.sh [domain]
#   with a domain pointing at the server you get https automatically, without one it serves http on port 80.
set -euo pipefail
cd "$(dirname "$0")"

if [ "$(uname -m)" != "aarch64" ]; then
  echo "!! this host is $(uname -m). the game client is arm64 only, use an ARM64 server." >&2
  exit 1
fi

echo "== docker"
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sh
fi

echo "== android kernel modules (binder)"
apt-get update -y
apt-get install -y "linux-modules-extra-$(uname -r)" || true
echo 'options binder_linux devices="binder,hwbinder,vndbinder"' > /etc/modprobe.d/redroid.conf
echo 'binder_linux' > /etc/modules-load.d/redroid.conf
modprobe binder_linux devices="binder,hwbinder,vndbinder"
grep -q binder /proc/filesystems || { echo "!! binder module did not load, see deploy/README.md" >&2; exit 1; }

echo "== web password"
if [ ! -f .env ]; then
  read -rp "username for the game page [admin]: " WEB_USER
  WEB_USER=${WEB_USER:-admin}
  read -rsp "password: " WEB_PASS; echo
  HASH=$(docker run --rm caddy:2 caddy hash-password --plaintext "$WEB_PASS")
  {
    echo "WEB_USER=$WEB_USER"
    echo "WEB_PASS_HASH='$HASH'"
    echo "SITE_ADDRESS=${1:-:80}"
  } > .env
  chmod 600 .env
fi

echo "== build and start"
docker compose up -d --build

echo
echo "done. next: put the gaucho apk on the server and run  ./deploy/install-apk.sh Gaucho.apk"
