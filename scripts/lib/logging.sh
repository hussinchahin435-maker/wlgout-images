#!/bin/bash

################################################################################
# Wlogout Themes - Logging Library
# Centralized logging infrastructure
################################################################################

set -euo pipefail

if [[ "${_WLOGOUT_LOGGING_SOURCED:-}" == "true" ]]; then
    return 0
fi
readonly _WLOGOUT_LOGGING_SOURCED=true

# Source common library first
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

################################################################################
# Logging Setup
################################################################################

readonly LOG_DIR="${WLOGOUT_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/wlogout-installer}"
readonly LOG_FILE="${LOG_FILE:-$LOG_DIR/install-$(get_timestamp_file).log}"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

################################################################################
# Logging Functions
################################################################################

# Initialize logging
init_logging() {
    local script_name="${1:-unknown}"
    
    {
        echo "==============================================="
        echo "Wlogout Installer - $(get_timestamp)"
        echo "Script: $script_name"
        echo "Version: $SCRIPT_VERSION"
        echo "User: $(whoami)"
        echo "Shell: $SHELL"
        echo "==============================================="
    } >> "$LOG_FILE"
}

# Log with level
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(get_timestamp)
    
    # Write to log file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Print to console with colors
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
            if is_verbose; then
                echo -e "${PURPLE}🐛${NC} $message"
            fi
            ;;
        TRACE)
            if is_verbose; then
                echo -e "${CYAN}→${NC} $message"
            fi
            ;;
    esac
}

# Logging shortcuts
log_info() { log INFO "$@"; }
log_success() { log SUCCESS "$@"; }
log_warning() { log WARNING "$@"; }
log_error() { log ERROR "$@"; }
log_debug() { log DEBUG "$@"; }
log_trace() { log TRACE "$@"; }

# Error exit with logging
error_exit() {
    log_error "$1"
    exit 1
}

# Assert condition
assert() {
    local condition="$1"
    local message="${2:-Assertion failed: $condition}"
    
    if ! eval "$condition"; then
        error_exit "$message"
    fi
log_debug "Assertion passed: $condition"
}

# Print header
print_header() {
    echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║  🚪 Wlogout Themes - $SCRIPT_VERSION          ║${NC}"
    echo -e "${PURPLE}║     Professional Installation Tool    ║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# Print separator
print_separator() {
    echo -e "${CYAN}────────────────────────────────────────${NC}"
}

# Print section
print_section() {
    echo ""
    print_separator
    echo -e "${BLUE}$1${NC}"
    print_separator
    echo ""
}

# Print table header
print_table_header() {
    local -a headers=("$@")
    local header_line
    
    printf "${BLUE}"
    for header in "${headers[@]}"; do
        printf "%-25s" "$header"
    done
    printf "${NC}\n"
    
    # Separator
    printf "─%.0s" {1..75}
    printf "\n"
}

# Print table row
print_table_row() {
    local -a values=("$@")
    
    for value in "${values[@]}"; do
        printf "%-25s" "$value"
    done
    printf "\n"
}

# Create spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    
    while kill -0 $pid 2>/dev/null; do
        for i in "${spinner[@]}"; do
            echo -ne "\r$i"
            sleep $delay
        done
    done
    echo -ne "\r${GREEN}✅${NC}\n"
}

# Log and execute command
log_exec() {
    local cmd="$*"
    log_debug "Executing: $cmd"
    
    if is_dry_run; then
        log_trace "[DRY RUN] $cmd"
        return 0
    fi
    
    eval "$cmd"
}

# Get log file path
get_log_file() {
    echo "$LOG_FILE"
}

echo "Logging library loaded successfully" >&2
