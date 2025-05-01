#!/bin/bash

# Define the array of directories
directories=(
    "PromptRepository"
    "Assistant"
    "AssistantAzureServer"
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