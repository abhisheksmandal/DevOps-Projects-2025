#!/bin/bash

# Backup Script
# Description: Creates compressed backups of specified directories
# Author: Abhishek Mandal
# Date: January 5, 2025

# Default values
DEFAULT_BACKUP_NAME="backup"
DEFAULT_SOURCE_DIR="$HOME"
DEFAULT_BACKUP_DIR="/var/backups"
BACKUP_LOG="/var/log/backup.log"
DATE=$(date +%Y%m%d_%H%M%S)
DISK_SPACE_BUFFER=10 # Percentage

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$BACKUP_LOG"
}

# Function to check available disk space
check_disk_space() {
    local source_size=$(du -sb "$1" | cut -f1)
    local backup_space=$(df -B1 "$2" | awk 'NR==2 {print $4}')

    # Add buffer to source size
    local required_space=$(($source_size * (100 + $DISK_SPACE_BUFFER) / 100))

    if [ $backup_space -lt $required_space ]; then
        return 1
    fi
    return 0
}

# Function to create backup
create_backup() {
    local backup_name="$1"
    local source_dir="$2"
    local backup_dir="$3"
    local backup_file="${backup_name}_${DATE}.tar.gz"
    local full_path="$backup_dir/$backup_file"

    log_message "Starting backup of $source_dir to $full_path"

    # Check if source directory exists
    if [ ! -d "$source_dir" ]; then
        log_message "Error: Source directory $source_dir does not exist"
        return 1
    fi

    # Create backup directory if it doesn't exist
    if ! mkdir -p "$backup_dir"; then
        log_message "Error: Failed to create backup directory $backup_dir"
        return 1
    fi

    # Check disk space
    if ! check_disk_space "$source_dir" "$backup_dir"; then
        log_message "Error: Insufficient disk space for backup"
        return 1
    fi

    # Create backup
    if tar -czf "$full_path" -C "$(dirname "$source_dir")" "$(basename "$source_dir")" 2>>"$BACKUP_LOG"; then
        log_message "Backup created successfully: $backup_file"

        # Calculate and log backup size
        local backup_size=$(du -h "$full_path" | cut -f1)
        log_message "Backup size: $backup_size"

        return 0
    else
        log_message "Error: Backup creation failed"
        return 1
    fi
}

# Function to cleanup old backups
cleanup_old_backups() {
    local backup_dir="$1"
    local max_backups=5

    log_message "Checking for old backups to remove"

    # Get list of backups sorted by date
    local old_backups=$(ls -t "$backup_dir"/backup_*.tar.gz 2>/dev/null | tail -n +$((max_backups + 1)))

    if [ -z "$old_backups" ]; then
        log_message "No old backups to remove"
        return 0
    fi

    echo "$old_backups" | while read backup; do
        if rm "$backup"; then
            log_message "Removed old backup: $backup"
        else
            log_message "Error removing old backup: $backup"
        fi
    done
}

# Main execution
main() {
    # Get backup name, source directory, and backup directory from arguments or use defaults
    local backup_name=${1:-$DEFAULT_BACKUP_NAME}
    local source_dir=${2:-$DEFAULT_SOURCE_DIR}
    local backup_dir=${3:-$DEFAULT_BACKUP_DIR}

    # Create log file if it doesn't exist
    if ! touch "$BACKUP_LOG"; then
        echo "Error: Unable to create or access log file $BACKUP_LOG"
        exit 1
    fi

    log_message "=== Starting Backup Script ==="

    # Create backup
    if create_backup "$backup_name" "$source_dir" "$backup_dir"; then
        cleanup_old_backups "$backup_dir"
        log_message "Backup process completed successfully"
    else
        log_message "Backup process failed"
        exit 1
    fi

    log_message "=== Backup Script Completed ==="
    exit 0
}

# Run main function
main "$@"
