# Linux-System-Admin-Toolkit

Linux System Admin Toolkit is a Bash-based automation project featuring scripts for system monitoring, backups, user management, log analysis, disk cleanup, firewall checks, and service management. It showcases Linux administration, shell scripting, automation, and security best practices.

## Usage

Run the toolkit with one of the supported subcommands:

```bash
./admin_toolkit.sh help
./admin_toolkit.sh monitor
./admin_toolkit.sh backup /path/to/source /path/to/backup-dir
./admin_toolkit.sh list-users
./admin_toolkit.sh user-info root
./admin_toolkit.sh analyze-logs /var/log/syslog 20
./admin_toolkit.sh disk-usage /var/log
./admin_toolkit.sh cleanup-temp /tmp 7
./admin_toolkit.sh firewall-status
./admin_toolkit.sh service-status ssh
./admin_toolkit.sh failed-services
```

## Features

- **System monitoring:** host, kernel, uptime, load, memory, and disk summary
- **Backups:** timestamped `tar.gz` archive creation for a chosen file or directory
- **User management:** local user listing and per-user account details
- **Log analysis:** quick scan for common warning and error patterns
- **Disk cleanup:** dry-run cleanup candidate discovery for old temporary files
- **Firewall checks:** status output for `ufw`, `firewalld`, or `iptables`
- **Service management:** service status lookup and failed service reporting

## Notes

- The toolkit uses safe defaults such as dry-run cleanup previews.
- Some commands may require elevated privileges depending on the target paths or services.
