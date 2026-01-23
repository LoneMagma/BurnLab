#!/bin/bash
source "$(dirname "$0")/../common.sh"

log "Installing Ollama..."
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
else
    warn "Ollama already installed"
fi

# Start service
sudo systemctl enable ollama
sudo systemctl start ollama

log "Ollama installed and running"
