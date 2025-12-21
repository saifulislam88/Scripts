#!/bin/bash
MOUNT_POINT="/var/opt/gitlab/backups"
NFS_SERVER="x.x.x.x:/volume1/XY/GIT"
LOG_FILE="/var/log/nfs_mount.log"

# Function to log messages with timestamp
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

# Check if already mounted
if ! mountpoint -q "$MOUNT_POINT"; then
    log_msg "NFS not mounted, trying to mount..."
    mount -t nfs "$NFS_SERVER" "$MOUNT_POINT"
    if [ $? -eq 0 ]; then
        log_msg "Mounted successfully."
        # Fix ownership and permissions after mount
        chown git:git "$MOUNT_POINT"
        chmod 700 "$MOUNT_POINT"
        log_msg "Set ownership to git:git and permissions to 700."
    else
        log_msg "Mount failed!"
        exit 1
    fi
else
    log_msg "NFS already mounted."
fi

