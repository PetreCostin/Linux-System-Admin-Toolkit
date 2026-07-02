#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: disk_cleanup.sh [--path <dir>] [--days <n>] [--force]

Find files older than a threshold and optionally delete them.

Options:
  --path <dir>   Directory to inspect (default: /tmp)
  --days <n>     Delete files older than N days (default: 7)
  --force        Delete matches; without this flag the script only previews
  -h, --help     Show this help message
EOF
}

target_path="/tmp"
days_old=7
force_delete=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      target_path="${2:-}"
      shift 2
      ;;
    --days)
      days_old="${2:-}"
      shift 2
      ;;
    --force)
      force_delete=true
      shift
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

if [[ ! "$days_old" =~ ^[0-9]+$ ]]; then
  echo "Error: --days must be a non-negative integer." >&2
  exit 1
fi

if [[ ! -d "$target_path" ]]; then
  echo "Error: directory not found: $target_path" >&2
  exit 1
fi

mapfile -t matches < <(find "$target_path" -type f -mtime +"$days_old" 2>/dev/null | sort)

if [[ ${#matches[@]} -eq 0 ]]; then
  echo "No files older than $days_old days were found in $target_path."
  exit 0
fi

printf 'Files older than %s days in %s:\n' "$days_old" "$target_path"
printf ' - %s\n' "${matches[@]}"

if [[ "$force_delete" == true ]]; then
  find "$target_path" -type f -mtime +"$days_old" -delete 2>/dev/null
  echo "Deleted ${#matches[@]} files."
else
  echo "Dry run only. Re-run with --force to delete these files."
fi
