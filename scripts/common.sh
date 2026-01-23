#!/bin/bash
# Common utilities for all scripts

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[BurnLab]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Helper: Check available space in GB on a path
# Usage: check_space_gb /path/to/check
get_free_space_gb() {
    local path=$1
    if [[ -d "$path" ]]; then
        df -BG "$path" | tail -1 | awk '{print $4}' | sed 's/G//'
    else
        echo "0"
    fi
}

# Helper: Get total RAM in GB
get_total_ram_gb() {
    free -g | grep Mem: | awk '{print $2}'
}
