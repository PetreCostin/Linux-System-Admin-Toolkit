#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: system_report.sh

Print a compact system health report.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

echo "System Report"
echo "============="
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -srmo)"
echo "Uptime: $(uptime -p)"
echo "Load: $(cut -d' ' -f1-3 /proc/loadavg)"
echo
echo "Memory Usage:"
free -h
echo
echo "Disk Usage:"
df -h /
echo
echo "Logged-in Users:"
who
echo
echo "Network Addresses:"
hostname -I
