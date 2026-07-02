# Linux-System-Admin-Toolkit

Linux System Admin Toolkit is a Bash-based automation project featuring scripts for system monitoring, backups, user management, log analysis, disk cleanup, firewall checks, and service management.

## Scripts

- `backup.sh` — create compressed backups of files or directories
- `disk_cleanup.sh` — preview or delete old files from a target directory
- `firewall_check.sh` — inspect the active firewall configuration
- `log_monitor.sh` — tail and filter logs
- `service_manager.sh` — manage services with `systemctl`
- `system_report.sh` — print a compact system health report
- `user_manager.sh` — list, add, or delete local users
- `install.sh` — install the toolkit scripts into a target directory

## Usage

```bash
chmod +x *.sh
./system_report.sh
./backup.sh --source /etc --destination ./backups
./log_monitor.sh --file /var/log/syslog --pattern error
./disk_cleanup.sh --path /tmp --days 14 --force
./install.sh --prefix "$HOME/.local/bin"
```

Some actions require elevated privileges, such as managing users or system services.
