#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module git-pull.sh
# Multi-repository git pull script for StrongAI Assistant platform.
# Performs git pull operations across all package directories to synchronize
# the latest changes from remote repositories. Ensures all packages are
# updated to the latest commits from their respective default branches.
#
# Usage: ./git-pull.sh
# Requires: git, each directory must be a git repository with remote tracking

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
        echo "Pulling: $directory"
        # Navigate to directory
        cd "$directory" || continue

        # Run git pull
        git pull       
        
        # Go back to original directory
        cd - > /dev/null
    else
        echo "Directory not found: $directory"
    fi
done
