#!/bin/bash

cd "$(dirname "$0")"

declare -A checksums

for dir in 2025-*/; do
    [ ! -d "$dir" ] && continue

    echo "Checking $dir..."
    checksum=$(cd "$dir" && find . -type f -exec md5sum {} \; 2>/dev/null | sort -k2 | md5sum | cut -d' ' -f1)
    [ -z "$checksum" ] && continue

    if [ -n "${checksums[$checksum]}" ]; then
        echo "  Removing duplicate (same as ${checksums[$checksum]})"
        rm -rf "$dir"
    else
        echo "  Keeping"
        checksums[$checksum]="$dir"
    fi
done

echo "Done"
