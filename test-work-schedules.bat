@echo off
echo ========================================
echo  Testing Work Schedules Feature
echo ========================================
echo.

REM Start Backend Server
echo [1/4] Starting backend server...
start "BPR Backend Server" cmd /k "cd c:\laragon\www\BPR_Absence\backend && npm start"
timeout /t 5 /nobreak > nul

echo.
echo [2/4] Testing API Endpoints...
echo.

REM Test GET all schedules
echo Testing: GET /api/work-schedules
curl -X GET http://localhost:3000/api/work-schedules ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -H "Content-Type: application/json"

echo.
echo.

REM Test GET specific role
echo Testing: GET /api/work-schedules/employee
curl -X GET http://localhost:3000/api/work-schedules/employee ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -H "Content-Type: application/json"

echo.
echo.
echo [3/4] Backend server is running on http://localhost:3000
echo.
echo [4/4] Available endpoints:
echo   - GET    /api/work-schedules
echo   - GET    /api/work-schedules/:role
echo   - PUT    /api/work-schedules/:role
echo   - POST   /api/work-schedules
echo   - DELETE /api/work-schedules/:role
echo   - POST   /api/attendance/clock-in
echo   - POST   /api/attendance/clock-out
echo.
echo ========================================
echo  Ready for testing!
echo ========================================
echo.
echo Press any key to stop backend server...
pause > nul

REM Kill backend server
taskkill /FI "WindowTitle eq BPR Backend Server*" /T /F > nul 2>&1
