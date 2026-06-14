#!/bin/bash

set -euo pipefail

URL="https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Targets.txt"
TMP_DIR="/tmp/smokeping"
GITHUB_TARGETS="$TMP_DIR/Targets"
LOCAL_TARGETS="/etc/smokeping/config.d/Targets"
BACKUP_TARGETS="/etc/smokeping/config.d/Targets.bak.$(date +%Y%m%d%H%M%S)"

mkdir -p "$TMP_DIR"

echo "Downloading latest Targets file..."
curl -fsSL "$URL" -o "$GITHUB_TARGETS"
if [ ! -s "$GITHUB_TARGETS" ]; then
    echo "Downloaded Targets file is missing or empty. Exiting."
    exit 1
fi

if [ ! -s "$LOCAL_TARGETS" ]; then
    echo "Local Targets file is missing or empty. Exiting."
    exit 1
fi

GitHub_Targets=$(sha256sum "$GITHUB_TARGETS" | awk '{print $1}')
Local_Targets=$(sha256sum "$LOCAL_TARGETS" | awk '{print $1}')

if [ "$GitHub_Targets" = "$Local_Targets" ]; then
    echo "No changes detected. Exiting."
    exit 0
fi

echo "Changes detected. Replacing with newer version now."
sudo cp "$LOCAL_TARGETS" "$BACKUP_TARGETS"
sudo cp "$GITHUB_TARGETS" "$LOCAL_TARGETS"

if sudo systemctl restart smokeping; then
    echo "SmokePing Targets updated and restarted successfully."
    exit 0
else
    echo "SmokePing failed to restart. Restoring previous Targets file."
    sudo cp "$BACKUP_TARGETS" "$LOCAL_TARGETS"
    sudo systemctl restart smokeping
    exit 1
fi