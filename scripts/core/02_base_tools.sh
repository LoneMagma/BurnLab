#!/bin/bash
source "$(dirname "$0")/../common.sh"

log "Installing base development tools..."
sudo apt install -y \
    git curl wget build-essential \
    python3-pip python3-venv \
    htop btrfs-progs \
    geany mousepad \
    scrot imagemagick

log "Base tools installed"
