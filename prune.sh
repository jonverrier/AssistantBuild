#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module prune.sh
# Multi-package dependency pruning script for StrongAI Assistant platform.
# Removes extraneous packages from node_modules across all package directories
# using npm prune. Helps maintain clean dependency trees and reduce disk usage.
#
# Usage: ./prune.sh
# Requires: npm, package.json in each target directory

# Define the array of directories
directories=(
    "PromptRepository"
    "Assistant"
    "AssistantAzureServer"
    "AssistantWebApp"
    "AssistantIngest"
    # Add more directories as needed
)

# Loop through the directories array
for directory in "${directories[@]}"; do
    # Check if directory exists
    if [ -d "$directory" ]; then
        echo "Pruning dependencies in: $directory"
        # Navigate to directory
        cd "$directory" || continue
        
        # Run npm prune
        npm prune
        
        # Go back to original directory
        cd - > /dev/null
    else
        echo "Directory not found: $directory"
    fi
done

echo "All pruning completed!"