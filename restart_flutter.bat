@echo off
echo 🔄 Restarting Flutter Web Server with Clean Cache...
echo.

echo 1️⃣ Stopping any running Flutter processes...
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM dart.exe 2>nul

echo.
echo 2️⃣ Cleaning Flutter cache...
cd /d "c:\laragon\www\BPR_Absence\frontend"
flutter clean

echo.
echo 3️⃣ Getting dependencies...
flutter pub get

echo.
echo 4️⃣ Starting Flutter web server on port 8080...
echo    🌐 URL: http://localhost:8080
echo    📝 Check browser console for debug logs
echo    🔍 Look for "LOGIN_PAGE DEBUG" messages
echo.

start flutter run -d chrome --web-port 8080 --web-browser-flag "--disable-web-security" --web-browser-flag "--disable-features=VizDisplayCompositor"

echo.
echo ✅ Flutter server starting...
echo    📋 Instructions:
echo    1. Wait for app to load
echo    2. Login with admin@gmail.com / 123456
echo    3. Check console logs for routing debug info
echo    4. Check if it goes to admin or user dashboard
echo.
pause