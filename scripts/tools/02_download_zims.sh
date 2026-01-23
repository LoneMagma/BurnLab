#!/bin/bash
source "$(dirname "$0")/../common.sh"

ZIMS_DIR=~/zims
MIRROR="https://download.kiwix.org/zim"

log "Starting Knowledge Base Download..."

# Auto-detect profile based on available space
# We check the space of the partition where ZIMS_DIR lives
mkdir -p "$ZIMS_DIR"
FREE_SPACE_GB=$(get_free_space_gb "$ZIMS_DIR")

log "Available space: ${FREE_SPACE_GB}GB"

# Profile Thresholds
# Full: Needs ~16GB free (Wikipedia=10GB, StackOverflow=4GB, Others=2GB)
# Lite: Needs ~4GB free (Python=0.5GB, Arch=0.5GB, DevDocs=1GB)

PROFILE="LITE"
if [[ "$FREE_SPACE_GB" -gt 18 ]]; then
    PROFILE="FULL"
elif [[ "$FREE_SPACE_GB" -gt 12 ]]; then
    PROFILE="STANDARD"
fi

# Override with argument if provided
if [[ "$1" == "FULL" ]]; then PROFILE="FULL"; fi
if [[ "$1" == "LITE" ]]; then PROFILE="LITE"; fi

log "Selected Profile: $PROFILE"

download_zim() {
    local name=$1
    local url=$2
    local file=$3
    
    if [[ ! -f "$ZIMS_DIR/$file" ]]; then
        log "Downloading $name..."
        wget -q --show-progress -c -P "$ZIMS_DIR" "$url" || warn "Failed to download $name"
    else
        log "Skipping $name (exists)"
    fi
}

# --- LITE PROFILE (Essential Developer Docs) ---
download_zim "Python 3 Docs" \
    "$MIRROR/other/python_en_all_2024-01.zim" \
    "python_en_all_2024-01.zim"

download_zim "DevDocs (API references)" \
    "$MIRROR/other/devdocs_en_all_2024-01.zim" \
    "devdocs_en_all_2024-01.zim"

download_zim "Arch Wiki" \
    "$MIRROR/other/archwiki_en_all_2024-01.zim" \
    "archwiki_en_all_2024-01.zim"

if [[ "$PROFILE" == "LITE" ]]; then
    log "Lite download complete."
    exit 0
fi

# --- STANDARD PROFILE (Adds StackOverflow, MDN) ---
download_zim "MDN Web Docs" \
    "$MIRROR/other/developer.mozilla.org_en_all_2024-01.zim" \
    "developer.mozilla.org_en_all_2024-01.zim"

download_zim "Stack Overflow" \
    "$MIRROR/stackoverflow.com/stackoverflow.com_en_all_2024-01.zim" \
    "stackoverflow.com_en_all_2024-01.zim"

if [[ "$PROFILE" == "STANDARD" ]]; then
    log "Standard download complete."
    exit 0
fi

# --- FULL PROFILE (Adds Wikipedia) ---
download_zim "Wikipedia (No Pictures)" \
    "$MIRROR/wikipedia/wikipedia_en_all_nopic_2024-01.zim" \
    "wikipedia_en_all_nopic_2024-01.zim"

log "Full download complete!"
ls -lh "$ZIMS_DIR"
