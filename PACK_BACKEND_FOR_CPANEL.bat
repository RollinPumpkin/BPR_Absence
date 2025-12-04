@echo off
echo ========================================
echo Packing Backend for cPanel Upload
echo ========================================
echo.

cd /d "%~dp0backend"

echo Membuat file ZIP untuk upload ke cPanel...
echo.

REM Hapus zip lama jika ada
if exist "backend-deploy.zip" del "backend-deploy.zip"

REM Buat zip baru (Windows 10/11 punya tar built-in)
echo Compressing files...
echo ⚠️  PENTING: node_modules TIDAK diikutkan (akan diinstall di server)
echo.
tar -a -c -f backend-deploy.zip ^
    config ^
    middleware ^
    routes ^
    services ^
    bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json ^
    server.js ^
    package.json ^
    firestore.rules ^
    firestore.indexes.json ^
    firebase.json ^
    .env.production

echo.
echo ⚠️  NOTE: node_modules folder TIDAK di-ZIP karena:
echo    - CloudLinux NodeJS Selector akan buat symlink otomatis
echo    - Dependencies akan diinstall via "Run NPM Install" di cPanel
echo    - Ukuran ZIP jadi lebih kecil dan upload lebih cepat

echo.
echo ========================================
echo ✅ SELESAI!
echo ========================================
echo.
echo File ZIP dibuat: backend\backend-deploy.zip
echo Size: 
dir backend-deploy.zip | find "backend-deploy.zip"
echo.
echo LANGKAH SELANJUTNYA:
echo 1. Upload file 'backend-deploy.zip' ke cPanel File Manager
echo 2. Letakkan di folder home directory (bukan public_html)
echo 3. Klik kanan file ZIP → Extract
echo 4. Folder 'backend' akan otomatis terbuat dengan semua file
echo 5. JANGAN upload folder node_modules (akan diinstall via npm)
echo.
echo ⚠️  PENTING: Rename file .env.production menjadi .env setelah extract!
echo.
pause
