#!/bin/bash

# Check if a parameter is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <number_of_runs>"
    exit 1
fi

# Check if parameter is a positive number
if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ]; then
    echo "Please provide a positive number as parameter"
    exit 1
fi

# Store the number of runs
N=$1

# Check if Assistant directory exists
if [ ! -d "Assistant" ]; then
    echo "Error: Assistant directory not found"
    exit 1
fi

echo "Running tests $N times in Assistant directory..."

# Loop N times
for ((i=1; i<=N; i++)); do
    echo "Test run $i of $N"
    
    # Navigate to Assistant directory
    cd Assistant || exit 1
    
    # Run npm test
    npm run test
    
    # Go back to original directory
    cd - > /dev/null
done

echo "All test runs completed!" 