#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: service_manager.sh <status|start|stop|restart> <service>

Manage services with systemctl.
EOF
}

if [[ $# -ne 2 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  usage
  [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]] && exit 0
  exit 1
fi

action="$1"
service_name="$2"

case "$action" in
  status|start|stop|restart)
    ;;
  *)
    echo "Unsupported action: $action" >&2
    usage >&2
    exit 1
    ;;
esac

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemctl is not available on this system." >&2
  exit 1
fi

systemctl "$action" "$service_name"
