@echo off
echo ========================================
echo   DATA FETCH TEST SCRIPT
echo ========================================
echo.
echo Starting data fetch test...
echo This will test if all data is properly fetched from database to frontend
echo.

cd frontend

echo Running test...
dart run test_data_fetch.dart

echo.
echo ========================================
echo Test completed!
echo ========================================
echo.
pause
