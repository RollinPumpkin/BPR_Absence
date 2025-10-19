@echo off
echo 🔐 Setup Gmail App Password untuk BPR Absence
echo ============================================
echo.

echo 📧 Email yang akan digunakan: septapuma@gmail.com
echo 🎯 Fungsi: Mengirim email reset password secara otomatis
echo.

echo 🚀 LANGKAH SETUP:
echo.
echo 1. Buka browser dan go to: https://myaccount.google.com/security
echo 2. Login dengan septapuma@gmail.com
echo 3. Pastikan 2-Step Verification AKTIF (wajib untuk App Password)
echo 4. Scroll ke bawah, cari "App passwords"
echo 5. Klik "App passwords"
echo 6. Pilih "Mail" dari dropdown
echo 7. Pilih "Other (Custom name)" dan ketik: BPR Absence
echo 8. Klik "Generate"
echo 9. Copy password 16-karakter yang muncul (format: xxxx xxxx xxxx xxxx)
echo.

echo 🔧 SETELAH DAPAT PASSWORD:
echo 1. Buka file: backend\.env
echo 2. Ganti "your_gmail_app_password_here" dengan password tanpa spasi
echo 3. Contoh: EMAIL_PASS=abcdefghijklmnop
echo 4. Save file
echo 5. Jalankan test lagi
echo.

echo 📱 Opening Gmail Account Security...
start https://myaccount.google.com/security

echo.
echo ⏳ Setelah setup App Password, tekan Enter untuk test email...
pause

echo.
echo 🧪 Testing email configuration...
node quick-email-test.js

echo.
echo 📋 Jika berhasil, Anda akan dapat email test di septapuma@gmail.com
echo 🚀 Kemudian test forgot password di Flutter app!
echo.
pause