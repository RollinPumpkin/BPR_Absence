@echo off
echo ================================================
echo BUILD APK RELEASE - BPR ABSENCE
echo ================================================
echo.

cd frontend

echo [1/4] Cleaning previous builds...
call flutter clean
if errorlevel 1 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo.
echo [2/4] Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo.
echo [3/4] Building RELEASE APK...
call flutter build apk --release
if errorlevel 1 (
    echo ERROR: Flutter build failed
    pause
    exit /b 1
)

echo.
echo [4/4] Renaming APK to bpr-absence.apk...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    ren "build\app\outputs\flutter-apk\app-release.apk" "bpr-absence.apk"
    echo.
    echo ================================================
    echo BUILD SUCCESS!
    echo ================================================
    echo APK location: frontend\build\app\outputs\flutter-apk\bpr-absence.apk
    echo.
    dir "build\app\outputs\flutter-apk\bpr-absence.apk"
    echo.
    start "" "%cd%\build\app\outputs\flutter-apk"
) else (
    echo ERROR: APK file not found
    echo Checking build output folder...
    dir "build\app\outputs\flutter-apk" /b
)

echo.
pause
