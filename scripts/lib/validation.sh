#!/bin/bash

################################################################################
# Wlogout Themes - Validation Library
# Theme validation and integrity checking
################################################################################

set -euo pipefail

if [[ "${_WLOGOUT_VALIDATION_SOURCED:-}" == "true" ]]; then
    return 0
fi
readonly _WLOGOUT_VALIDATION_SOURCED=true

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/logging.sh"

################################################################################
# Theme Validation Functions
################################################################################

# Validate theme directory structure
validate_theme_structure() {
    local theme_dir="$1"
    local errors=0
    
    log_debug "Validating theme structure: $theme_dir"
    
    # Check theme directory exists
    if [ ! -d "$theme_dir" ]; then
        log_error "Theme directory not found: $theme_dir"
        return 1
    fi
    
    # Check required files
    local required_files=("theme.json" "layout.json" "style.css")
    for file in "${required_files[@]}"; do
        if [ ! -f "$theme_dir/$file" ]; then
            log_warning "Missing file: $theme_dir/$file"
            ((errors++))
        fi
    done
    
    # Check icons directory
    if [ ! -d "$theme_dir/icons" ]; then
        log_warning "Missing icons directory: $theme_dir/icons"
        ((errors++))
    else
        # Check for PNG files
        local icon_count
        icon_count=$(find "$theme_dir/icons" -maxdepth 1 -name "*.png" 2>/dev/null | wc -l)
        if [ "$icon_count" -eq 0 ]; then
            log_warning "No PNG icons found in: $theme_dir/icons"
            ((errors++))
        else
            log_debug "Found $icon_count icons"
        fi
    fi
    
    return $errors
}

# Validate theme.json format
validate_theme_json() {
    local theme_json="$1"
    
    if [ ! -f "$theme_json" ]; then
        log_error "Theme JSON not found: $theme_json"
        return 1
    fi
    
    # Check JSON validity
    if ! command_exists jq; then
        log_warning "jq not installed, skipping JSON validation"
        return 0
    fi
    
    if ! jq empty "$theme_json" 2>/dev/null; then
        log_error "Invalid JSON in: $theme_json"
        return 1
    fi
    
    # Check required fields
    local required_fields=("name" "version" "description")
    for field in "${required_fields[@]}"; do
        if ! jq -e ".$field" "$theme_json" &>/dev/null; then
            log_warning "Missing field in theme.json: $field"
        fi
    done
    
    log_debug "Theme JSON is valid"
    return 0
}

# Validate CSS syntax (basic)
validate_css() {
    local css_file="$1"
    
    if [ ! -f "$css_file" ]; then
        log_error "CSS file not found: $css_file"
        return 1
    fi
    
    # Basic checks
    local brace_count
    brace_count=$(grep -o "{" "$css_file" | wc -l)
    local close_count
    close_count=$(grep -o "}" "$css_file" | wc -l)
    
    if [ "$brace_count" -ne "$close_count" ]; then
        log_warning "CSS syntax issue: unmatched braces in $css_file"
        return 1
    fi
    
    log_debug "CSS file looks valid"
    return 0
}

# Validate layout.json
validate_layout_json() {
    local layout_json="$1"
    
    if [ ! -f "$layout_json" ]; then
        log_error "Layout JSON not found: $layout_json"
        return 1
    fi
    
    if ! command_exists jq; then
        log_warning "jq not installed, skipping layout validation"
        return 0
    fi
    
    if ! jq empty "$layout_json" 2>/dev/null; then
        log_error "Invalid JSON in layout: $layout_json"
        return 1
    fi
    
    log_debug "Layout JSON is valid"
    return 0
}

# Validate PNG icons
validate_icons() {
    local icons_dir="$1"
    local required_icons=("logout.png" "shutdown.png" "reboot.png" "suspend.png" "hibernate.png" "lock.png")
    local errors=0
    
    if [ ! -d "$icons_dir" ]; then
        log_error "Icons directory not found: $icons_dir"
        return 1
    fi
    
    for icon in "${required_icons[@]}"; do
        if [ ! -f "$icons_dir/$icon" ]; then
            log_warning "Missing icon: $icons_dir/$icon"
            ((errors++))
        else
            # Check if it's a valid PNG
            if ! file "$icons_dir/$icon" | grep -q "PNG image"; then
                log_warning "Invalid PNG file: $icons_dir/$icon"
                ((errors++))
            fi
        fi
    done
    
    return $errors
}

# Comprehensive theme validation
validate_theme_complete() {
    local theme_name="$1"
    local theme_dir
    theme_dir=$(get_theme_path "$theme_name")
    
    log_info "Validating theme: $theme_name"
    print_separator
    
    local total_errors=0
    
    # Validate structure
    log_debug "Checking structure..."
    if ! validate_theme_structure "$theme_dir"; then
        ((total_errors++))
    fi
    
    # Validate theme.json
    log_debug "Checking theme.json..."
    if ! validate_theme_json "$theme_dir/theme.json"; then
        ((total_errors++))
    fi
    
    # Validate layout.json
    log_debug "Checking layout.json..."
    if ! validate_layout_json "$theme_dir/layout.json"; then
        ((total_errors++))
    fi
    
    # Validate CSS
    log_debug "Checking style.css..."
    if ! validate_css "$theme_dir/style.css"; then
        ((total_errors++))
    fi
    
    # Validate icons
    log_debug "Checking icons..."
    if ! validate_icons "$theme_dir/icons"; then
        ((total_errors++))
    fi
    
    print_separator
    
    if [ "$total_errors" -eq 0 ]; then
        log_success "Theme validation passed"
        return 0
    else
        log_error "Theme validation failed with $total_errors error(s)"
        return 1
    fi
}

echo "Validation library loaded successfully" >&2
