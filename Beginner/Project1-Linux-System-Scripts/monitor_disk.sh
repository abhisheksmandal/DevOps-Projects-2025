#!/bin/bash

# Disk Space Monitor Script
# Description: Monitors disk space usage and sends alerts
# Author: Abhishek Mandal
# Date: January 5, 2025

# Default values
DEFAULT_THRESHOLD=90
LOG_FILE="/var/log/disk_monitor.log"
EMAIL_TO="admin@example.com"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

# Function to send email alert
send_alert() {
    local message="$1"
    local subject="Disk Space Alert - $(hostname)"

    if command -v mail &>/dev/null; then
        echo "$message" | mail -s "$subject" "$EMAIL_TO"
        log_message "Alert email sent to $EMAIL_TO"
    else
        log_message "mail command not found. Alert not sent"
    fi
}

# Function to check disk space
check_disk_space() {
    local threshold=$1
    local alert_needed=0
    local alert_message="Disk Space Alert:\n\n"

    log_message "Checking disk space usage (threshold: ${threshold}%)"

    # Get disk usage for all mounted filesystems
    while read -r line; do
        # Skip header and non-local filesystems
        if [[ $line =~ ^Filesystem|tmpfs|cdrom|udev ]]; then
            continue
        fi

        # Extract filesystem information
        local filesystem=$(echo "$line" | awk '{print $1}')
        local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        local mounted=$(echo "$line" | awk '{print $6}')

        # Log current usage
        log_message "Filesystem: $filesystem, Usage: $usage%, Mount: $mounted"

        # Check if usage exceeds threshold
        if [ "$usage" -gt "$threshold" ]; then
            alert_message+="Filesystem: $filesystem\n"
            alert_message+="Mounted on: $mounted\n"
            alert_message+="Current usage: $usage%\n\n"
            alert_needed=1
        fi
    done < <(df -h)

    # Send alert if needed
    if [ $alert_needed -eq 1 ]; then
        send_alert "$alert_message"
        return 1
    fi

    return 0
}

# Function to display disk usage report
generate_report() {
    local report="Disk Usage Report - $(date '+%Y-%m-%d %H:%M:%S')\n\n"

    # Add system information
    report+="System: $(hostname)\n"
    report+="Kernel: $(uname -r)\n\n"

    # Add disk usage information
    report+="Filesystem Usage:\n"
    df -h | grep -v '^Filesystem' | while read -r line; do
        local filesystem=$(echo "$line" | awk '{print $1}')
        local size=$(echo "$line" | awk '{print $2}')
        local used=$(echo "$line" | awk '{print $3}')
        local avail=$(echo "$line" | awk '{print $4}')
        local usage=$(echo "$line" | awk '{print $5}')
        local mounted=$(echo "$line" | awk '{print $6}')

        report+="$filesystem ($mounted):\n"
        report+="  Size: $size, Used: $used, Available: $avail, Usage: $usage\n"
    done

    echo -e "$report"
}

# Main execution
main() {
    # Get threshold from argument or use default
    local threshold=${1:-$DEFAULT_THRESHOLD}

    # Validate threshold
    if ! [[ "$threshold" =~ ^[0-9]+$ ]] || [ "$threshold" -lt 0 ] || [ "$threshold" -gt 100 ]; then
        echo "Error: Please provide a valid threshold percentage (0-100)"
        exit 1
    fi

    # Create log file if it doesn't exist
    touch "$LOG_FILE"

    log_message "=== Starting Disk Space Monitor ==="

    # Check disk space
    if check_disk_space "$threshold"; then
        log_message "All filesystems below threshold"
    else
        log_message "Warning: Some filesystems exceeded threshold"
    fi

    # Generate and log report
    generate_report >>"$LOG_FILE"

    log_message "=== Disk Space Monitor Completed ==="

    # Optionally send an "everything is OK" email if no alert triggered
    if check_disk_space "$threshold"; then
        send_alert "Disk usage is under control on $(hostname)"
    fi
}

# Run main function
main "$@"
