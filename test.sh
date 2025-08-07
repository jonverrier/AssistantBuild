#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module test.sh
# Multi-package test execution script for StrongAI Assistant platform.
# Runs npm test across all defined package directories in the monorepo structure.
# Validates directory existence and provides status reporting for each test suite.
#
# Usage: ./test.sh
# Requires: npm, package.json with test script in each target directory

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
        echo "Testing: $directory"
        # Navigate to directory
        cd "$directory" || continue
        
        # Run npm test
        npm run test
        
        # Go back to original directory
        cd - > /dev/null
    else
        echo "Directory not found: $directory"
    fi
done

echo "All tests completed!"