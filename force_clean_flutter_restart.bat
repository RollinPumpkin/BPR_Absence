@echo off
echo =========================================
echo FORCE CLEAN RESTART - BPR ABSENCE
echo =========================================
echo.

echo 1. Stopping Flutter development server...
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM dart.exe 2>nul

echo 2. Cleaning Flutter build cache...
cd /d "c:\laragon\www\BPR_Absence\frontend"
flutter clean

echo 3. Getting dependencies...
flutter pub get

echo 4. Starting development server with clean cache...
flutter run -d chrome --web-port=8080 --no-web-security --web-browser-flag="--disable-web-security --disable-features=VizDisplayCompositor --user-data-dir=c:\temp\chrome_debug_%RANDOM%"

pause