#!/bin/bash
# BurnLab Master Installer
# The one-command setup for the entire lab.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo ""
echo "=========================================="
echo "   BurnLab Automated Installer"
echo "=========================================="
echo ""

# 1. Persistence Check & Setup
# ----------------------------
log "Checking system state..."

if ! findmnt -n -o SOURCE / | grep -q '/dev/sd'; then
    warn "Persistence NOT active."
    warn "Attempting to configure persistence now..."
    
    # Run persistence setup in automated mode
    sudo bash "$SCRIPT_DIR/core/00_setup_persistence.sh" -y
    
    echo ""
    log "Persistence partition created."
    log "CRITICAL: You MUST reboot now to activate persistence."
    log "Please reboot, select the 'Persistence' option in the boot menu,"
    log "and run this command again to complete installation."
    exit 0
fi

log "Persistence is active. Proceeding with installation."

# 2. Hardware Checks & Profile Selection
# -------------------------------------
TOTAL_RAM=$(get_total_ram_gb)
log "Detected RAM: ${TOTAL_RAM}GB"

if [[ "$TOTAL_RAM" -lt 4 ]]; then
    warn "Low RAM detected (<4GB). AI features may be unstable."
fi

# 3. Installation Phases
# ----------------------
# Run everything non-interactively

log "Phase 1/9: System Updates"
sudo bash "$SCRIPT_DIR/core/01_system_update.sh"

log "Phase 2/9: Base Tools"
sudo bash "$SCRIPT_DIR/core/02_base_tools.sh"

log "Phase 3/9: Python Environment"
bash "$SCRIPT_DIR/core/03_python_env.sh"

log "Phase 4/9: AI Runtime (Ollama)"
sudo bash "$SCRIPT_DIR/ai/01_install_ollama.sh"

log "Phase 5/9: AI Models"
bash "$SCRIPT_DIR/ai/02_pull_models.sh"

log "Phase 6/9: Kiwix Server"
sudo bash "$SCRIPT_DIR/tools/01_install_kiwix.sh"

log "Phase 7/9: Knowledge Bases (Auto-selected based on space)"
bash "$SCRIPT_DIR/tools/02_download_zims.sh"

log "Phase 8/9: VS Code"
bash "$SCRIPT_DIR/tools/03_install_vscode.sh"

log "Phase 9/9: Desktop & Wrappers"
bash "$SCRIPT_DIR/core/04_customize_desktop.sh"
sudo bash "$SCRIPT_DIR/core/05_create_wrappers.sh"

echo ""
echo "=========================================="
echo "   Installation Complete!"
echo "=========================================="
echo ""
log "System is ready."
log "Reboot recommended to finalize all paths."
