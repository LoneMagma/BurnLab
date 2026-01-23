#!/bin/bash
source "$(dirname "$0")/../common.sh"

VSCODE_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
INSTALL_DIR=~/apps/vscode

log "Installing VS Code portable..."
mkdir -p ~/apps
wget -O /tmp/vscode.tar.gz "$VSCODE_URL"
tar -xzf /tmp/vscode.tar.gz -C ~/apps/
mv ~/apps/VSCode-linux-x64 "$INSTALL_DIR"

# Add to PATH
grep -q "apps/vscode/bin" ~/.bashrc || \
    echo 'export PATH="$PATH:~/apps/vscode/bin"' >> ~/.bashrc

log "VS Code installed: $INSTALL_DIR"
