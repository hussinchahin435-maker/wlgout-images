#!/bin/bash

# ==============================================================================
# Horimiya Prototype Theme - Unified Installer v2.1.0
# ==============================================================================

set -euo pipefail

# Project Paths
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/horimiya-theme"
readonly LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"

# Configuration Paths
readonly WLOGOUT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wlogout"
readonly WALLUST_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wallust"

# State variables
INSTALL_WLOGOUT=false
INSTALL_TERMINAL=false
USE_WALLUST=false
INSTALL_THEME="default"

# Colors
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }

init_env() {
    mkdir -p "$LOG_DIR"
    log "Initializing Horimiya Prototype Theme setup..."
}

install_wlogout() {
    log "Installing wlogout theme: $INSTALL_THEME..."
    mkdir -p "$WLOGOUT_CONFIG_DIR"
    cp -r "$PROJECT_ROOT/themes/$INSTALL_THEME/"* "$WLOGOUT_CONFIG_DIR/"
    success "wlogout configured."
}

install_terminal() {
    log "Configuring Terminal settings..."
    mkdir -p "$HOME/.config/kitty" # مثال لـ Kitty
    cp "$PROJECT_ROOT/terminal/kitty.conf" "$HOME/.config/kitty/"
    success "Terminal configuration updated."
}

apply_wallust() {
    if command -v wallust &> /dev/null; then
        log "Linking Wallust templates..."
        mkdir -p "$WALLUST_CONFIG_DIR/templates"
        cp "$PROJECT_ROOT/templates/style.css.j2" "$WALLUST_CONFIG_DIR/templates/wlogout.css"
        success "Wallust templates prepared."
    else
        error "Wallust not found. Skipping dynamic colors."
    fi
}

show_help() {
    echo "Usage: ./install.sh [OPTIONS]"
    echo "  --wlogout     Install wlogout theme"
    echo "  --terminal    Install terminal config"
    echo "  --wallust     Apply wallust templates"
    echo "  --all         Install everything"
}

# --- Main Logic ---
init_env

if [[ $# -eq 0 ]]; then show_help; exit 0; fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --wlogout) INSTALL_WLOGOUT=true; shift ;;
        --terminal) INSTALL_TERMINAL=true; shift ;;
        --wallust) USE_WALLUST=true; shift ;;
        --all) INSTALL_WLOGOUT=true; INSTALL_TERMINAL=true; USE_WALLUST=true; shift ;;
        *) log "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

[[ "$INSTALL_WLOGOUT" == true ]] && install_wlogout
[[ "$INSTALL_TERMINAL" == true ]] && install_terminal
[[ "$USE_WALLUST" == true ]] && apply_wallust

success "Horimiya Prototype Theme installation finished!"
