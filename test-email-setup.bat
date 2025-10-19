@echo off
echo 🧪 BPR Absence Email Service Test
echo ================================
echo.

echo 📂 Opening Gmail Setup Guide...
start gmail-setup-guide.html
echo.

echo ⏳ Waiting 5 seconds for you to review the guide...
timeout /t 5 /nobreak > nul
echo.

echo 🔄 Testing email service configuration...
cd backend
node test-email-service.js

echo.
echo 📱 After email test passes, you can test the Flutter app:
echo    1. Open Flutter app
echo    2. Go to Forgot Password
echo    3. Enter: septapuma@gmail.com
echo    4. Check Gmail inbox for reset email
echo    5. Click reset link to verify app integration
echo.

pause