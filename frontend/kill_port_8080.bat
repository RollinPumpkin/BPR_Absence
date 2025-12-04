@echo off
echo ====================================
echo Killing process on port 8080
echo ====================================

FOR /F "tokens=5" %%P IN ('netstat -a -n -o ^| findstr :8080') DO (
    echo Found PID: %%P
    taskkill /F /PID %%P 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo Process %%P killed successfully
    )
)

echo.
echo Port 8080 should be free now
echo ====================================
pause
