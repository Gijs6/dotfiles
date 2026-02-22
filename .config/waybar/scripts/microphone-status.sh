#!/bin/bash

if ! command -v pactl &> /dev/null; then
    echo '{"text":"ERR","class":"unavailable","tooltip":"PulseAudio not available"}'
    exit 0
fi

mute_status=$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')

if [ $? -ne 0 ]; then
    echo '{"text":"ERR","class":"error","tooltip":"Failed to get microphone status"}'
    exit 0
fi

source_info=$(pactl list sources 2>/dev/null | grep -A 20 "Name: $(pactl get-default-source)")
source_desc=$(echo "$source_info" | grep "Description:" | cut -d: -f2- | xargs)

if [ "$mute_status" == "yes" ]; then
    echo "{\"text\":\"MUT\",\"class\":\"muted\",\"tooltip\":\"Microphone: MUTED\\n$source_desc\"}"
else
    echo "{\"text\":\"ACT\",\"class\":\"active\",\"tooltip\":\"Microphone: ACTIVE\\n$source_desc\"}"
fi
