@echo off
echo ====================================
echo BPR ABSENCE - ROLE-BASED TEST
echo ====================================
echo.
echo Testing all endpoints for:
echo - USER role
echo - ADMIN role  
echo - SUPER ADMIN role
echo.
echo Credentials will be fetched from Firestore
echo.
pause

cd /d "%~dp0backend"
node test-all-roles.js

echo.
echo ====================================
echo Test completed!
echo ====================================
pause
