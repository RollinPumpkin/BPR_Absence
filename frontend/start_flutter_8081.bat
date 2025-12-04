@echo off
echo ====================================
echo Starting Flutter on Port 8081
echo ====================================
echo.
echo If port 8080 is busy, using 8081 instead
echo.

cd /d "%~dp0"

flutter run -d chrome --web-port 8081

pause
