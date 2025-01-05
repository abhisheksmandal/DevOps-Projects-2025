#!/bin/bash

# Log Cleanup Script
# Description: Manages and rotates system log files
# Author: Abhishek Mandal
# Date: January 5, 2025

# Default values
DEFAULT_DAYS=30
LOG_DIR="/var/log"
SCRIPT_LOG="/var/log/log_cleanup.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$SCRIPT_LOG" 2>/dev/null
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

# Function to cleanup old log files
cleanup_logs() {
    local days=$1
    local current_date=$(date +%s)
    local deleted_count=0
    local total_size=0

    log_message "Starting log cleanup for files older than $days days"

    # Find and process log files
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            file_date=$(stat -c %Y "$file")
            file_age=$(((current_date - file_date) / 86400))

            if [ "$file_age" -gt "$days" ]; then
                file_size=$(stat -c %s "$file")
                total_size=$((total_size + file_size))

                # Compress the log file
                if gzip "$file"; then
                    deleted_count=$((deleted_count + 1))
                    log_message "Compressed: $file"
                else
                    log_message "Failed to compress: $file"
                fi
            fi
        fi
    done < <(find "$LOG_DIR" -type f -name "*.log" 2>/dev/null)

    log_message "Cleanup completed. Compressed $deleted_count files"
    log_message "Total space saved: $(numfmt --to=iec-i --suffix=B $total_size)"
}

# Function to rotate active log files
rotate_logs() {
    log_message "Starting log rotation"

    if command -v logrotate &>/dev/null; then
        logrotate -f /etc/logrotate.conf >>"$SCRIPT_LOG" 2>&1
        log_message "Log rotation completed"
    else
        log_message "logrotate not found. Skipping rotation"
    fi
}

# Main execution
main() {
    check_root

    # Create script log if it doesn't exist
    if ! touch "$SCRIPT_LOG" 2>/dev/null; then
        echo "Error: Unable to write to $SCRIPT_LOG"
        exit 1
    fi

    # Get number of days from argument or use default
    days=${1:-$DEFAULT_DAYS}

    # Validate input: Ensure it's a positive integer
    if ! [[ "$days" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Please provide a valid positive integer for the number of days"
        exit 1
    fi

    log_message "=== Starting Log Cleanup Script ==="

    # Perform log cleanup and rotation
    cleanup_logs "$days"
    rotate_logs

    log_message "=== Log Cleanup Script Completed ==="
}

# Run main function
main "$@"
