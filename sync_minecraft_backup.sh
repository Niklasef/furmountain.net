#!/bin/bash

# Define variables
SOURCE_USER="niklas"
SOURCE_HOST="minecraft.furmountain.net"
SOURCE_DIR="/home/niklas/minecraft_backups"
TARGET_DIR="/home/niklas/received_minecraft_backups"

# Ensure the target directory exists
mkdir -p "$TARGET_DIR"

# Sync the backup files using rsync without deletion
rsync -avz --ignore-existing -e ssh "$SOURCE_USER@$SOURCE_HOST:$SOURCE_DIR/" "$TARGET_DIR/"

# Log the result of rsync
if [ $? -eq 0 ]; then
    echo "Backup synced successfully at $(date)"
else
    echo "Failed to sync backup at $(date)"
fi

# Delete old backups, keeping only the 7 newest files
cd "$TARGET_DIR" || exit
ls -t | sed -e '1,7d' | xargs -d '\n' rm -f

# Log the result of deletion
if [ $? -eq 0 ]; then
    echo "Old backups deleted successfully at $(date)"
else
    echo "Failed to delete old backups at $(date)"
fi
