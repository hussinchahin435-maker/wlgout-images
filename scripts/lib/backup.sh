#!/bin/bash

################################################################################
# Wlogout Themes - Backup and Restore Library
# Safe backup and restoration of user configurations
################################################################################

set -euo pipefail

if [[ "${_WLOGOUT_BACKUP_SOURCED:-}" == "true" ]]; then
    return 0
fi
readonly _WLOGOUT_BACKUP_SOURCED=true

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/logging.sh"

################################################################################
# Backup Functions
################################################################################

# Create backup of existing wlogout config
create_backup() {
    if [ ! -d "$WLOGOUT_CONFIG_DIR" ]; then
        log_debug "No existing wlogout config to backup"
        return 0
    fi
    
    local backup_name="backup-$(get_timestamp_file)"
    local backup_path="$WLOGOUT_BACKUP_DIR/$backup_name"
    
    log_info "Creating backup..."
    
    if is_dry_run; then
        log_trace "[DRY RUN] cp -r $WLOGOUT_CONFIG_DIR -> $backup_path"
        return 0
    fi
    
    mkdir -p "$WLOGOUT_BACKUP_DIR"
    cp -r "$WLOGOUT_CONFIG_DIR" "$backup_path"
    
    # Store backup path
    echo "$backup_path" > "$WLOGOUT_BACKUP_DIR/last-backup"
    
    log_success "Backup created: $backup_path"
    echo "$backup_path"
}

# Get last backup directory
get_last_backup() {
    if [ ! -f "$WLOGOUT_BACKUP_DIR/last-backup" ]; then
        return 1
    fi
    
    cat "$WLOGOUT_BACKUP_DIR/last-backup"
}

# List available backups
list_backups() {
    if [ ! -d "$WLOGOUT_BACKUP_DIR" ]; then
        return 1
    fi
    
    find "$WLOGOUT_BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -name "backup-*" -exec basename {} \; | sort -r
}

# Restore from backup
restore_backup() {
    local backup_path="${1:-}"
    
    if [ -z "$backup_path" ]; then
        backup_path=$(get_last_backup)
    fi
    
    if [ ! -d "$backup_path" ]; then
        log_error "Backup directory not found: $backup_path"
        return 1
    fi
    
    log_info "Restoring from: $backup_path"
    
    if is_dry_run; then
        log_trace "[DRY RUN] Restore from $backup_path"
        return 0
    fi
    
    # Remove current config
    if [ -d "$WLOGOUT_CONFIG_DIR" ]; then
        rm -rf "$WLOGOUT_CONFIG_DIR"
    fi
    
    # Restore backup
    cp -r "$backup_path" "$WLOGOUT_CONFIG_DIR"
    
    log_success "Backup restored successfully"
}

# Create manifest file
create_manifest() {
    local theme_name="$1"
    local theme_source="$2"
    local installed_symlinks="${3:-}"
    local backup_path="${4:-}"
    local hyprland_binding="${5:-false}"
    local hyprland_config="${6:-}"
    
    local manifest_content
    
    manifest_content=$(
        cat <<EOF
{
  "schema_version": "1.0.0",
  "installed_at": "$(get_timestamp)",
  "installed_by": "install.sh v$SCRIPT_VERSION",
  "user": "$(whoami)",
  "system": $(get_system_info),
  "theme": {
    "name": "$theme_name",
    "source": "$theme_source",
    "version": "1.0.0"
  },
  "installation": {
    "config_dir": "$WLOGOUT_CONFIG_DIR",
    "symlinks": $installed_symlinks
  },
  "backup": {
    "created": $([ -n "$backup_path" ] && echo "true" || echo "false"),
    "path": "${backup_path:-null}",
    "timestamp": "$(get_timestamp)"
  },
  "hyprland": {
    "binding_added": $hyprland_binding,
    "config_file": "${hyprland_config:-null}"
  },
  "verification": {
    "passed": false,
    "checks": []
  }
}
EOF
    )
    
    if is_dry_run; then
        log_trace "[DRY RUN] Create manifest at: $WLOGOUT_MANIFEST_FILE"
        log_trace "Manifest content: $manifest_content"
        return 0
    fi
    
    mkdir -p "$WLOGOUT_STATE_DIR"
    echo "$manifest_content" > "$WLOGOUT_MANIFEST_FILE"
    
    log_success "Manifest created: $WLOGOUT_MANIFEST_FILE"
}

# Read manifest value
read_manifest() {
    local key="$1"
    
    if [ ! -f "$WLOGOUT_MANIFEST_FILE" ]; then
        return 1
    fi
    
    if command_exists jq; then
        jq -r "$key // empty" "$WLOGOUT_MANIFEST_FILE" 2>/dev/null || return 1
    else
        # Fallback if jq not available
        grep "\"$key\"" "$WLOGOUT_MANIFEST_FILE" | head -1 || return 1
    fi
}

# Update manifest verification status
update_manifest_verification() {
    local passed="$1"
    local checks=("${@:2}")
    
    if [ ! -f "$WLOGOUT_MANIFEST_FILE" ]; then
        return 1
    fi
    
    if is_dry_run; then
        log_trace "[DRY RUN] Update manifest verification status"
        return 0
    fi
    
    if command_exists jq; then
        local checks_json
        checks_json=$(printf '%s\n' "${checks[@]}" | jq -R . | jq -s .)
        
        jq --arg passed "$passed" --argjson checks "$checks_json" \
            '.verification.passed = ($passed == "true") | .verification.checks = $checks' \
            "$WLOGOUT_MANIFEST_FILE" > "${WLOGOUT_MANIFEST_FILE}.tmp" \
            && mv "${WLOGOUT_MANIFEST_FILE}.tmp" "$WLOGOUT_MANIFEST_FILE"
    fi
}

# Remove manifest
remove_manifest() {
    if is_dry_run; then
        log_trace "[DRY RUN] Remove manifest: $WLOGOUT_MANIFEST_FILE"
        return 0
    fi
    
    if [ -f "$WLOGOUT_MANIFEST_FILE" ]; then
        rm -f "$WLOGOUT_MANIFEST_FILE"
        log_debug "Manifest removed"
    fi
}

echo "Backup library loaded successfully" >&2
