@echo off
title BPR Absence - Development Servers
color 0A
echo.
echo ===============================================
echo 🔥 BPR Absence Development Environment
echo ===============================================
echo.
echo Starting servers...
echo.

:: Start Firebase NPM Server in new window
echo 🔥 Starting Firebase NPM Server on port 3000...
start "Firebase NPM Server" cmd /k "cd /d c:\laragon\www\BPR_Absence\backend && echo 🔥 Firebase NPM Server Starting... && npm run firebase-server"

:: Wait a moment for Firebase server to start
timeout /t 3 /nobreak >nul

:: Start Flutter Web Server in new window  
echo 🚀 Starting Flutter Web Server on port 8080...
start "Flutter Web Server" cmd /k "cd /d c:\laragon\www\BPR_Absence\frontend && echo 🚀 Flutter Web Server Starting... && flutter run -d chrome --web-port=8080 --web-hostname=localhost"

echo.
echo ===============================================
echo ✅ Both servers are starting!
echo ===============================================
echo.
echo 🔥 Firebase NPM Server: http://localhost:3000
echo 🚀 Flutter Web App: http://localhost:8080
echo.
echo Press any key to continue...
pause >nul

:: Optional: Open browsers
echo.
echo Opening development environment...
start http://localhost:3000
timeout /t 2 /nobreak >nul
start http://localhost:8080

echo.
echo 🎉 Development environment is ready!
echo.
echo To stop servers:
echo - Close the Firebase NPM Server window
echo - Close the Flutter Web Server window
echo.
pause