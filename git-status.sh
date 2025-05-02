#!/bin/bash

# Define the array of directories
directories=(
    "AssistantBuild"
    "PromptRepository"
    "Assistant"
    "AssistantAzureServer"
    "AssistantWebApp"
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
