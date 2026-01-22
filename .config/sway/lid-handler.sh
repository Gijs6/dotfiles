#!/bin/bash

external_count=$(swaymsg -t get_outputs | jq '[.[] | select(.name != "eDP-1" and .active == true)] | length')

if [ "$external_count" -gt 0 ]; then
    swaymsg output eDP-1 disable
else
    systemctl suspend
fi
