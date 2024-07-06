#!/bin/bash

# Define variables
SERVER_DIR="/home/niklas/minecraft"  # Path to your Minecraft server directory
BACKUP_DIR="/home/niklas/minecraft_backups" # Path to the backup directory
TIMESTAMP=$(date +"%Y%m%d%H%M%S")       # Timestamp for the backup filename
BACKUP_FILE="$BACKUP_DIR/minecraft_backup_$TIMESTAMP.tar.gz" # Backup file name

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Stop the Minecraft server
sudo systemctl stop minecraft

# Create a compressed archive of the server directory
tar -czf "$BACKUP_FILE" -C "$SERVER_DIR" .

# Start the Minecraft server
sudo systemctl start minecraft

# Delete old backups (older than 7 days)
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;

# Print a message indicating the backup is complete
echo "Backup completed: $BACKUP_FILE"
