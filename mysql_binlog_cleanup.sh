#!/bin/bash

# MySQL Binary Log Cleanup Script
# This script helps resolve MySQL binary log storage issues

echo "=== MySQL Binary Log Cleanup Script ==="
echo "This script will help you clean up MySQL binary logs that are consuming disk space."
echo ""

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script should be run as root or with sudo privileges."
   echo "Usage: sudo bash mysql_binlog_cleanup.sh"
   exit 1
fi

# Function to check MySQL service status
check_mysql_status() {
    if systemctl is-active --quiet mysql; then
        echo "✓ MySQL service is running"
        return 0
    else
        echo "✗ MySQL service is not running"
        return 1
    fi
}

# Function to show current binlog usage
show_binlog_usage() {
    echo ""
    echo "=== Current Binary Log Usage ==="
    du -sh /var/lib/mysql/binlog.* 2>/dev/null | head -10
    echo "..."
    echo "Total binlog size:"
    du -sh /var/lib/mysql/binlog.* 2>/dev/null | awk '{sum+=$1} END {print sum "B"}'
}

# Function to backup important data (optional)
backup_binlog_index() {
    echo ""
    echo "=== Backing up binlog index ==="
    cp /var/lib/mysql/binlog.index /var/lib/mysql/binlog.index.backup.$(date +%Y%m%d_%H%M%S)
    echo "✓ Binlog index backed up"
}

# Function to purge old binary logs
purge_old_binlogs() {
    echo ""
    echo "=== Purging Old Binary Logs ==="
    
    # Get the current binlog file
    current_binlog=$(mysql -e "SHOW MASTER STATUS\G" | grep File | awk '{print $2}')
    echo "Current active binlog: $current_binlog"
    
    # Calculate date for logs older than 7 days
    purge_date=$(date -d '7 days ago' '+%Y-%m-%d %H:%M:%S')
    echo "Purging logs older than: $purge_date"
    
    # Purge binary logs older than 7 days
    mysql -e "PURGE BINARY LOGS BEFORE '$purge_date';"
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully purged old binary logs"
    else
        echo "✗ Failed to purge binary logs"
        return 1
    fi
}

# Function to configure binlog retention
configure_binlog_retention() {
    echo ""
    echo "=== Configuring Binary Log Retention ==="
    
    # Create MySQL configuration for binlog retention
    cat > /etc/mysql/conf.d/binlog_retention.cnf << EOF
[mysqld]
# Binary log retention settings
expire_logs_days = 7
max_binlog_size = 100M
binlog_cache_size = 32K
sync_binlog = 1

# Optional: Disable binary logging if not needed for replication
# log-bin = OFF
EOF

    echo "✓ Created binlog retention configuration"
    echo "  - Logs will expire after 7 days"
    echo "  - Maximum binlog size: 100MB"
    echo "  - Configuration saved to: /etc/mysql/conf.d/binlog_retention.cnf"
}

# Function to restart MySQL service
restart_mysql() {
    echo ""
    echo "=== Restarting MySQL Service ==="
    systemctl restart mysql
    
    if [ $? -eq 0 ]; then
        echo "✓ MySQL service restarted successfully"
    else
        echo "✗ Failed to restart MySQL service"
        return 1
    fi
}

# Function to show final status
show_final_status() {
    echo ""
    echo "=== Final Status ==="
    show_binlog_usage
    
    echo ""
    echo "=== Disk Usage After Cleanup ==="
    df -h /var/lib/mysql
}

# Main execution
main() {
    echo "Starting MySQL binlog cleanup process..."
    
    # Check MySQL status
    if ! check_mysql_status; then
        echo "Please start MySQL service first: sudo systemctl start mysql"
        exit 1
    fi
    
    # Show current usage
    show_binlog_usage
    
    # Ask for confirmation
    echo ""
    read -p "Do you want to proceed with cleanup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        exit 0
    fi
    
    # Backup binlog index
    backup_binlog_index
    
    # Purge old binary logs
    if ! purge_old_binlogs; then
        echo "Failed to purge logs. Exiting."
        exit 1
    fi
    
    # Configure retention policy
    configure_binlog_retention
    
    # Restart MySQL to apply new configuration
    if ! restart_mysql; then
        echo "Warning: MySQL restart failed. You may need to restart manually."
    fi
    
    # Show final status
    show_final_status
    
    echo ""
    echo "=== Cleanup Complete ==="
    echo "✓ Old binary logs have been purged"
    echo "✓ Retention policy configured (7 days)"
    echo "✓ MySQL service restarted"
    echo ""
    echo "To monitor future binlog usage, run:"
    echo "  sudo du -sh /var/lib/mysql/binlog.*"
    echo ""
    echo "To manually purge logs in the future:"
    echo "  mysql -e \"PURGE BINARY LOGS BEFORE '$(date -d '7 days ago' '+%Y-%m-%d %H:%M:%S')';\""
}

# Run main function
main "$@"