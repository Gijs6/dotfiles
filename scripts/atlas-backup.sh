#!/bin/bash

set -euo pipefail

NOW=$(date +"%Y%m%d_%H%M%S")
DIST="/tmp/dec_$NOW.tar.gz"
REMOTE="ggijs@100.113.201.50"

BASE_PATHS=(
    "/usr/local/bin/lift"
    "/usr/local/bin/lift-bootstrap"
    "/home/ggijs/www"
)

GLOB_PATHS=(
    "/home/ggijs/*.env"
)

for pattern in "${GLOB_PATHS[@]}"; do
    shopt -s nullglob
    matches=("$pattern")
    shopt -u nullglob
    if [ -e "${matches[0]}" ]; then
        BASE_PATHS+=("${matches[@]}")
    fi
done

echo "Creating archive: $DIST"
tar -czf "$DIST" \
    --exclude='/home/ggijs/www/master-db' \
    --ignore-failed-read \
    "${BASE_PATHS[@]}" || {
    code=$?
    if [ "$code" -gt 1 ]; then
        exit "$code"
    fi
    echo "tar completed with warnings (some files missing)"
}

chmod 600 "$DIST"

echo "Uploading to $REMOTE"
rsync -az --progress -e "ssh -i /home/ggijs/.ssh/antarctica" "$DIST" "$REMOTE:"

echo "Cleaning up temporary archive"
rm -f "$DIST"

echo "Backup completed successfully!"
