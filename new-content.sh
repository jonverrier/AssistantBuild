#!/bin/bash
# Copyright (c) 2025 Jon Verrier
#
# @module new-content.sh
# Specialized deployment script for StrongAI Assistant content updates.
# Builds wrapped content in AssistantIngest, updates Assistant package
# dependencies, builds the core library, and deploys the updated Azure Function API.
# Used for content pipeline updates and production deployments.
#
# Usage: ./new-content.sh
# Requires: make, npm, Azure Functions CLI (func), Azure deployment credentials

cd AssistantIngest
make wrapped-CoachNotesContent wrapped-CoachNotesContentLite

cd ..
cd Assistant
npm run install-local
npm run build

cd ..
cd AssistantAzureServer
npm i
npm run build
func azure functionapp publish MotifAssistantApi