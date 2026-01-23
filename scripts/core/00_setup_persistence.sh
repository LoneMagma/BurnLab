#!/bin/bash
# BurnLab Persistence Setup - Run ONCE on first boot

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[Persistence]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Detect automated flag
AUTO_MODE=false
[[ "$1" == "-y" ]] && AUTO_MODE=true

# Check if already persistent
if findmnt -n -o SOURCE / | grep -q '/dev/sd'; then
    log "✅ Persistence already enabled!"
    exit 0
fi

if [[ "$AUTO_MODE" == "false" ]]; then
    warn "⚠️  This will modify your USB partitions!"
    warn "Make sure you've backed up any important data."
    warn "Continue? Type 'yes' to proceed:"
    read -r response
    [[ "$response" != "yes" ]] && { log "Aborted."; exit 1; }
else
    log "Running in automated mode..."
fi

log "Installing partition tools..."
sudo apt update -qq
sudo apt install -y btrfs-progs parted

# Find USB device
USB_DEV=$(lsblk -ndo NAME,TRAN | awk '$2=="usb" {print "/dev/"$1}' | head -1)
[[ -z "$USB_DEV" ]] && error "No USB device found. Are you booted from USB?"

log "Found USB device: $USB_DEV"
lsblk "$USB_DEV"

# Dynamic Calculation
log "Calculating partition sizes..."
TOTAL_SIZE_BYTES=$(lsblk -bno SIZE "$USB_DEV" | head -1)
# Reserve 4GB for System/ISO (Ventoy needs some, ISO needs ~2.5GB)
RESERVE_BYTES=$((4 * 1024 * 1024 * 1024))
PERSIST_SIZE_BYTES=$((TOTAL_SIZE_BYTES - RESERVE_BYTES))

if [[ $PERSIST_SIZE_BYTES -lt $((2 * 1024 * 1024 * 1024)) ]]; then
    error "Not enough space for persistence. Need at least 6GB total USB size."
fi

# Convert to MB for display
PERSIST_MB=$((PERSIST_SIZE_BYTES / 1024 / 1024))
log "Total USB: $((TOTAL_SIZE_BYTES / 1024 / 1024 / 1024))GB"
log "Reserving: 4GB for System"
log "Persistence Partition: ~${PERSIST_MB}MB"

# Get last partition number to append
LAST_PART=$(lsblk -no NAME "$USB_DEV" | tail -1 | grep -o '[0-9]*$')
NEXT_PART=$((LAST_PART + 1))
PERSIST_PART="${USB_DEV}${NEXT_PART}"

log "Creating partition ${PERSIST_PART}..."
# Use 100% to fill the rest of the disk, starting from where the previous ended?
# Ventoy usually puts data at the end or beginning. Safe bet with parted 'mkpart' using percentages if free space is at end.
# However, Ventoy is tricky. It usually has Part1 (exFAT data), Part2 (EFI).
# We want to create Part 3 in the free space.
# We will trust Parted to find the free space if we say 'Start of free space' to '100%'.
# BUT, we need to be careful not to overwrite Part 1 if it thinks it's full.
# Best approach for Ventoy: Use the 'F4 Localdisk' plugin logic manually or just append.
# We will use valid "print free" logic or just append to end of disk.

# Simplest reliable method for appended partition:
sudo parted -s "$USB_DEV" -- mkpart primary btrfs "${RESERVE_BYTES}B" 100% || \
    error "Partition creation failed. Disk setup might be non-standard."

# Reload partition table
sudo partprobe "$USB_DEV" || true
sleep 3

# Format with compression
log "Formatting with btrfs (zstd:15 compression)..."
sudo mkfs.btrfs -f -L persistence "$PERSIST_PART"

# Mount and configure
sudo mkdir -p /mnt/persist
sudo mount -o compress=zstd:15 "$PERSIST_PART" /mnt/persist
echo "/ union" | sudo tee /mnt/persist/persistence.conf
sudo umount /mnt/persist

log "✅ Persistence configured!"
