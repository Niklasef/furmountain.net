#!/bin/bash

# Define variables
SERVER_DIR="/home/niklas/minecraft"  # Path to your Minecraft server directory
BACKUP_DIR="/home/niklas/minecraft_backups" # Path to the backup directory
TIMESTAMP=$(date +"%Y%m%d%H%M%S")       # Timestamp for the backup filename
BACKUP_FILE="$BACKUP_DIR/minecraft_backup_$TIMESTAMP.tar.gz" # Backup file name

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"
echo "$(date) - Created backup directory if it didn't exist."

# Stop the Minecraft server
sudo systemctl stop minecraft
if [ $? -eq 0 ]; then
  echo "$(date) - Stopped the Minecraft server."
else
  echo "$(date) - Failed to stop the Minecraft server."
  exit 1
fi

# Create a compressed archive of the world directory and essential files
tar -czf "$BACKUP_FILE" -C "$SERVER_DIR" world server.properties whitelist.json ops.json banned-players.json banned-ips.json
if [ $? -eq 0 ]; then
  echo "$(date) - Created a compressed archive of the world directory and essential files."
else
  echo "$(date) - Failed to create a compressed archive."
  sudo systemctl start minecraft
  exit 1
fi

# Start the Minecraft server
sudo systemctl start minecraft
if [ $? -eq 0 ]; then
  echo "$(date) - Started the Minecraft server."
else
  echo "$(date) - Failed to start the Minecraft server."
  exit 1
fi

# Delete old backups (older than 7 days)
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;
echo "$(date) - Deleted backups older than 7 days."

# Print a message indicating the backup is complete
echo "$(date) - Backup completed: $BACKUP_FILE"
