#!/bin/bash
set -euo pipefail

usage() {
    echo "Usage: $0 --usb | --remote"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

DEST_TYPE=""
for arg in "$@"; do
    case $arg in
        --usb)
            DEST_TYPE="usb"
            DEST_PATH="/run/media/$USER/Elements/ggijs/arch-full-backups/$(date +%Y-%m-%d)"
            ;;
        --remote)
            DEST_TYPE="remote"
            DEST_PATH="dec:/home/ggijs/backups/arch-full-backups/$(date +%Y-%m-%d)"
            ;;
        *)
            usage
            ;;
    esac
done

DATE=$(date +%Y-%m-%d-%H%M%S)
TMP_ARCHIVE="/tmp/arch-backup-$DATE.tar.gz"

echo "Finding large .mp4 files to exclude..."
# Handle spaces correctly
MP4_EXCLUDES=()
while IFS= read -r f; do
    MP4_EXCLUDES+=("--exclude=$f")
done < <(find "$HOME" -type f -name "*.mp4" -size +500M)

echo "Creating compressed backup archive $TMP_ARCHIVE..."

sudo tar --exclude=/dev \
        --exclude=/proc \
        --exclude=/sys \
        --exclude=/tmp \
        --exclude=/run \
        --exclude=/mnt \
        --exclude=/media \
        --exclude=/lost+found \
        --exclude="$HOME/.local/share" \
        --exclude="$HOME/projects/qd" \
        --exclude="$HOME/.cache" \
        --exclude="$HOME/.npm" \
        --exclude="$HOME/.yarn" \
        --exclude="$HOME/.cargo" \
        --exclude="$HOME/.nuget" \
        --exclude="$HOME/.mix" \
        --exclude="$HOME/.hex" \
        --exclude="$HOME/.bun" \
        --exclude="$HOME/.bundle" \
        --exclude="$HOME/.mozilla" \
        --exclude="$HOME/.thunderbird" \
        --exclude="$HOME/.nv" \
        --exclude="$HOME/.nvidia-settings-rc" \
        --exclude="$HOME/.fly" \
        --exclude="$HOME/tmp" \
        --exclude="$HOME/.steampath" \
        --exclude="$HOME/.steampid" \
        --exclude="$HOME/.wine" \
        --exclude="$HOME/.xsession-errors*" \
        --exclude="$HOME/.histfile" \
        --exclude="$HOME/.zcompdump" \
        --exclude='**/.venv' \
        --exclude='**/node_modules' \
        --exclude="*.iso" \
        "${MP4_EXCLUDES[@]}" \
        -czvpf "$TMP_ARCHIVE" /

echo "Archive created."

if [ "$DEST_TYPE" = "usb" ]; then
    mkdir -p "$DEST_PATH"
    mv "$TMP_ARCHIVE" "$DEST_PATH/"
    echo "Backup moved to USB at $DEST_PATH/$(basename "$TMP_ARCHIVE")"
elif [ "$DEST_TYPE" = "remote" ]; then
    echo "Transferring backup to remote host $DEST_PATH..."
    rsync -aHv --progress "$TMP_ARCHIVE" "$DEST_PATH/"
    rm -f "$TMP_ARCHIVE"
    echo "Backup transferred to remote host and temporary archive removed."
fi
