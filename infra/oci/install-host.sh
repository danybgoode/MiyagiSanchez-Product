#!/usr/bin/env bash
# One-time (idempotent) host setup for Miyagi on `panfleto-prod`. Run ON the VM as root:
#   sudo /opt/miyagi/infra/oci/install-host.sh
#
# Creates the state directories on the /data block volume, the shared `edge` docker network that
# panfleto's Caddy joins, the /opt/edge/{sites,certs} folders Caddy mounts, installs rclone (R2 uploads),
# and installs + enables the systemd units in infra/oci/systemd/. The cron timers are installed but
# NOT enabled: until the cutover, Cloud Scheduler still calls the Cloud Run copy, and both firing would
# double-send every daily email.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$(id -u)" -eq 0 ] || { echo "run as root (sudo)" >&2; exit 1; }

install -d -m 0700 -o 70 -g 70 /data/miyagi/postgres     # 70 = postgres uid in postgres:17-alpine
install -d -m 0750 /data/miyagi/redis /data/miyagi/backups
install -d -m 0755 /opt/edge/sites
install -d -m 0750 /opt/edge/certs

docker network inspect edge >/dev/null 2>&1 || docker network create edge >/dev/null
echo "✓ dirs + edge network"

# backup.sh uploads with the OCI CLI via the instance principal. panfleto's install put it at
# /usr/local/bin/oci; if it is missing, stop HERE — not at the first 04:45 backup.
command -v oci >/dev/null || { echo "✗ OCI CLI not found — install it (https://docs.oracle.com/iaas/Content/API/SDKDocs/cliinstall.htm) and re-run" >&2; exit 1; }
oci os ns get --auth instance_principal --query data --raw-output >/dev/null \
  || { echo "✗ the instance principal cannot reach Object Storage — check the panfleto dynamic group / policy" >&2; exit 1; }
echo "✓ OCI CLI + instance principal"

command -v rclone >/dev/null || { apt-get update -qq && apt-get install -y -qq rclone >/dev/null; }
echo "✓ rclone $(rclone version | head -1 | awk '{print $2}')"

install -m 0644 "$HERE"/systemd/*.service "$HERE"/systemd/*.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now miyagi-backup.timer miyagi-restore-drill.timer
echo "✓ backup + restore-drill timers enabled; cron timers installed but NOT enabled (cutover enables them)"
