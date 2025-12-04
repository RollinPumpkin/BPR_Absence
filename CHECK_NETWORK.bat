@echo off
echo ========================================
echo BPR Absence - Network Diagnostic Tool
echo ========================================
echo.

echo [1/5] Checking your IP address...
echo.
ipconfig | findstr /i "IPv4"
echo.

echo [2/5] Checking if backend server is running...
echo.
netstat -ano | findstr ":3000"
if %errorlevel% == 0 (
    echo ✓ Backend server is running on port 3000
) else (
    echo ✗ Backend server is NOT running on port 3000
    echo   Please run: cd backend ^& node server.js
)
echo.

echo [3/5] Checking Windows Firewall rules...
echo.
netsh advfirewall firewall show rule name=all | findstr /i "3000"
echo.

echo [4/5] Testing localhost connection...
echo.
curl -s http://localhost:3000/health
if %errorlevel% == 0 (
    echo.
    echo ✓ Localhost connection OK
) else (
    echo ✗ Cannot connect to localhost:3000
)
echo.

echo [5/5] Testing network IP connection...
echo.
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%a
    goto :found
)
:found
set IP=%IP: =%
echo Testing: http://%IP%:3000/health
curl -s http://%IP%:3000/health
if %errorlevel% == 0 (
    echo.
    echo ✓ Network IP connection OK
) else (
    echo ✗ Cannot connect via network IP
)
echo.

echo ========================================
echo DIAGNOSTIC COMPLETE
echo ========================================
echo.
echo Next steps if issues found:
echo 1. Make sure backend is running: cd backend ^& node server.js
echo 2. Add firewall rule: netsh advfirewall firewall add rule name="BPR Backend" dir=in action=allow protocol=TCP localport=3000
echo 3. Make sure phone and PC are on same WiFi network
echo 4. Update IP in: frontend\lib\data\constants\server_config.dart
echo.
pause
