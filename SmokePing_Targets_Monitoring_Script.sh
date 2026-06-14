#!/bin/bash
set -euo pipefail

URL="https://raw.githubusercontent.com/jacktooandroid/smokeping/master/Configurations/Targets.txt"
TMP_DIR="/tmp/smokeping"
GITHUB_TARGETS="$TMP_DIR/GitHub_Targets"
LOCAL_TARGETS="/etc/smokeping/config.d/Targets"
BACKUP_TARGETS="/etc/smokeping/config.d/Targets.bak.$(date +%Y%m%d%H%M%S)"

mkdir -p "$TMP_DIR"

#Download from GitHub
echo "Downloading latest Targets file..."
if curl -fsSL "$URL" -o "$GITHUB_TARGETS"; then
    echo "Downloaded latest Targets file using curl."
else
    echo "curl failed. Trying wget as fallback..."
    
    if wget -q "$URL" -O "$GITHUB_TARGETS"; then
        echo "Downloaded latest Targets file using wget."
    else
        echo "Both curl and wget failed. Exiting."
        exit 1
    fi
fi

#Test target files
if [ ! -s "$GITHUB_TARGETS" ]; then
    echo "Downloaded Targets file is missing or empty. Exiting."
    exit 1
fi

if [ ! -s "$LOCAL_TARGETS" ]; then
    echo "Local Targets file is missing or empty. Exiting."
    exit 1
fi

#Compare SHA256 hashes
GitHub_Targets=$(sha256sum "$GITHUB_TARGETS" | awk '{print $1}')
Local_Targets=$(sha256sum "$LOCAL_TARGETS" | awk '{print $1}')

if [ "$GitHub_Targets" = "$Local_Targets" ]; then
    echo "No changes detected. Exiting."
    exit 0
fi

#Implement replacement if SHA256 hashes do not match
echo "Changes detected. Replacing with newer version now."
sudo cp "$LOCAL_TARGETS" "$BACKUP_TARGETS"
sudo cp "$GITHUB_TARGETS" "$LOCAL_TARGETS"

if sudo systemctl restart smokeping; then
    echo "SmokePing Targets updated and restarted successfully."
    exit 0
else
    echo "SmokePing failed to restart. Restoring previous Targets file."
    sudo cp "$BACKUP_TARGETS" "$LOCAL_TARGETS"
    if sudo systemctl restart smokeping; then
        echo "Previous Targets file restored and SmokePing restarted successfully."
    else
        echo "Previous Targets file restored, but SmokePing still failed to restart. Manual investigation required."
    fi
    exit 1
fi