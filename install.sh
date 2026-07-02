#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install.sh [--prefix <dir>]

Install toolkit scripts into a target directory.

Options:
  --prefix <dir>  Installation directory (default: /usr/local/bin)
  -h, --help      Show this help message
EOF
}

prefix="/usr/local/bin"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scripts=(
  backup.sh
  disk_cleanup.sh
  firewall_check.sh
  log_monitor.sh
  service_manager.sh
  system_report.sh
  user_manager.sh
)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      prefix="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

mkdir -p "$prefix"

for script in "${scripts[@]}"; do
  install -m 0755 "${script_dir}/${script}" "${prefix}/${script}"
done

echo "Installed ${#scripts[@]} scripts to $prefix"
