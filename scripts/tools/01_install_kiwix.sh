#!/bin/bash
source "$(dirname "$0")/../common.sh"

log "Installing Kiwix tools..."
sudo apt install -y kiwix-tools

# Create ZIM directory
mkdir -p ~/zims

log "Kiwix installed. ZIM directory: ~/zims"
