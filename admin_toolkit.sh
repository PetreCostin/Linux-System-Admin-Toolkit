#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <command> [arguments]

Commands:
  help                              Show this help message
  monitor                           Print a system summary
  backup <source> [destination]     Create a timestamped tar.gz backup
  list-users                        List local user accounts
  user-info <username>              Show account details for a user
  analyze-logs <file> [limit]       Show recent warning/error log entries
  disk-usage [path]                 Show filesystem and top-level path usage
  cleanup-temp [path] [days]        Preview old files for cleanup (dry-run)
  cleanup-temp [path] [days] --apply Remove old files for cleanup
  firewall-status                   Show firewall status
  service-status <service>          Show a service status with systemctl
  failed-services                   List failed services with systemctl
EOF
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_readable_file() {
  local path="$1"
  if [[ ! -r "$path" || ! -f "$path" ]]; then
    echo "Error: '$path' is not a readable file." >&2
    exit 1
  fi
}

require_directory() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    echo "Error: '$path' is not a directory." >&2
    exit 1
  fi
}

monitor_system() {
  echo "Hostname: $(hostname)"
  echo "Date: $(date)"
  echo "Kernel: $(uname -sr)"
  echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
  if [[ -r /proc/loadavg ]]; then
    echo "Load Average: $(cut -d' ' -f1-3 /proc/loadavg)"
  fi
  echo
  echo "Memory:"
  if command_exists free; then
    free -h
  else
    awk '/Mem(Total|Free|Available)/ {print}' /proc/meminfo
  fi
  echo
  echo "Disk:"
  df -h /
}

create_backup() {
  local source="$1"
  local destination="${2:-.}"
  local timestamp archive_name archive_path source_dir source_name

  if [[ ! -e "$source" ]]; then
    echo "Error: source '$source' does not exist." >&2
    exit 1
  fi

  mkdir -p "$destination"
  require_directory "$destination"

  timestamp="$(date +%Y%m%d-%H%M%S)"
  source_dir="$(dirname "$source")"
  source_name="$(basename "$source")"
  archive_name="${source_name}-backup-${timestamp}.tar.gz"
  archive_path="${destination%/}/$archive_name"

  tar -czf "$archive_path" -C "$source_dir" "$source_name"
  echo "Backup created: $archive_path"
}

list_users() {
  getent passwd | cut -d: -f1 | sort
}

show_user_info() {
  local username="$1"
  local entry

  entry="$(getent passwd "$username" || true)"
  if [[ -z "$entry" ]]; then
    echo "Error: user '$username' was not found." >&2
    exit 1
  fi

  IFS=: read -r name _ uid gid gecos home shell <<<"$entry"
  echo "Username: $name"
  echo "UID: $uid"
  echo "GID: $gid"
  echo "Description: ${gecos:-N/A}"
  echo "Home: $home"
  echo "Shell: $shell"
  echo "Groups: $(id -nG "$username")"
}

analyze_logs() {
  local logfile="$1"
  local limit="${2:-20}"

  require_readable_file "$logfile"

  if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
    echo "Error: limit must be a non-negative integer." >&2
    exit 1
  fi

  grep -Ein 'error|warn|fail|critical|denied' "$logfile" | tail -n "$limit" || \
    echo "No matching warning or error patterns found in '$logfile'."
}

show_disk_usage() {
  local target="${1:-.}"

  require_directory "$target"
  df -h "$target"
  echo
  echo "Top-level usage in $target:"
  if find "$target" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
    du -sh "$target"/* 2>/dev/null | sort -h
  else
    echo "No entries found."
  fi
}

cleanup_temp() {
  local target="${1:-/tmp}"
  local days="${2:-7}"
  local apply="${3:-}"

  require_directory "$target"

  if [[ "$target" == "/" || "$target" == "." ]]; then
    echo "Error: refusing to operate on unsafe path '$target'." >&2
    exit 1
  fi

  if ! [[ "$days" =~ ^[0-9]+$ ]]; then
    echo "Error: days must be a non-negative integer." >&2
    exit 1
  fi

  if [[ -n "$apply" && "$apply" != "--apply" ]]; then
    echo "Error: the optional third argument must be --apply." >&2
    exit 1
  fi

  echo "Scanning '$target' for entries older than $days day(s)..."
  if [[ "$apply" == "--apply" ]]; then
    find "$target" -mindepth 1 -mtime +"$days" -print -exec rm -rf -- {} + 2>/dev/null
    echo "Cleanup complete."
  else
    echo "Dry run only. Re-run with --apply to remove files."
    find "$target" -mindepth 1 -mtime +"$days" -print 2>/dev/null
  fi
}

show_firewall_status() {
  if command_exists ufw; then
    ufw status
  elif command_exists firewall-cmd; then
    firewall-cmd --state
    firewall-cmd --list-all
  elif command_exists iptables; then
    iptables -L -n
  else
    echo "No supported firewall tools found (ufw, firewall-cmd, iptables)." >&2
    exit 1
  fi
}

show_service_status() {
  local service="$1"

  if ! command_exists systemctl; then
    echo "Error: systemctl is not available on this host." >&2
    exit 1
  fi

  systemctl status "$service" --no-pager
}

list_failed_services() {
  if ! command_exists systemctl; then
    echo "Error: systemctl is not available on this host." >&2
    exit 1
  fi

  systemctl --failed --type=service --no-pager
}

main() {
  local command="${1:-help}"

  case "$command" in
    help|-h|--help)
      usage
      ;;
    monitor)
      monitor_system
      ;;
    backup)
      if [[ $# -lt 2 ]]; then
        echo "Error: backup requires a source path." >&2
        usage
        exit 1
      fi
      create_backup "$2" "${3:-.}"
      ;;
    list-users)
      list_users
      ;;
    user-info)
      if [[ $# -lt 2 ]]; then
        echo "Error: user-info requires a username." >&2
        usage
        exit 1
      fi
      show_user_info "$2"
      ;;
    analyze-logs)
      if [[ $# -lt 2 ]]; then
        echo "Error: analyze-logs requires a log file path." >&2
        usage
        exit 1
      fi
      analyze_logs "$2" "${3:-20}"
      ;;
    disk-usage)
      show_disk_usage "${2:-.}"
      ;;
    cleanup-temp)
      cleanup_temp "${2:-/tmp}" "${3:-7}" "${4:-}"
      ;;
    firewall-status)
      show_firewall_status
      ;;
    service-status)
      if [[ $# -lt 2 ]]; then
        echo "Error: service-status requires a service name." >&2
        usage
        exit 1
      fi
      show_service_status "$2"
      ;;
    failed-services)
      list_failed_services
      ;;
    *)
      echo "Error: unknown command '$command'." >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
