#!/bin/bash

export PATH=/usr/local/bin:/usr/bin:/bin

# Source keychain environment to access SSH agent with flower key
[ -f "$HOME/.keychain/$(uname -n)-sh" ] && . "$HOME/.keychain/$(uname -n)-sh"

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
rsync_exit=$?

# rsync exit codes:
# 0 = success
# 23 = partial transfer (some files failed but most succeeded)
# 24 = partial transfer (some files vanished during transfer)
# other = failure
if [ $rsync_exit -ne 0 ] && [ $rsync_exit -ne 23 ] && [ $rsync_exit -ne 24 ]; then
    echo "ERROR: rsync failed with exit code $rsync_exit"
    rm -rf "$dest"
    exit $rsync_exit
elif [ $rsync_exit -eq 23 ]; then
    echo "WARNING: rsync completed with some errors (exit code 23)"
    echo "Some files/attributes were not transferred. Backup is partial but kept."
elif [ $rsync_exit -eq 24 ]; then
    echo "WARNING: rsync completed with some files vanishing (exit code 24)"
    echo "Backup is partial but kept."
fi

"$backup_dir/remove_duplicates.sh"
