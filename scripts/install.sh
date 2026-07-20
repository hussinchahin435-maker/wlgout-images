#!/bin/bash

################################################################################
# Wlogout Icons - Robust Installation Script
# Professional-grade installer for wlogout on Hyprland
# 
# Features:
#   - Dependency checking
#   - Interactive theme selection
#   - Automatic backup and rollback
#   - Comprehensive logging
#   - Error handling with recovery
#
# Author: Senior Linux Developer
# License: MIT
################################################################################

set -euo pipefail

# Script version
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Logging configuration
readonly LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wlogout-installer"
readonly LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
readonly BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wlogout-backups"

# Configuration
readonly WLOGOUT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wlogout"
readonly WLOGOUT_ICONS_DIR="$WLOGOUT_CONFIG_DIR/icons"
readonly HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# State variables
INSTALL_THEME="default"
ADD_HYPRLAND_BINDING=false
BACKUP_EXISTING=true
INTERACTIVE_MODE=true
VERBOSE_MODE=false
DRY_RUN=false

################################################################################
# Utility Functions
################################################################################

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        INFO)
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}✅${NC} $message"
            ;;
        WARNING)
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}❌${NC} $message"
            ;;
        DEBUG)
            [ "$VERBOSE_MODE" = true ] && echo -e "${PURPLE}🐛${NC} $message"
            ;;
    esac
}

error_exit() {
    log ERROR "$1"
    exit 1
}

# Initialize logging
init_logging() {
    mkdir -p "$LOG_DIR"
    {
        echo "==============================================="
        echo "Wlogout Installer - $(date)"
        echo "Version: $SCRIPT_VERSION"
        echo "User: $(whoami)"
        echo "Shell: $SHELL"
        echo "==============================================="
    } >> "$LOG_FILE"
}

