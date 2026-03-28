@echo off
echo Starting AI Backend...
start cmd /k "python app.py"
echo Starting Cloud Tunnel...
start cmd /k "npx localtunnel --port 5000 --subdomain exam-guard-master-059"
echo Done! Keep these terminal windows open for the mobile app to stay online.
pause
