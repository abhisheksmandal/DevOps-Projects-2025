#!/bin/bash

# System Update Script
# Description: Automatically updates system packages and performs cleanup
# Author: Abhishek Mandal
# Date: January 5, 2025

# Log file setup
LOG_FILE="/var/log/system_update.log"
ERROR_LOG="/var/log/system_update_error.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

# Function to perform system update
update_system() {
    log_message "Starting system update"

    # Update package list
    log_message "Updating package list"
    if apt-get update >>"$LOG_FILE" 2>>"$ERROR_LOG"; then
        log_message "Package list update successful"
    else
        log_message "Error updating package list. See $ERROR_LOG for details"
        return 1
    fi

    # Upgrade packages
    log_message "Upgrading packages"
    if DEBIAN_FRONTEND=noninteractive apt-get -y upgrade >>"$LOG_FILE" 2>>"$ERROR_LOG"; then
        log_message "Package upgrade successful"
    else
        log_message "Error upgrading packages. See $ERROR_LOG for details"
        return 1
    fi

    return 0
}

# Function to clean up package cache
cleanup_packages() {
    log_message "Starting package cleanup"

    # Remove unnecessary packages
    if apt-get -y autoremove >>"$LOG_FILE" 2>>"$ERROR_LOG"; then
        log_message "Unnecessary packages removed"
    else
        log_message "Error removing unnecessary packages. See $ERROR_LOG for details"
        return 1
    fi

    # Clean package cache
    if apt-get -y clean >>"$LOG_FILE" 2>>"$ERROR_LOG"; then
        log_message "Package cache cleaned"
    else
        log_message "Error cleaning package cache. See $ERROR_LOG for details"
        return 1
    fi

    log_message "Package cleanup completed successfully"
    return 0
}

# Main execution
main() {
    check_root

    # Create log files if they don't exist
    if ! touch "$LOG_FILE" "$ERROR_LOG"; then
        echo "Error: Unable to create log files. Check permissions."
        exit 1
    fi

    log_message "=== Starting System Update Script ==="

    # Perform system update
    if update_system; then
        if cleanup_packages; then
            log_message "System update and cleanup completed successfully"
        else
            log_message "System update completed, but cleanup encountered errors. See $ERROR_LOG for details"
            exit 1
        fi
    else
        log_message "System update failed. See $ERROR_LOG for details"
        exit 1
    fi

    log_message "=== System Update Script Completed ==="
}

# Run main function
main
