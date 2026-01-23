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

# Check if enough unallocated space exists for standard partitioning
# We need at least 6GB of UNALLOCATED space at the end of the drive.
# If sdb1 takes up 100% of space, we must use File-Based Persistence (Ventoy method).

BACKEND_FILE="/run/live/medium/persistence.dat"

if [[ -f "$BACKEND_FILE" ]]; then
    log "Existing persistence file found."
    # Check if it's already configured? 
    # Just proceed to tell user to validify it.
fi

# Check if we can partition (Naive check: is the last partition end < disk size - 5GB?)
LAST_PART_END=$(sudo parted -s "$USB_DEV" unit B print | grep -v "^$" | tail -1 | awk '{print $3}' | tr -d 'B')
DISK_SIZE=$(lsblk -bno SIZE "$USB_DEV" | head -1)
FREE_SPACE=$((DISK_SIZE - LAST_PART_END))
MIN_FREE=$((5 * 1024 * 1024 * 1024))

MODE="PARTITION"
if [[ "$FREE_SPACE" -lt "$MIN_FREE" ]]; then
    log "Drive is fully allocated (Ventoy Default). Switching to File-Based Persistence."
    MODE="FILE"
fi

if [[ "$MODE" == "FILE" ]]; then
    # Fix: Do not use /run/live/medium as it is often read-only (loopback).
    # Instead, mount the physical partition (sdb1) directly.
    
    # Assuming standard Ventoy layout: Partition 1 is the Data partition.
    DATA_PART="${USB_DEV}1"
    TEMP_MOUNT="/mnt/ventoy_rw"
    
    log "Mounting physical partition $DATA_PART to $TEMP_MOUNT..."
    sudo mkdir -p "$TEMP_MOUNT"
    
    # Try mounting. If fails (e.g. exFAT/NTFS needs helpers), try generic mount.
    if ! sudo mount "$DATA_PART" "$TEMP_MOUNT"; then
        warn "Standard mount failed. Trying to force rw..."
        # Sometimes it's already mounted read-only by the system at /run/live/medium.
        # We can't remount check, so we just try to mount it elsewhere.
        error "Could not mount $DATA_PART. Is the filesystem corrupt or hibernated?"
    fi

    # Check for write access
    if [[ ! -w "$TEMP_MOUNT" ]]; then
        # Try remounting RW
        sudo mount -o remount,rw "$TEMP_MOUNT" || error "Partition $DATA_PART is read-only."
    fi

    BACKEND_FILE="$TEMP_MOUNT/persistence.dat"

    # Calculate size (Use available space on the partition minus 1GB buffer)
    AVAIL_KB=$(df -k "$TEMP_MOUNT" | tail -1 | awk '{print $4}')
    # Convert to GB (roughly)
    AVAIL_GB=$((AVAIL_KB / 1024 / 1024))
    FILE_SIZE_GB=$((AVAIL_GB - 1))
    
    if [[ "$FILE_SIZE_GB" -lt 4 ]]; then
        error "Not enough space on USB drive for persistence file. Need 4GB+, have ${AVAIL_GB}GB."
    fi
    
    # Cap at 32GB to be safe/fast
    if [[ "$FILE_SIZE_GB" -gt 32 ]]; then FILE_SIZE_GB=32; fi

    log "Creates ${FILE_SIZE_GB}GB persistence file at $BACKEND_FILE..."
    
    # Use dd if fallocate isn't supported on exFAT (common on Ventoy)
    if ! sudo fallocate -l "${FILE_SIZE_GB}G" "$BACKEND_FILE" 2>/dev/null; then
        log "fallocate not supported (exFAT?), using dd (this will take time)..."
        sudo dd if=/dev/zero of="$BACKEND_FILE" bs=1M count=$((FILE_SIZE_GB * 1024)) status=progress
    fi

    log "Formatting persistence file..."
    # Loop setup
    LOOP_DEV=$(sudo losetup -fP --show "$BACKEND_FILE")
    sudo mkfs.btrfs -f -L persistence "$LOOP_DEV"
    
    # Configure Persistence inside the BTRFS container
    sudo mkdir -p /mnt/persist_temp
    sudo mount "$LOOP_DEV" /mnt/persist_temp
    echo "/ union" | sudo tee /mnt/persist_temp/persistence.conf
    sudo umount /mnt/persist_temp
    sudo losetup -d "$LOOP_DEV"

    # Configure Ventoy JSON
    VENTOY_DIR="$TEMP_MOUNT/ventoy"
    sudo mkdir -p "$VENTOY_DIR"
    
    # Find the ISO file (usually in root or nested)
    # We look in the root of the mounted drive
    ISO_FILE=$(ls "$TEMP_MOUNT" | grep -i "\.iso$" | head -1) || true
    
    if [[ -z "$ISO_FILE" ]]; then
        warn "Could not auto-detect ISO filename in root of USB."
        warn "You may need to edit /ventoy/ventoy.json manually on the drive."
        ISO_FILE="bunsenlabs.iso"
    fi
    
    JSON_FILE="$VENTOY_DIR/ventoy.json"
    log "Creating $JSON_FILE configuration..."
    
    cat <<EOF | sudo tee "$JSON_FILE"
{
    "persistence": [
        {
            "image": "/$ISO_FILE",
            "backend": "/persistence.dat"
        }
    ]
}
EOF
    
    log "Unmounting..."
    sudo umount "$TEMP_MOUNT"
    
    log "✅ Ventoy File-Based Persistence Configured!"
    log "Please REBOOT now."
    exit 0
    
else
    # PARTITION MODE (Legacy/Standard)
    
    TOTAL_SIZE_BYTES=$(lsblk -bno SIZE "$USB_DEV" | head -1)
    # Reserve 4GB for System/ISO (Ventoy needs some, ISO needs ~2.5GB)
    RESERVE_BYTES=$((4 * 1024 * 1024 * 1024))
    
    log "Creating partition at end of disk..."
    sudo parted -s "$USB_DEV" -- mkpart primary btrfs "${RESERVE_BYTES}B" 100% || \
        error "Partition creation failed."

    # Reload partition table
    sudo partprobe "$USB_DEV" || true
    sleep 3

    # Format with compression
    # Find the new partition (likely the last one)
    NEW_PART=$(lsblk -no NAME,PATH "$USB_DEV" | tail -1 | awk '{print $2}')
    
    log "Formatting $NEW_PART with btrfs..."
    sudo mkfs.btrfs -f -L persistence "$NEW_PART"

    # Mount and configure
    sudo mkdir -p /mnt/persist
    sudo mount -o compress=zstd:15 "$NEW_PART" /mnt/persist
    echo "/ union" | sudo tee /mnt/persist/persistence.conf
    sudo umount /mnt/persist

    log "✅ Partition-Based Persistence Configured!"
fi
