#!/bin/bash

################################################################################
# Wlogout Themes - Common Utilities Library
# Shared utility functions for all scripts
################################################################################

set -euo pipefail

# Prevent double-sourcing
if [[ "${_WLOGOUT_COMMON_SOURCED:-}" == "true" ]]; then
    return 0
fi
readonly _WLOGOUT_COMMON_SOURCED=true

################################################################################
# Global Constants
################################################################################

readonly SCRIPT_VERSION="2.0.0"
readonly XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
readonly XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

readonly WLOGOUT_CONFIG_DIR="$XDG_CONFIG_HOME/wlogout"
readonly WLOGOUT_ICONS_DIR="$WLOGOUT_CONFIG_DIR/icons"
readonly WLOGOUT_STATE_DIR="$XDG_STATE_HOME/wlogout-installer"
readonly WLOGOUT_BACKUP_DIR="$XDG_STATE_HOME/wlogout-backups"
readonly WLOGOUT_MANIFEST_FILE="$WLOGOUT_STATE_DIR/manifest.json"

################################################################################
# Color Codes
################################################################################

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

################################################################################
# Utility Functions
################################################################################

# Get script directory
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

# Get project root directory
get_project_root() {
    local script_dir
    script_dir=$(get_script_dir)
    cd "$script_dir/../.." && pwd
}

# Get themes directory
get_themes_dir() {
    echo "$(get_project_root)/themes"
}

# List available themes
list_available_themes() {
    local themes_dir
    themes_dir=$(get_themes_dir)
    
    if [ ! -d "$themes_dir" ]; then
        return 1
    fi
    
    find "$themes_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

# Check if theme exists
theme_exists() {
    local theme_name="$1"
    local themes_dir
    themes_dir=$(get_themes_dir)
    
    [ -d "$themes_dir/$theme_name" ]
}

# Get absolute path of theme
get_theme_path() {
    local theme_name="$1"
    local themes_dir
    themes_dir=$(get_themes_dir)
    
    echo "$themes_dir/$theme_name"
}

# Check if running in dry-run mode
is_dry_run() {
    [ "${DRY_RUN:-false}" == "true" ]
}

# Check if verbose mode is enabled
is_verbose() {
    [ "${VERBOSE_MODE:-false}" == "true" ]
}

# Initialize directories
init_directories() {
    mkdir -p "$WLOGOUT_STATE_DIR"
    mkdir -p "$WLOGOUT_BACKUP_DIR"
    mkdir -p "$WLOGOUT_CONFIG_DIR"
}

# Get current timestamp in ISO 8601 format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Get current timestamp for filenames
get_timestamp_file() {
    date +"%Y%m%d-%H%M%S"
}

# Confirm action with user
confirm() {
    local prompt="$1"
    local response
    
    while true; do
        read -p "$prompt (y/n): " -r response
        case "$response" in
            [yY][eE][sS]|[yY]) return 0 ;;
            [nN][oO]|[nN]) return 1 ;;
            *) echo "Please answer yes or no" ;;
        esac
    done
}

# Execute command with dry-run support
exec_cmd() {
    local cmd="$*"
    
    if is_dry_run; then
        echo "[DRY RUN] $cmd"
        return 0
    fi
    
    eval "$cmd"
}

# Execute command with full output capture
exec_cmd_capture() {
    local cmd="$*"
    local output
    local exit_code
    
    if is_dry_run; then
        echo "[DRY RUN] $cmd"
        return 0
    fi
    
    output=$(eval "$cmd" 2>&1) || exit_code=$?
    echo "$output"
    return "${exit_code:-0}"
}

# Create a symlink safely
safe_symlink() {
    local target="$1"
    local link="$2"
    
    # Resolve to absolute path
    target=$(cd "$(dirname "$target")" && pwd)/$(basename "$target")
    
    # Remove existing symlink or file
    if [ -L "$link" ] || [ -e "$link" ]; then
        if is_dry_run; then
            echo "[DRY RUN] Remove existing: $link"
        else
            rm -f "$link"
        fi
    fi
    
    # Create symlink
    if is_dry_run; then
        echo "[DRY RUN] Symlink: $link -> $target"
    else
        ln -sf "$target" "$link"
    fi
}

# Verify symlink target
verify_symlink() {
    local link="$1"
    local expected_target="$2"
    
    if [ ! -L "$link" ]; then
        return 1
    fi
    
    local actual_target
    actual_target=$(readlink -f "$link" 2>/dev/null || echo "")
    expected_target=$(cd "$(dirname "$expected_target")" && pwd)/$(basename "$expected_target") 2>/dev/null || true
    
    [ "$actual_target" = "$expected_target" ]
}

# Check command availability
command_exists() {
    command -v "$1" &> /dev/null
}

# Get system information
get_system_info() {
    local os_name
    local kernel_release
    local hostname
    
    if command_exists lsb_release; then
        os_name=$(lsb_release -d | cut -f2)
    else
        os_name=$(uname -s)
    fi
    
    kernel_release=$(uname -r)
    hostname=$(hostname)
    
    echo "{\"os\":\"$os_name\",\"kernel\":\"$kernel_release\",\"hostname\":\"$hostname\"}"
}

# Pretty print JSON
jq_pretty() {
    if command_exists jq; then
        jq .
    else
        cat
    fi
}

echo "Common library loaded successfully" >&2
