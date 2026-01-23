#!/bin/bash
source "$(dirname "$0")/../common.sh"

log "Updating system packages..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
log "System updated"
