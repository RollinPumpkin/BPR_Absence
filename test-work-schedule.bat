@echo off
echo ============================================
echo   Work Schedule Feature - Quick Test
echo ============================================
echo.

echo [1/3] Starting Backend Server...
cd backend
start cmd /k "npm start"
timeout /t 3 /nobreak >nul

echo [2/3] Starting Frontend...
cd ..\frontend
start cmd /k "flutter run -d chrome --web-port=8080"
timeout /t 5 /nobreak >nul

echo [3/3] Opening Test Guide...
start http://localhost:8080/#/admin/employees
echo.
echo ============================================
echo   Servers Started!
echo ============================================
echo.
echo Backend:  http://localhost:3000
echo Frontend: http://localhost:8080
echo.
echo Test Steps:
echo 1. Login as admin (admin@bpr.com / admin123)
echo 2. Click any employee card
echo 3. Click Edit button
echo 4. Scroll to "Work Schedule" section
echo 5. Set work times and threshold
echo 6. Click Save
echo.
echo Press any key to exit...
pause >nul
