#!/bin/bash

# System Information Script
# Description: Displays comprehensive system information
# Author: Abhishek Mandal
# Date: January 5, 2025

# Function to get CPU information
get_cpu_info() {
    echo "=== CPU Information ==="
    local processor=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | sed 's/^[ \t]*//')
    local cpu_cores=$(nproc)
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    echo "Processor: $processor"
    echo "CPU Cores: $cpu_cores"
    echo "CPU Usage: $cpu_usage%"
    echo
}

# Function to get memory information
get_memory_info() {
    echo "=== Memory Information ==="
    free -h | awk '
        /^Mem:/ {
            printf "Total Memory: %s\n", $2
            printf "Used Memory: %s\n", $3
            printf "Free Memory: %s\n", $4
            printf "Shared Memory: %s\n", $5
            printf "Buffer/Cache: %s\n", $6
            printf "Available Memory: %s\n", $7
        }'
    echo
}

# Function to get disk information
get_disk_info() {
    echo "=== Disk Information ==="
    df -h | grep -v '^Filesystem' | while read -r line; do
        local filesystem=$(echo "$line" | awk '{print $1}')
        local size=$(echo "$line" | awk '{print $2}')
        local used=$(echo "$line" | awk '{print $3}')
        local avail=$(echo "$line" | awk '{print $4}')
        local usage=$(echo "$line" | awk '{print $5}')
        local mounted=$(echo "$line" | awk '{print $6}')

        echo "Filesystem: $filesystem"
        echo "  Mounted on: $mounted"
        echo "  Size: $size"
        echo "  Used: $used"
        echo "  Available: $avail"
        echo "  Usage: $usage"
    done
    echo
}

# Function to get network information
get_network_info() {
    echo "=== Network Information ==="
    echo "Hostname: $(hostname)"
    echo "IP Addresses:"
    ip -4 addr show | grep inet | awk '{print "  " $2}'
    echo
    echo "Network Interfaces:"
    ip link show | grep -v "^\s" | cut -d: -f2 | sed 's/^[ \t]*//' | while read -r interface; do
        echo "  $interface"
    done
    echo
}

# Function to get system load information
get_system_load() {
    echo "=== System Load ==="
    local load=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//')
    echo "Load Average (1,5,15 min): $load"
    echo "Uptime: $(uptime -p)"
    echo
}

# Function to get system version information
get_system_version() {
    echo "=== System Version ==="
    local os_version=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
    echo "OS: $os_version"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo
}

# Function to get running processes information
get_process_info() {
    echo "=== Process Information ==="
    local total_processes=$(ps aux | wc -l)
    echo "Total Processes: $total_processes"
    echo
    echo "Top 5 CPU-Consuming Processes:"
    ps aux --sort=-%cpu | head -6 | awk 'NR>1 {printf "  %s (%s%%)\n", $11, $3}'
    echo
    echo "Top 5 Memory-Consuming Processes:"
    ps aux --sort=-%mem | head -6 | awk 'NR>1 {printf "  %s (%s%%)\n", $11, $4}'
    echo
}

# Main execution
main() {
    echo "System Information Report - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=================================================="
    echo

    get_system_version
    get_cpu_info
    get_memory_info
    get_disk_info
    get_network_info
    get_system_load
    get_process_info

    echo "End of Report"
}

# Run main function
main
