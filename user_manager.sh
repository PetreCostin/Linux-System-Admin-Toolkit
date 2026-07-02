#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: user_manager.sh <list|add|delete> [username]

Manage local Linux users. The add and delete actions require root privileges.
EOF
}

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "This action requires root privileges." >&2
    exit 1
  fi
}

if [[ $# -lt 1 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  usage
  [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]] && exit 0
  exit 1
fi

action="$1"
username="${2:-}"

case "$action" in
  list)
    cut -d: -f1 /etc/passwd
    ;;
  add)
    [[ -n "$username" ]] || { echo "Username is required for add." >&2; exit 1; }
    require_root
    useradd -m "$username"
    echo "User created: $username"
    ;;
  delete)
    [[ -n "$username" ]] || { echo "Username is required for delete." >&2; exit 1; }
    require_root
    userdel -r "$username"
    echo "User deleted: $username"
    ;;
  *)
    echo "Unsupported action: $action" >&2
    usage >&2
    exit 1
    ;;
esac
