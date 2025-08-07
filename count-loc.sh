#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module count-loc.sh
# Lines of code analysis script for StrongAI Assistant platform.
# Counts non-whitespace lines in TypeScript source files (.ts/.tsx) across
# all package directories, separating source code from test code. Provides
# comprehensive code metrics for the entire monorepo structure.
#
# Usage: ./count-loc.sh <base_directory>
# Example: ./count-loc.sh /path/to/strongai
# Requires: grep, find, bash with process substitution support

ts_directories=("PromptRepository/src" "Assistant/src" "AssistantAzureServer/src" "AssistantWebApp/src" "AssistantIngest/src")

ts_test_directories=("PromptRepository/test" "Assistant/test" "AssistantAzureServer/test" "AssistantWebApp/test" "AssistantIngest/test")


# Function to count non-whitespace lines in files
count_lines() {
    local dir=$1
    local file_type=$2
    local lines=0
    
    while IFS= read -r file; do
        lines=$((lines + $(grep -cve '^\s*$' "$file")))
    done < <(find "$dir" -type f -name "*.$file_type")
    
    #echo "$file_type files: $lines lines"
    echo "$lines"
}

# Main script
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <base_directory>"
    exit 1
fi

base_dir=$1

if [[ ! -d $base_dir ]]; then
    echo "Error: $base_dir is not a valid directory."
    exit 1
fi

total_ts_lines=0
total_ts_test_lines=0

# Process TypeScript directories
#
echo -e "\nProcessing TypeScript directories..."
for dir in "${ts_directories[@]}"; do
    full_path="$base_dir/$dir"
    if [[ -d $full_path ]]; then
        echo "Checking directory: $full_path"
        line_count=$(count_lines "$full_path" "ts")        
        total_ts_lines=$((total_ts_lines + line_count))   
        line_count=$(count_lines "$full_path" "tsx")        
        total_ts_lines=$((total_ts_lines + line_count))         
    fi
done

# Process TypeScript test directories
#
echo -e "\nProcessing TypeScript test directories..."
for dir in "${ts_test_directories[@]}"; do
    full_path="$base_dir/$dir"
    if [[ -d $full_path ]]; then
        echo "Checking directory: $full_path"
        line_count=$(count_lines "$full_path" "ts")        
        total_ts_test_lines=$((total_ts_test_lines + line_count))   
        line_count=$(count_lines "$full_path" "tsx")        
        total_ts_test_lines=$((total_ts_test_lines + line_count))         
    else
        echo "Directory not found: $full_path"
    fi
done

echo -e "\nFinal Totals:"
echo "Total TypeScript (.ts .tsx) lines: $total_ts_lines"
echo "Total TypeScript test (.ts .tsx) lines: $total_ts_test_lines"

