#!/bin/bash

if ! command -v tailscale &> /dev/null; then
    echo '{"text":"TSC err","class":"not-installed","tooltip":"Tailscale: NOT INSTALLED"}'
    exit 0
fi

status=$(tailscale status --json 2>/dev/null)

if [ $? -ne 0 ]; then
    echo '{"text":"TSC err","class":"error","tooltip":"Tailscale: ERROR\nFailed to get status"}'
    exit 0
fi

backend_state=$(echo "$status" | jq -r '.BackendState')

if [ "$backend_state" == "Running" ]; then
    self_ip=$(echo "$status" | jq -r '.Self.TailscaleIPs[0]')
    hostname=$(echo "$status" | jq -r '.Self.HostName')
    account=$(echo "$status" | jq -r '.Self.UserProfile.LoginName // .CurrentTailnet.Name // "Unknown"')
    account_short=$(echo "$account" | cut -d'@' -f1 | head -c 3)
    peer_count=$(echo "$status" | jq '.Peer | length')
    exit_node_name=$(echo "$status" | jq -r '.Peer | to_entries[] | select(.value.ExitNode == true) | .value.HostName // "Unknown"')

    tooltip="Tailscale: CONNECTED\nAccount: $account\nHostname: $hostname\nIP: $self_ip\nPeers: $peer_count"

    if [ -n "$exit_node_name" ]; then
        tooltip="$tooltip\nExit Node: $exit_node_name"
        text="TSC ext $account_short"
        class="exit-node"
    else
        text="TSC $account_short"
        class="connected"
    fi

    echo "{\"text\":\"$text\",\"class\":\"$class\",\"tooltip\":\"$tooltip\"}"
elif [ "$backend_state" == "Stopped" ]; then
    echo '{"text":"TSC off","class":"disconnected","tooltip":"Tailscale: STOPPED"}'
else
    echo "{\"text\":\"TSC unk\",\"class\":\"unknown\",\"tooltip\":\"Tailscale: UNKNOWN STATE\n$backend_state\"}"
fi
