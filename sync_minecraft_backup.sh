#!/bin/bash

# Define variables
SOURCE_USER="niklas"
SOURCE_HOST="minecraft.furmountain.net"
SOURCE_DIR="/home/niklas/minecraft_backups"
TARGET_DIR="/home/niklas/received_minecraft_backups"

# Ensure the target directory exists
mkdir -p "$TARGET_DIR"

# Sync the backup files using rsync
rsync -avz --ignore-existing "$SOURCE_USER@$SOURCE_HOST:$SOURCE_DIR/" "$TARGET_DIR/"

# Log the result
if [ $? -eq 0 ]; then
    echo "Backup synced successfully"
else
    echo "Failed to sync backup"
fi
