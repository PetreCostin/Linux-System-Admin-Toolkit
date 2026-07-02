#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: log_monitor.sh --file <path> [--pattern <text>] [--lines <n>] [--follow]

Inspect logs with optional filtering and follow mode.

Options:
  --file <path>     Log file to read
  --pattern <text>  Filter lines containing the text
  --lines <n>       Number of trailing lines to read (default: 20)
  --follow          Continue following the file after printing output
  -h, --help        Show this help message
EOF
}

log_file=""
pattern=""
line_count=20
follow_mode=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      log_file="${2:-}"
      shift 2
      ;;
    --pattern)
      pattern="${2:-}"
      shift 2
      ;;
    --lines)
      line_count="${2:-}"
      shift 2
      ;;
    --follow)
      follow_mode=true
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

if [[ -z "$log_file" ]]; then
  echo "Error: --file is required." >&2
  usage >&2
  exit 1
fi

if [[ ! "$line_count" =~ ^[0-9]+$ ]]; then
  echo "Error: --lines must be a non-negative integer." >&2
  exit 1
fi

if [[ ! -f "$log_file" ]]; then
  echo "Error: log file not found: $log_file" >&2
  exit 1
fi

tail_args=(-n "$line_count")
if [[ "$follow_mode" == true ]]; then
  tail_args+=(-f)
fi

if [[ -n "$pattern" ]]; then
  tail "${tail_args[@]}" "$log_file" | grep --line-buffered -F "$pattern"
else
  tail "${tail_args[@]}" "$log_file"
fi
