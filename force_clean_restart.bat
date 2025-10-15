@echo off
echo 🧹 FORCE CLEAR ALL CACHE AND RESTART FLUTTER
echo ================================================

echo 1️⃣ Killing all Flutter/Dart processes...
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM dart.exe 2>nul
ping 127.0.0.1 -n 3 > nul

echo 2️⃣ Changing to frontend directory...
cd /d "c:\laragon\www\BPR_Absence\frontend"

echo 3️⃣ Flutter clean (removing build cache)...
flutter clean

echo 4️⃣ Clearing pub cache...
flutter pub cache clean

echo 5️⃣ Getting fresh dependencies...
flutter pub get

echo 6️⃣ Clearing browser cache directories...
rmdir /s /q "build\web" 2>nul
rmdir /s /q ".dart_tool\build" 2>nul

echo 7️⃣ Starting Flutter web with FRESH CACHE...
echo.
echo 📋 TESTING INSTRUCTIONS:
echo    1. Wait for app to fully load
echo    2. Login with: admin@gmail.com / 123456
echo    3. Check browser console for debug messages
echo    4. Look for these messages:
echo       - 🚀 LOGIN_ATTEMPT: Starting login process...
echo       - 🎯 LOGIN_PAGE DEBUG: User role received...
echo       - 🚀 NAVIGATION: About to navigate to...
echo    5. Check final URL: should be /admin/dashboard
echo.

start flutter run -d chrome --web-port 8080 --dart-define=WEB_DEBUG=true

echo.
echo ✅ Flutter starting with fresh cache...
echo 🌐 URL: http://localhost:8080
echo 📝 Open browser console to see debug messages
echo.
pause