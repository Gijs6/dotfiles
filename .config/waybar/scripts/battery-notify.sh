#!/bin/bash

STATE_FILE="/tmp/battery-notify-state"

CAPACITY=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
STATUS=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)

if [[ "$STATUS" == "Charging" ]] || [[ "$STATUS" == "Full" ]]; then
    rm -f "$STATE_FILE"
    exit 0
fi

if [[ -z "$CAPACITY" ]]; then
    exit 0
fi

if [[ -f "$STATE_FILE" ]]; then
    LAST_LEVEL=$(cat "$STATE_FILE")
else
    LAST_LEVEL=100
fi

if [[ $CAPACITY -le 5 ]] && [[ $LAST_LEVEL -gt 5 ]]; then
    notify-send -u critical "Battery critical" "${CAPACITY}% remaining"
    echo "5" > "$STATE_FILE"
elif [[ $CAPACITY -le 15 ]] && [[ $LAST_LEVEL -gt 15 ]]; then
    notify-send -u critical "Battery low" "${CAPACITY}% remaining"
    echo "15" > "$STATE_FILE"
elif [[ $CAPACITY -le 30 ]] && [[ $LAST_LEVEL -gt 30 ]]; then
    notify-send -u normal "Battery warning" "${CAPACITY}% remaining"
    echo "30" > "$STATE_FILE"
fi
