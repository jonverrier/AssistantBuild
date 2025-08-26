#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module rollover-programming.sh
# Weekly file rollover script for StrongAI Assistant programming content.
# Renames files in AssistantIngest/content/inputs/coachnotes directory:
# - xxx.ThisWeek.* files to xxx.YYYYMMDD.* (Monday date of current week)
# - xxx.NextWeek.* files to xxx.ThisWeek.*
# Preserves original file stems and suffixes.
#
# Usage: ./rollover-programming.sh
# Requires: Standard Unix tools (find, date, mv, sed)

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly COACHNOTES_DIR="$SCRIPT_DIR/../AssistantIngest/content/inputs/coachnotes"

function log_info() {
    echo "[INFO] $*" >&2
}

function log_error() {
    echo "[ERROR] $*" >&2
}

function get_monday_date() {
    # Get current date and day of week (0=Sunday, 1=Monday, etc.)
    local current_date=$(date +%Y%m%d)
    local day_of_week=$(date +%u)  # 1=Monday, 7=Sunday
    
    # Calculate days to subtract to get to Monday
    local days_to_subtract=$((day_of_week - 1))
    
    # Get Monday's date
    local monday_date=$(date -d "-${days_to_subtract} days" +%Y%m%d)
    echo "$monday_date"
}

function rename_files() {
    local monday_date=$(get_monday_date)
    
    log_info "Checking for files to rename in: $COACHNOTES_DIR"
    
    if [[ ! -d "$COACHNOTES_DIR" ]]; then
        log_error "Directory not found: $COACHNOTES_DIR"
        return 1
    fi
    
    # Find files matching the patterns
    local thisweek_files=()
    local nextweek_files=()
    
    # Use find to locate files with the patterns
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            thisweek_files+=("$file")
        fi
    done < <(find "$COACHNOTES_DIR" -name "*.ThisWeek.*" -type f -print0 2>/dev/null || true)
    
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            nextweek_files+=("$file")
        fi
    done < <(find "$COACHNOTES_DIR" -name "*.NextWeek.*" -type f -print0 2>/dev/null || true)
    
    # Check if any files were found
    if [[ ${#thisweek_files[@]} -eq 0 && ${#nextweek_files[@]} -eq 0 ]]; then
        log_info "No files found matching .ThisWeek.* or .NextWeek.* patterns"
        return 0
    fi
    
    # Display files that will be renamed
    echo ""
    echo "Files found for renaming:"
    echo "========================"
    
    if [[ ${#thisweek_files[@]} -gt 0 ]]; then
        echo ""
        echo "Files with .ThisWeek.* pattern (will be renamed to .$monday_date.*):"
        for file in "${thisweek_files[@]}"; do
            local basename=$(basename "$file")
            local new_name=$(echo "$basename" | sed "s/\.ThisWeek\./.${monday_date}./")
            echo "  $basename -> $new_name"
        done
    fi
    
    if [[ ${#nextweek_files[@]} -gt 0 ]]; then
        echo ""
        echo "Files with .NextWeek.* pattern (will be renamed to .ThisWeek.*):"
        for file in "${nextweek_files[@]}"; do
            local basename=$(basename "$file")
            local new_name=$(echo "$basename" | sed 's/\.NextWeek\./.ThisWeek./')
            echo "  $basename -> $new_name"
        done
    fi
    
    echo ""
    read -p "Do you want to proceed with these file renames? (Y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "File renaming cancelled by user"
        return 0
    fi
    
    # Perform the renaming operations
    log_info "Starting file renaming operations..."
    
    # Rename .ThisWeek.* files to .YYYYMMDD.*
    for file in "${thisweek_files[@]}"; do
        local dir=$(dirname "$file")
        local basename=$(basename "$file")
        local new_name=$(echo "$basename" | sed "s/\.ThisWeek\./.${monday_date}./")
        local new_path="$dir/$new_name"
        
        log_info "Renaming: $basename -> $new_name"
        mv "$file" "$new_path" || {
            log_error "Failed to rename: $basename"
            return 1
        }
    done
    
    # Rename .NextWeek.* files to .ThisWeek.*
    for file in "${nextweek_files[@]}"; do
        local dir=$(dirname "$file")
        local basename=$(basename "$file")
        local new_name=$(echo "$basename" | sed 's/\.NextWeek\./.ThisWeek./')
        local new_path="$dir/$new_name"
        
        log_info "Renaming: $basename -> $new_name"
        mv "$file" "$new_path" || {
            log_error "Failed to rename: $basename"
            return 1
        }
    done
    
    log_info "File renaming completed successfully"
}

function main() {
    log_info "Starting weekly programming content rollover"
    rename_files
    log_info "Weekly programming content rollover completed"
}

# Execute main function
main "$@"
