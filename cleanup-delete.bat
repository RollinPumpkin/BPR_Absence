@echo off
echo ========================================
echo WARNING: DELETING TERMINATED USERS
echo ========================================
echo.
echo This will PERMANENTLY delete all users
echo with status 'terminated' from Firestore.
echo.
echo This action CANNOT be undone!
echo.
pause

cd backend
node cleanup-terminated-users.js --delete

echo.
echo ========================================
echo Cleanup Complete!
echo ========================================
echo.
pause
