@echo off
echo ========================================
echo Adding Windows Firewall Rule for BPR Backend
echo ========================================
echo.

echo This will allow incoming connections on port 3000
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator... OK
    echo.
    
    echo Removing old rules (if any)...
    netsh advfirewall firewall delete rule name="BPR Absence Backend" >nul 2>&1
    netsh advfirewall firewall delete rule name="BPR Backend" >nul 2>&1
    netsh advfirewall firewall delete rule name="Node.js: Server-side JavaScript" >nul 2>&1
    echo.
    
    echo Adding new firewall rule...
    netsh advfirewall firewall add rule name="BPR Absence Backend" dir=in action=allow protocol=TCP localport=3000
    
    if %errorlevel% == 0 (
        echo.
        echo ✓ Firewall rule added successfully!
        echo.
        echo Port 3000 is now open for incoming connections.
        echo.
        echo Testing connectivity...
        echo.
        curl -s http://localhost:3000/health
        echo.
        echo.
        echo Next: Try login from mobile again!
    ) else (
        echo.
        echo ✗ Failed to add firewall rule
    )
) else (
    echo ✗ This script must be run as Administrator
    echo.
    echo Right-click this file and select "Run as administrator"
)

echo.
pause
