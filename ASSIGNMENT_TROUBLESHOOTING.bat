@echo off
echo ============================================
echo   Assignment Troubleshooting Guide
echo ============================================
echo.
echo Masalah: Assignment tidak muncul setelah ditambahkan
echo.
echo Solusi yang sudah diterapkan:
echo [1] Refresh otomatis setelah Add Data
echo [2] Update widget saat data berubah
echo [3] Error handling yang lebih baik
echo.
echo ============================================
echo   Langkah Troubleshooting:
echo ============================================
echo.
echo STEP 1: Restart Backend Server
echo --------------------------------
echo 1. Tekan Ctrl+C di terminal backend (jika running)
echo 2. cd backend
echo 3. npm start
echo.
echo STEP 2: Hot Reload Frontend
echo --------------------------------
echo 1. Tekan 'r' di terminal Flutter untuk reload
echo 2. Atau tekan 'R' untuk hot restart
echo.
echo STEP 3: Clear Cache ^& Restart
echo --------------------------------
echo 1. Close browser completely
echo 2. flutter run -d chrome --web-port=8080
echo.
echo STEP 4: Test Assignment Creation
echo --------------------------------
echo 1. Login sebagai admin
echo 2. Buka Assignments page
echo 3. Klik "Add Data"
echo 4. Isi form dan submit
echo 5. Lihat console log:
echo    - "[ADD_DATA] Button clicked"
echo    - "[SAVE] Starting assignment save"
echo    - "[SUCCESS] Assignment created"
echo    - "[REFRESH] Triggering refresh callback"
echo    - "[MONTHLY_UI] Assignments updated"
echo.
echo STEP 5: Check Backend Logs
echo --------------------------------
echo Pastikan backend log menampilkan:
echo - POST /api/assignments (201 Created)
echo - GET /api/assignments (200 OK)
echo.
echo STEP 6: Check Firestore Database
echo --------------------------------
echo 1. Buka Firebase Console
echo 2. Firestore Database ^> assignments collection
echo 3. Verify assignment baru ada di database
echo.
echo ============================================
echo   Common Issues ^& Solutions:
echo ============================================
echo.
echo Issue 1: HTTP 500 Error
echo - Backend tidak running atau crash
echo - Solution: Restart backend server
echo.
echo Issue 2: Assignment tidak muncul
echo - Refresh tidak dipanggil
echo - Solution: Sudah diperbaiki dengan force refresh
echo.
echo Issue 3: Console error "Failed to get profile"
echo - Token expired atau invalid
echo - Solution: Logout dan login kembali
echo.
echo Issue 4: Data tidak tersimpan
echo - Validation error di backend
echo - Solution: Check backend console untuk error message
echo.
echo ============================================
echo.
echo Press any key to close...
pause >nul
