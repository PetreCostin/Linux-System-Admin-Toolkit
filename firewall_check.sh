#!/usr/bin/env bash
set -euo pipefail

print_ufw_status() {
  echo "[ufw]"
  ufw status verbose
}

print_firewalld_status() {
  echo "[firewalld]"
  firewall-cmd --state
  firewall-cmd --list-all
}

print_iptables_status() {
  echo "[iptables]"
  iptables -L -n --line-numbers
}

usage() {
  cat <<'EOF'
Usage: firewall_check.sh

Display the active firewall configuration by checking ufw, firewalld,
and iptables in that order.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if command -v ufw >/dev/null 2>&1; then
  print_ufw_status
elif command -v firewall-cmd >/dev/null 2>&1; then
  print_firewalld_status
elif command -v iptables >/dev/null 2>&1; then
  print_iptables_status
else
  echo "No supported firewall tooling found (ufw, firewalld, iptables)." >&2
  exit 1
fi
