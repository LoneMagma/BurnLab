#!/bin/bash
# BurnLab Bootstrap Script
# Usage: bash <(curl -sL https://raw.githubusercontent.com/LoneMagma/BurnLab/main/scripts/bootstrap.sh)

set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[Bootstrap] Checking dependencies...${NC}"

# 1. Install Git if missing
if ! command -v git &> /dev/null; then
    echo "Git not found. Installing..."
    sudo apt update -qq
    sudo apt install -y git
fi

# 2. Clone Repository
REPO_DIR="$HOME/BurnLab"
if [[ -d "$REPO_DIR" ]]; then
    echo "BurnLab directory exists. Pulling latest..."
    cd "$REPO_DIR"
    git pull
else
    echo "Cloning BurnLab..."
    git clone https://github.com/LoneMagma/BurnLab.git "$REPO_DIR"
fi

# 3. Launch Installer
echo -e "${GREEN}[Bootstrap] Launching Installer...${NC}"
cd "$REPO_DIR"
chmod +x scripts/install.sh
chmod +x scripts/core/*.sh
chmod +x scripts/tools/*.sh
chmod +x scripts/ai/*.sh

sudo ./scripts/install.sh -y
