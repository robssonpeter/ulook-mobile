# MySQL Binary Log Storage Issue - Solution Guide

## Problem Description

Your Ubuntu server is experiencing a storage issue due to MySQL binary logs consuming excessive disk space. The logs shown in your output indicate hundreds of binary log files (binlog.005481 through binlog.006649), each approximately 101MB in size, totaling several gigabytes of storage.

## Immediate Solution

### Option 1: Use the Automated Script

1. **Download and run the cleanup script:**
   ```bash
   # Make the script executable
   chmod +x mysql_binlog_cleanup.sh
   
   # Run the script with sudo privileges
   sudo bash mysql_binlog_cleanup.sh
   ```

### Option 2: Manual Cleanup Commands

If you prefer to run commands manually:

1. **Check current binlog usage:**
   ```bash
   sudo du -sh /var/lib/mysql/binlog.*
   ```

2. **Connect to MySQL and check current status:**
   ```bash
   mysql -u root -p
   ```
   
   Then run these SQL commands:
   ```sql
   SHOW MASTER STATUS;
   SHOW BINARY LOGS;
   ```

3. **Purge old binary logs (keep last 7 days):**
   ```sql
   PURGE BINARY LOGS BEFORE DATE(NOW() - INTERVAL 7 DAY);
   ```
   
   Or purge logs before a specific date:
   ```sql
   PURGE BINARY LOGS BEFORE '2024-05-15 00:00:00';
   ```

4. **Exit MySQL:**
   ```sql
   EXIT;
   ```

## Long-term Configuration

### Configure Automatic Log Rotation

1. **Create MySQL configuration file:**
   ```bash
   sudo nano /etc/mysql/conf.d/binlog_retention.cnf
   ```

2. **Add the following configuration:**
   ```ini
   [mysqld]
   # Binary log retention settings
   expire_logs_days = 7
   max_binlog_size = 100M
   binlog_cache_size = 32K
   sync_binlog = 1
   
   # Optional: Disable binary logging if not needed for replication
   # log-bin = OFF
   ```

3. **Restart MySQL service:**
   ```bash
   sudo systemctl restart mysql
   ```

### Alternative: Disable Binary Logging (if not needed)

If you don't need binary logging for replication or point-in-time recovery:

1. **Edit MySQL configuration:**
   ```bash
   sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
   ```

2. **Comment out or remove the log-bin line:**
   ```ini
   # log-bin = /var/lib/mysql/binlog
   ```

3. **Restart MySQL:**
   ```bash
   sudo systemctl restart mysql
   ```

## Monitoring and Maintenance

### Regular Monitoring Commands

1. **Check disk usage:**
   ```bash
   df -h /var/lib/mysql
   ```

2. **Monitor binlog files:**
   ```bash
   sudo ls -lh /var/lib/mysql/binlog.* | tail -10
   ```

3. **Check MySQL binlog status:**
   ```sql
   SHOW BINARY LOGS;
   SHOW MASTER STATUS;
   ```

### Automated Cleanup Cron Job

Create a cron job to automatically purge old logs:

1. **Edit crontab:**
   ```bash
   sudo crontab -e
   ```

2. **Add weekly cleanup (runs every Sunday at 2 AM):**
   ```bash
   0 2 * * 0 mysql -e "PURGE BINARY LOGS BEFORE DATE(NOW() - INTERVAL 7 DAY);"
   ```

## Safety Considerations

### Before Cleanup:
- ✅ Ensure you have recent database backups
- ✅ Verify that binary logs are not needed for replication
- ✅ Check if point-in-time recovery is required
- ✅ Test the cleanup process on a non-production server first

### During Cleanup:
- ⚠️ Never delete the currently active binlog file
- ⚠️ Always use `PURGE BINARY LOGS` command instead of `rm`
- ⚠️ Keep at least 1-2 days of recent logs for safety

## Understanding Binary Logs

### What are Binary Logs?
- Record all changes to the database
- Used for replication and point-in-time recovery
- Created automatically when binary logging is enabled

### When to Keep Binary Logs:
- ✅ Running MySQL replication (master-slave setup)
- ✅ Need point-in-time recovery capabilities
- ✅ Compliance requirements for audit trails

### When to Disable Binary Logs:
- ✅ Single server setup with no replication
- ✅ Regular full backups are sufficient
- ✅ Storage space is limited
- ✅ Performance is more important than recovery options

## Troubleshooting

### Common Issues:

1. **Permission denied:**
   ```bash
   sudo chown mysql:mysql /var/lib/mysql/binlog.*
   ```

2. **MySQL won't start after configuration change:**
   ```bash
   sudo systemctl status mysql
   sudo journalctl -u mysql -f
   ```

3. **Cannot purge logs:**
   - Check if logs are being used by replication
   - Ensure MySQL user has SUPER privileges

### Recovery Steps:
If something goes wrong:
1. Stop MySQL: `sudo systemctl stop mysql`
2. Restore binlog.index from backup
3. Start MySQL: `sudo systemctl start mysql`

## Expected Results

After running the cleanup:
- **Immediate:** Several GB of disk space freed
- **Long-term:** Automatic log rotation prevents future buildup
- **Performance:** Reduced I/O overhead from excessive log files

## Next Steps

1. **Immediate:** Run the cleanup script or manual commands
2. **Configure:** Set up automatic log rotation
3. **Monitor:** Check disk usage regularly
4. **Backup:** Ensure regular database backups are in place
5. **Document:** Record the configuration for future reference

---

**Note:** This solution addresses a MySQL server administration issue and is not related to the Flutter application in this repository. The binlog cleanup should be performed on your Ubuntu server where MySQL is running.