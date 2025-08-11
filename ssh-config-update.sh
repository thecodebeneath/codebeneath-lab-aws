#!/bin/bash

set -e 

HOST_ALIAS=$1
SSH_CONFIG="/mnt/c/Users/Trivi/.ssh/config"
HOST_ENTRY="Host $HOST_ALIAS"
NEW_HOSTNAME=$(terraform output -raw "$HOST_ALIAS-public-eip")

# Check if the SSH config file exists
if [[ ! -f "$SSH_CONFIG" ]]; then
  echo "Error: SSH config file not found at $SSH_CONFIG"
  exit 1
fi

# Create a backup of the original config file
cp "$SSH_CONFIG" "$SSH_CONFIG.bak"
echo "Backup created: $SSH_CONFIG.bak"

# Use sed to modify the HostName for "Host bootstrap"
# The sed command works as follows:
# 1. '/^Host bootstrap/,/^Host /{ ... }' : This defines a range from the line
#    starting with "Host bootstrap" to the next line that starts with "Host"
#    (which marks the beginning of the next host entry). This ensures we only
#    modify within the "Host bootstrap" block.
# 2. '/^\s*HostName / s/.*/  HostName '"$NEW_HOSTNAME"'/ ' : Within that range,
#    it finds lines that start with optional spaces and "HostName ".
#    Then, it replaces the entire line (.*) with "  HostName " followed by the
#    new hostname.
# 3. -i : This option tells sed to edit the file in-place.
sed -i '/^'"$HOST_ENTRY"'/,/^Host /{
  /^\s*HostName / s/.*/    HostName '"$NEW_HOSTNAME"'/
}' "$SSH_CONFIG"

echo "SSH config file updated: HostName for '$HOST_ENTRY' changed to '$NEW_HOSTNAME'"
