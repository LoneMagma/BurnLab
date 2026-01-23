#!/bin/bash
source "$(dirname "$0")/../common.sh"

log "Creating shared Python environment..."
python3 -m venv ~/lab-env --system-site-packages
source ~/lab-env/bin/activate
pip install --upgrade pip
pip install numpy pandas requests beautifulsoup4 matplotlib

# Add to bashrc
grep -q "lab-env/bin/activate" ~/.bashrc || \
    echo "source ~/lab-env/bin/activate" >> ~/.bashrc

log "Python environment ready"
