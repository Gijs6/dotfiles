#!/bin/bash
set -euo pipefail

USB_MOUNT="/run/media/$USER/Elements"
BACKUP_DIR="$USB_MOUNT/ggijs/arch-full-backups/$(date +%Y-%m-%d)"

sudo mkdir -p "$BACKUP_DIR"

echo "Backing up to $BACKUP_DIR"

sudo rsync -aAXHv --info=progress2 \
  --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} \
  --exclude="$HOME/.local/share/Steam" \
  --exclude="$HOME/.cache" \
  --exclude="*.iso" \
  / "$BACKUP_DIR"

echo "Backup completed to $BACKUP_DIR"
