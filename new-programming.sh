
cd AssistantIngest
make wrapped-CoachNotesProgramming

cd ..
cd Assistant
npm run install-local
npm run build

cd ..
cd AssistantAzureServer
npm i
func azure functionapp publish MotifAssistantApi
