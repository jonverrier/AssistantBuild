#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module test-n.sh
# Repeated test execution script for the Assistant package.
# Runs npm test in the Assistant directory N times for reliability testing,
# stress testing, or intermittent failure detection. Validates input parameters
# and directory existence before execution.
#
# Usage: ./test-n.sh <number_of_runs>
# Example: ./test-n.sh 5
# Requires: npm, Assistant directory with package.json test script

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