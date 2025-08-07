#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module git-status.sh
# Multi-repository git status check script for StrongAI Assistant platform.
# Checks git status across all package directories to provide a consolidated
# view of repository states. Useful for identifying uncommitted changes,
# untracked files, and branch status across the monorepo structure.
#
# Usage: ./git-status.sh
# Requires: git, each directory must be a git repository

# Define the array of directories
directories=(
    "AssistantBuild"
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
        echo "Checking: $directory"
        # Navigate to directory
        cd "$directory" || continue

        # Run git status
        git status       
        
        # Go back to original directory
        cd - > /dev/null
    else
        echo "Directory not found: $directory"
    fi
done
