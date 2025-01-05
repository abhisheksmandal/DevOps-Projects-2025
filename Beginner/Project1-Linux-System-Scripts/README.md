# Project1-Linux-System-Scripts

A collection of Bash scripts for automating common Linux system administration tasks. These scripts help streamline routine maintenance operations, system updates, and backup procedures.

## Scripts Included

1. `system_update.sh` - Automatically updates system packages and performs cleanup
2. `log_cleanup.sh` - Manages and rotates system log files
3. `backup_data.sh` - Creates compressed backups of specified directories
4. `monitor_disk.sh` - Monitors disk space usage and sends alerts
5. `system_info.sh` - Displays comprehensive system information

## Prerequisites

- Bash shell (version 4.0 or higher)
- Root access or sudo privileges
- Linux operating system (tested on Ubuntu 20.04+)

## Installation

1. Clone the repository:

```bash
git clone https://github.com/abhisheksmandal/DevOps-Projects-2025.git
cd DevOps-Projects-2025/Beginner/Project1-Linux-System-Scripts
```

2. Make the scripts executable:

```bash
chmod +x *.sh
```

## Usage

### System Update Script

```bash
./system_update.sh
```

### Log Cleanup Script

```bash
./log_cleanup.sh [days_to_retain]
```

### Backup Script

```bash
./backup_data.sh [source_directory] [backup_directory]
```

### Disk Monitor Script

```bash
./monitor_disk.sh [threshold_percentage]
```

### System Information Script

```bash
./system_info.sh
```

## Configuration

Each script can be configured by modifying the variables at the beginning of the file. Common configuration options include:

- Log retention periods
- Backup locations
- Email notifications
- Disk space thresholds

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Author

Abhishek Mandal (@abhisheksmandal)

## Acknowledgments

- Inspired by common system administration tasks
- Built for the Linux system administration community
