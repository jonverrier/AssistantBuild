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
# Usage: ./new-programming.sh
# Requires: make, npm, Azure Functions CLI (func), Azure deployment credentials


cd AssistantIngest
make wrapped-CoachNotesProgramming

cd ..
cd Assistant
npm run install-local
npm run build

cd ..
cd AssistantAzureServer
npm i
npm run build
func azure functionapp publish MotifAssistantApi