#!/bin/bash

export PATH=/usr/local/bin:/usr/bin:/bin

# Source keychain environment to access SSH agent with flower key
[ -f "$HOME/.keychain/$(hostname)-sh" ] && . "$HOME/.keychain/$(hostname)-sh"

today=$(date +"%Y-%m-%d")
backup_dir="$HOME/atlas-backups"

# Only check for existing backup if not run manually (via cron/automated)
if [ -z "$PS1" ] && [ ! -t 0 ]; then
    if ls -d "$backup_dir/$today"* > /dev/null 2>&1; then
        echo "Backup already exists for today ($today), skipping."
        exit 0
    fi
fi

ts=$(date +"%Y-%m-%d_%H-%M-%S")
dest="$backup_dir/$ts"

mkdir -p "$dest"

rsync -ciavuP nov:/volume1/docker/atlas/ "$dest"

"$backup_dir/remove_duplicates.sh"
