#!/bin/bash
source "$(dirname "$0")/../common.sh"

log "Customizing Openbox desktop..."

# Copy configs from repo
cp -r "$PROJECT_ROOT/configs/openbox/"* ~/.config/openbox/
cp -r "$PROJECT_ROOT/configs/conky/"* ~/.config/conky/ 2>/dev/null || true
cp "$PROJECT_ROOT/configs/dotfiles/bashrc_additions" ~/.bashrc_burnlab

# Source additions
grep -q "bashrc_burnlab" ~/.bashrc || \
    echo "source ~/.bashrc_burnlab" >> ~/.bashrc

openbox --reconfigure

log "Desktop customized"
