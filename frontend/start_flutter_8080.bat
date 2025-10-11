@echo off
echo 🚀 Starting Flutter App on port 8080...
echo 📱 Flutter Web Server will run on http://localhost:8080
echo.
cd /d "c:\laragon\www\BPR_Absence\frontend"
flutter run -d chrome --web-port=8080 --web-hostname=localhost
pause