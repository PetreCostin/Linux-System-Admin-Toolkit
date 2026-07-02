#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: backup.sh --source <path> [--destination <dir>] [--name <prefix>]

Create a compressed tar.gz backup of a file or directory.

Options:
  --source <path>        File or directory to archive
  --destination <dir>    Output directory (default: ./backups)
  --name <prefix>        Archive name prefix (default: backup)
  -h, --help             Show this help message
EOF
}

source_path=""
destination_dir="./backups"
archive_prefix="backup"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      source_path="${2:-}"
      shift 2
      ;;
    --destination)
      destination_dir="${2:-}"
      shift 2
      ;;
    --name)
      archive_prefix="${2:-}"
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

if [[ -z "$source_path" ]]; then
  echo "Error: --source is required." >&2
  usage >&2
  exit 1
fi

if [[ ! -e "$source_path" ]]; then
  echo "Error: source path does not exist: $source_path" >&2
  exit 1
fi

mkdir -p "$destination_dir"

timestamp="$(date +%Y%m%d_%H%M%S)"
archive_path="${destination_dir%/}/${archive_prefix}_${timestamp}.tar.gz"
parent_dir="$(dirname "$source_path")"
item_name="$(basename "$source_path")"

tar -czf "$archive_path" -C "$parent_dir" "$item_name"

echo "Backup created: $archive_path"