# Print header
print_header() {
    clear
    echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║  🚪 Wlogout Icons Installer v$SCRIPT_VERSION    ║${NC}"
    echo -e "${PURPLE}║     Professional Installation Tool    ║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# Print separator
print_separator() {
    echo -e "${CYAN}────��───────────────────────────────────${NC}"
}

################################################################################
# Dependency Checking
################################################################################

check_dependencies() {
    log INFO "Checking system dependencies..."
    print_separator
    
    local missing_deps=()
    local optional_deps=()
    
    # Required dependencies
    local required=("wlogout" "jq")
    for cmd in "${required[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
            log WARNING "Missing required: $cmd"
        else
            log SUCCESS "Found: $cmd ($(command -v $cmd))"
        fi
    done
    
    # Optional dependencies
    local optional=("hyprctl" "systemctl")
    for cmd in "${optional[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            optional_deps+=("$cmd")
            log WARNING "Missing optional: $cmd"
        else
            log SUCCESS "Found: $cmd"
        fi
    done
    
    echo ""
    
    # Handle missing dependencies
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log ERROR "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        log INFO "Installation instructions for missing packages:"
        
        for pkg in "${missing_deps[@]}"; do
            case "$pkg" in
                wlogout)
                    echo -e "  ${YELLOW}wlogout${NC}: sudo dnf install wlogout"
                    ;;
                jq)
                    echo -e "  ${YELLOW}jq${NC}: sudo dnf install jq"
                    ;;
            esac
        done
        
        echo ""
        if ! ask_yes_no "Continue anyway? (not recommended)"; then
            error_exit "Installation cancelled due to missing dependencies"
        fi
    fi
    
    if [ ${#optional_deps[@]} -gt 0 ]; then
        log WARNING "Optional features will be limited: ${optional_deps[*]}"
    fi
    
    echo ""
}

################################################################################
# Theme Selection
################################################################################

detect_available_themes() {
    local themes_dir="$PROJECT_ROOT/themes"
    
    if [ ! -d "$themes_dir" ]; then
        log WARNING "No themes directory found"
        echo "default"
        return
    fi
    
    find "$themes_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

select_theme_interactive() {
    local themes=($(detect_available_themes))
    
    if [ ${#themes[@]} -eq 0 ]; then
        log ERROR "No themes found"
        return 1
    fi
    
    echo ""
    log INFO "Available themes:"
    print_separator
    
    for i in "${!themes[@]}"; do
        echo "  $((i + 1)). ${themes[$i]}"
    done
    
    echo ""
    read -p "Select theme (1-${#themes[@]}): " -r selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#themes[@]} ]; then
        INSTALL_THEME="${themes[$((selection - 1))]}"
        log SUCCESS "Selected theme: $INSTALL_THEME"
    else
        log ERROR "Invalid selection"
        select_theme_interactive
    fi
}

################################################################################
# Backup System
################################################################################

create_backup() {
    if [ "$BACKUP_EXISTING" != true ]; then
        return
    fi
    
    if [ ! -d "$WLOGOUT_CONFIG_DIR" ]; then
        log INFO "No existing wlogout config to backup"
        return
    fi
    
    local backup_timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_path="$BACKUP_DIR/wlogout-backup-$backup_timestamp"
    
    log INFO "Creating backup..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$WLOGOUT_CONFIG_DIR" "$backup_path"
    
    log SUCCESS "Backup created: $backup_path"
    echo "$backup_path" > "$BACKUP_DIR/last-backup"
}

restore_backup() {
    if [ ! -f "$BACKUP_DIR/last-backup" ]; then
        log ERROR "No backup found to restore"
        return 1
    fi
    
    local last_backup=$(cat "$BACKUP_DIR/last-backup")
    
    if [ ! -d "$last_backup" ]; then
        log ERROR "Backup directory not found: $last_backup"
        return 1
    fi
    
    log INFO "Restoring from: $last_backup"
    
    if [ -d "$WLOGOUT_CONFIG_DIR" ]; then
        rm -rf "$WLOGOUT_CONFIG_DIR"
    fi
    
    cp -r "$last_backup" "$WLOGOUT_CONFIG_DIR"
    log SUCCESS "Backup restored successfully"
}

################################################################################
# Installation Functions
################################################################################

create_directories() {
    log INFO "Creating required directories..."
    
    [ "$DRY_RUN" = true ] && log DEBUG "[DRY RUN] Would create: $WLOGOUT_CONFIG_DIR"
    [ "$DRY_RUN" = false ] && mkdir -p "$WLOGOUT_CONFIG_DIR"
    
    [ "$DRY_RUN" = true ] && log DEBUG "[DRY RUN] Would create: $WLOGOUT_ICONS_DIR"
    [ "$DRY_RUN" = false ] && mkdir -p "$WLOGOUT_ICONS_DIR"
    
    log SUCCESS "Directories created"
}

install_theme() {
    log INFO "Installing theme: $INSTALL_THEME"
    print_separator
    
    local theme_path="$PROJECT_ROOT/themes/$INSTALL_THEME"
    
    if [ ! -d "$theme_path" ]; then
        error_exit "Theme not found: $theme_path"
    fi
    
    # Copy icons
    if [ -d "$theme_path/icons" ]; then
        log INFO "Copying icons..."
        [ "$DRY_RUN" = false ] && cp "$theme_path/icons"/*.png "$WLOGOUT_ICONS_DIR/" 2>/dev/null || true
        
        local icon_count=$(find "$WLOGOUT_ICONS_DIR" -name "*.png" 2>/dev/null | wc -l)
        log SUCCESS "Installed $icon_count icons"
    fi
    
    # Copy layout
    if [ -f "$theme_path/layout.json" ]; then
        log INFO "Copying layout configuration..."
        [ "$DRY_RUN" = false ] && cp "$theme_path/layout.json" "$WLOGOUT_CONFIG_DIR/layout"
        log SUCCESS "Layout installed"
    fi
    
    # Copy style
    if [ -f "$theme_path/style.css" ]; then
        log INFO "Copying style sheet..."
        [ "$DRY_RUN" = false ] && cp "$theme_path/style.css" "$WLOGOUT_CONFIG_DIR/style.css"
        log SUCCESS "Style sheet installed"
    fi
    
    echo ""
}

verify_installation() {
    log INFO "Verifying installation..."
    print_separator
    
    local errors=0
    
    # Check directories
    if [ ! -d "$WLOGOUT_CONFIG_DIR" ]; then
        log ERROR "Config directory not created: $WLOGOUT_CONFIG_DIR"
        ((errors++))
    else
        log SUCCESS "Config directory OK"
    fi
    
    # Check icons
    local icon_count=$(find "$WLOGOUT_ICONS_DIR" -name "*.png" 2>/dev/null | wc -l)
    if [ "$icon_count" -eq 0 ]; then
        log ERROR "No icons found in: $WLOGOUT_ICONS_DIR"
        ((errors++))
    else
        log SUCCESS "Found $icon_count icons"
    fi
    
    # Check configuration files
    if [ ! -f "$WLOGOUT_CONFIG_DIR/layout" ]; then
        log ERROR "Layout file not found"
        ((errors++))
    else
        log SUCCESS "Layout file OK"
    fi
    
    if [ ! -f "$WLOGOUT_CONFIG_DIR/style.css" ]; then
        log ERROR "Style file not found"
        ((errors++))
    else
        log SUCCESS "Style file OK"
    fi
    
    echo ""
    
    if [ $errors -gt 0 ]; then
        return 1
    fi
    
    return 0
}

################################################################################
# Hyprland Integration
################################################################################

configure_hyprland() {
    if [ "$ADD_HYPRLAND_BINDING" != true ]; then
        log INFO "Skipping Hyprland configuration"
        return
    fi
    
    log INFO "Configuring Hyprland..."
    print_separator
    
    if [ ! -f "$HYPRLAND_CONFIG" ]; then
        log WARNING "Hyprland config not found: $HYPRLAND_CONFIG"
        return
    fi
    
    local binding="bind = SUPER, X, exec, wlogout"
    
    if grep -q "$binding" "$HYPRLAND_CONFIG"; then
        log INFO "Hyprland binding already exists"
        return
    fi
    
    log INFO "Adding Hyprland key binding..."
    
    if [ "$DRY_RUN" = false ]; then
        echo "" >> "$HYPRLAND_CONFIG"
        echo "# Wlogout binding (added by installer)" >> "$HYPRLAND_CONFIG"
        echo "$binding" >> "$HYPRLAND_CONFIG"
    else
        log DEBUG "[DRY RUN] Would add: $binding"
    fi
    
    log SUCCESS "Hyprland binding added"
    log INFO "Reload with: ${CYAN}hyprctl reload${NC}"
    
    echo ""
}

################################################################################
# Interactive Prompts
################################################################################

ask_yes_no() {
    local prompt="$1"
    local response
    
    while true; do
        read -p "$prompt (y/n): " -r response
        case "$response" in
            [yY][eE][sS]|[yY])
                return 0
                ;;
            [nN][oO]|[nN])
                return 1
                ;;
            *)
                echo "Please answer yes or no"
                ;;
        esac
    done
}

interactive_setup() {
    if [ "$INTERACTIVE_MODE" != true ]; then
        return
    fi
    
    echo ""
    print_separator
    log INFO "Installation Options"
    print_separator
    echo ""
    
    # Theme selection
    if ask_yes_no "Select theme interactively?"; then
        select_theme_interactive
    fi
    
    # Hyprland binding
    if ask_yes_no "Add Hyprland key binding (Super+X)?"; then
        ADD_HYPRLAND_BINDING=true
    fi
    
    # Backup
    if ask_yes_no "Backup existing configuration?"; then
        BACKUP_EXISTING=true
    fi
    
    echo ""
}

################################################################################
# Usage and Help
################################################################################

show_help() {
    cat << EOF
${PURPLE}Usage:${NC} $(basename "$0") [OPTIONS]

${PURPLE}Options:${NC}
  -t, --theme THEME         Select installation theme (default: default)
  -y, --yes                 Non-interactive mode (auto-confirm)
  -n, --dry-run             Show what would be done without making changes
  --skip-backup             Don't backup existing configuration
  --add-hyprland            Add Super+X binding to Hyprland
  -v, --verbose             Enable verbose output
  -h, --help                Show this help message

${PURPLE}Examples:${NC}
  # Interactive installation
  $(basename "$0")

  # Install specific theme
  $(basename "$0") --theme nord

  # Non-interactive installation
  $(basename "$0") --yes --theme dracula

  # Preview changes
  $(basename "$0") --dry-run

${PURPLE}Available Themes:${NC}
EOF
    
    detect_available_themes | sed 's/^/  - /'
    
    echo ""
    echo "${PURPLE}Logs:${NC} $LOG_FILE"
}

################################################################################
# Main Installation Flow
################################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--theme)
                INSTALL_THEME="$2"
                shift 2
                ;;
            -y|--yes)
                INTERACTIVE_MODE=false
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-backup)
                BACKUP_EXISTING=false
                shift
                ;;
            --add-hyprland)
                ADD_HYPRLAND_BINDING=true
                shift
                ;;
            -v|--verbose)
                VERBOSE_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log ERROR "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Initialize
    init_logging
    print_header
    
    if [ "$DRY_RUN" = true ]; then
        log WARNING "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    # Execution steps
    check_dependencies
    interactive_setup
    create_backup
    create_directories
    install_theme
    
    if verify_installation; then
        log SUCCESS "Verification passed"
    else
        log ERROR "Verification failed"
        
        if ask_yes_no "Restore from backup?"; then
            restore_backup
        fi
        
        error_exit "Installation verification failed"
    fi
    
    configure_hyprland
    
    # Summary
    print_separator
    echo -e "${GREEN}✨ Installation completed successfully!${NC}"
    echo ""
    log INFO "Summary:"
    echo "  Theme:      $INSTALL_THEME"
    echo "  Config Dir: $WLOGOUT_CONFIG_DIR"
    echo "  Icons Dir:  $WLOGOUT_ICONS_DIR"
    echo ""
    
    if [ "$DRY_RUN" = false ]; then
        log INFO "Next steps:"
        echo "  1. Run wlogout: ${CYAN}wlogout${NC}"
        echo "  2. Reload Hyprland: ${CYAN}hyprctl reload${NC}"
        echo "  3. View logs: ${CYAN}tail -f $LOG_FILE${NC}"
    fi
    
    echo ""
    log SUCCESS "Installation log: $LOG_FILE"
}

# Run main
main "$@"
