#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module new-programming.sh
# Specialized deployment script for StrongAI Assistant programming content updates.
# Builds wrapped programming content in AssistantIngest, 
# updates Assistant package dependencies, builds the core library, and deploys the 
# updated Azure Function API.
# Used for content pipeline updates and production deployments.
#
# Usage: ./new-programming.sh [options]
# Options:
#   -v, --verbose    Enable verbose output
#   -h, --help       Show this help message
# Requires: make, npm, Azure Functions CLI (func), Azure deployment credentials

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Default values
VERBOSE=false
QUIET=false

# Functions
function usage() {
    echo "Usage: $0 [options]"
    echo "  -v, --verbose    Enable verbose output"
    echo "  -q, --quiet      Suppress non-essential output"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "This script builds wrapped programming content in AssistantIngest,"
    echo "updates Assistant package dependencies, builds the core library,"
    echo "and deploys the updated Azure Function API."
    exit 2
}

function log_info() {
    if [[ "$QUIET" != "true" ]]; then
        echo "[INFO] $*" >&2
    fi
}

function log_error() {
    echo "[ERROR] $*" >&2
}

function log_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[VERBOSE] $*" >&2
    fi
}

function validate_environment() {
    log_info "Validating environment..."
    
    # Check if we're in the right directory structure
    if [[ ! -d "$PROJECT_ROOT/AssistantIngest" ]]; then
        log_error "AssistantIngest directory not found. Are you in the correct project root?"
        exit 1
    fi
    
    if [[ ! -d "$PROJECT_ROOT/Assistant" ]]; then
        log_error "Assistant directory not found. Are you in the correct project root?"
        exit 1
    fi
    
    if [[ ! -d "$PROJECT_ROOT/AssistantAzureServer" ]]; then
        log_error "AssistantAzureServer directory not found. Are you in the correct project root?"
        exit 1
    fi
    
    # Check required tools
    if ! command -v make &> /dev/null; then
        log_error "make command not found. Please install make."
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        log_error "npm command not found. Please install Node.js and npm."
        exit 1
    fi
    
    if ! command -v func &> /dev/null; then
        log_error "Azure Functions CLI (func) not found. Please install Azure Functions Core Tools."
        exit 1
    fi
    
    log_info "Environment validation completed successfully"
}

function build_ingest_content() {
    log_info "Building wrapped programming content in AssistantIngest..."
    
    local ingest_dir="$PROJECT_ROOT/AssistantIngest"
    cd "$ingest_dir" || {
        log_error "Failed to change to AssistantIngest directory"
        exit 1
    }
    
    log_verbose "Running: make wrapped-CoachNotesProgramming"
    
    # Capture make output and display it cleanly
    local make_output
    if make_output=$(make wrapped-CoachNotesProgramming 2>&1); then
        if [[ "$VERBOSE" == "true" ]]; then
            # Display make output with proper formatting in verbose mode
            echo "=== Makefile Output ===" >&2
            echo "$make_output" | sed 's/^/  /' >&2
            echo "=== End Makefile Output ===" >&2
        else
            # In normal mode, just show a summary
            local line_count=$(echo "$make_output" | wc -l)
            log_info "Makefile completed successfully ($line_count lines of output)"
        fi
        log_info "Successfully built wrapped programming content"
    else
        log_error "Failed to build wrapped programming content"
        echo "=== Makefile Error Output ===" >&2
        echo "$make_output" | sed 's/^/  /' >&2
        echo "=== End Makefile Error Output ===" >&2
        exit 1
    fi
}

function build_assistant_package() {
    log_info "Building Assistant package..."
    
    local assistant_dir="$PROJECT_ROOT/Assistant"
    cd "$assistant_dir" || {
        log_error "Failed to change to Assistant directory"
        exit 1
    }
    
    log_verbose "Installing local dependencies..."
    local npm_output
    if npm_output=$(npm run install-local 2>&1); then
        if [[ "$VERBOSE" == "true" ]]; then
            log_verbose "npm install-local output:"
            echo "$npm_output" | sed 's/^/  /' >&2
        fi
        log_info "Successfully installed local dependencies"
    else
        log_error "Failed to install local dependencies"
        echo "=== npm install-local Error Output ===" >&2
        echo "$npm_output" | sed 's/^/  /' >&2
        echo "=== End npm Error Output ===" >&2
        exit 1
    fi
    
    log_verbose "Building Assistant package..."
    if npm_output=$(npm run build 2>&1); then
        if [[ "$VERBOSE" == "true" ]]; then
            log_verbose "npm build output:"
            echo "$npm_output" | sed 's/^/  /' >&2
        fi
        log_info "Successfully built Assistant package"
    else
        log_error "Failed to build Assistant package"
        echo "=== npm build Error Output ===" >&2
        echo "$npm_output" | sed 's/^/  /' >&2
        echo "=== End npm Error Output ===" >&2
        exit 1
    fi
}

function build_and_deploy_azure_server() {
    log_info "Building and deploying Azure Server..."
    
    local server_dir="$PROJECT_ROOT/AssistantAzureServer"
    cd "$server_dir" || {
        log_error "Failed to change to AssistantAzureServer directory"
        exit 1
    }
    
    log_verbose "Installing dependencies..."
    local npm_output
    if npm_output=$(npm i 2>&1); then
        if [[ "$VERBOSE" == "true" ]]; then
            log_verbose "npm install output:"
            echo "$npm_output" | sed 's/^/  /' >&2
        fi
        log_info "Successfully installed Azure Server dependencies"
    else
        log_error "Failed to install Azure Server dependencies"
        echo "=== npm install Error Output ===" >&2
        echo "$npm_output" | sed 's/^/  /' >&2
        echo "=== End npm Error Output ===" >&2
        exit 1
    fi
    
    log_verbose "Building Azure Server..."
    if npm_output=$(npm run build 2>&1); then
        if [[ "$VERBOSE" == "true" ]]; then
            log_verbose "npm build output:"
            echo "$npm_output" | sed 's/^/  /' >&2
        fi
        log_info "Successfully built Azure Server"
    else
        log_error "Failed to build Azure Server"
        echo "=== npm build Error Output ===" >&2
        echo "$npm_output" | sed 's/^/  /' >&2
        echo "=== End npm Error Output ===" >&2
        exit 1
    fi
    
    log_verbose "Deploying to Azure Function App: MotifAssistantApi"
    local func_output
    if func_output=$(func azure functionapp publish MotifAssistantApi 2>&1); then
        if [[ "$VERBOSE" == "true" ]]; then
            log_verbose "Azure deployment output:"
            echo "$func_output" | sed 's/^/  /' >&2
        fi
        log_info "Successfully deployed to Azure Function App"
    else
        log_error "Failed to deploy to Azure Function App"
        echo "=== Azure Deployment Error Output ===" >&2
        echo "$func_output" | sed 's/^/  /' >&2
        echo "=== End Azure Error Output ===" >&2
        exit 1
    fi
}

function main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done
    
    log_info "Starting StrongAI Assistant programming content deployment..."
    log_verbose "Project root: $PROJECT_ROOT"
    
    # Validate environment before starting
    validate_environment
    
    # Build content pipeline
    build_ingest_content
    
    # Build core library
    build_assistant_package
    
    # Build and deploy Azure server
    build_and_deploy_azure_server
    
    log_info "Programming content deployment completed successfully!"
}

# Execute main function with all arguments
main "$@"