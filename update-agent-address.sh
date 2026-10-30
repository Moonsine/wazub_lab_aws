#!/usr/bin/env bash
# Point a Linux Wazuh agent at a new server address and restart it.
# Usage: sudo ./update-agent-address.sh <NEW_SERVER_IP>
set -euo pipefail

CONF=/var/ossec/etc/ossec.conf
NEW_IP="${1:-}"

if [[ -z "$NEW_IP" ]]; then
  echo "Usage: sudo $0 <NEW_SERVER_IP>" >&2
  exit 1
fi
if [[ $EUID -ne 0 ]]; then
  echo "Run as root (use sudo)." >&2
  exit 1
fi
if [[ ! -f "$CONF" ]]; then
  echo "$CONF not found. Is the Wazuh agent installed on this machine?" >&2
  exit 1
fi
if ! [[ "$NEW_IP" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
  echo "'$NEW_IP' does not look like an IPv4 address." >&2
  exit 1
fi

cp "$CONF" "${CONF}.bak"
sed -i "s#<address>.*</address>#<address>${NEW_IP}</address>#" "$CONF"
grep -n "<address>" "$CONF"
systemctl restart wazuh-agent
echo "Agent restarted. Check: tail -20 /var/ossec/logs/ossec.log"
