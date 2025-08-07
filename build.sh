#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module build.sh
# Multi-package build coordination script for StrongAI Assistant platform.
# Executes npm run build across all package directories in dependency order.
# Ensures proper compilation of TypeScript sources and generation of
# distribution artifacts for the entire monorepo structure.
#
# Usage: ./build.sh
# Requires: npm, package.json with build script in each target directory

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
        echo "Building: $directory"
        # Navigate to directory
        cd "$directory" || continue

        # Run npm run build
        npm run build        
        
        # Go back to original directory
        cd - > /dev/null
    else
        echo "Directory not found: $directory"
    fi
done

echo "All builds completed!"