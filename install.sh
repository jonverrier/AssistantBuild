#!/bin/bash

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
        echo "Installing dependencies in: $directory"
        # Navigate to directory
        cd "$directory" || continue
        
        # Run npm install
        npm install
        npm run install-local || true
        
        # Go back to original directory
        cd - > /dev/null
    else
        echo "Directory not found: $directory"
    fi
done

echo "All installations completed!"