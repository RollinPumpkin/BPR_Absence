@echo off
echo ========================================
echo Checking for Terminated Users
echo ========================================
echo.

cd backend
node cleanup-terminated-users.js --dry-run

echo.
echo ========================================
echo.
echo To permanently delete terminated users:
echo   1. Review the list above
echo   2. Run: cleanup-delete.bat
echo.
pause
