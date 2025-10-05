# Testing Guide untuk Fitur yang Sudah Diperbaiki

## 1. Remember Me Feature
### Test Steps:
1. Buka halaman login
2. Masukkan email: `user@gmail.com` dan password: `user123`
3. Centang checkbox "Remember Me"
4. Klik "SIGN IN"
5. Setelah login berhasil, logout
6. Kembali ke halaman login
7. **Expected**: Email dan password sudah terisi otomatis dan checkbox "Remember Me" sudah tercentang

### Test Uncheck Remember Me:
1. Di halaman login dengan kredensial tersimpan
2. Uncheck "Remember Me"
3. Login
4. Logout
5. Kembali ke halaman login
6. **Expected**: Field email dan password kosong

## 2. Token Authentication Fix
### Test Steps:
1. Login dengan kredensial valid
2. Pergi ke dashboard user
3. Scroll ke bagian "Activity Summary"
4. **Expected**: Data activity summary muncul tanpa error "Access denied. No token provided"
5. **Expected**: Tombol "Retry" tidak muncul

## 3. Clock Display Fix
### Test Steps:
1. Login dan pergi ke dashboard
2. Lihat bagian Clock In/Clock Out di header
3. **Expected**: Sebelum clock in, waktu menampilkan "--:--:--" bukan waktu yang berjalan
4. **Expected**: Sebelum clock out (dan belum clock in), waktu menampilkan "--:--:--"

### Test Clock In/Out:
1. Klik tombol Clock In
2. **Expected**: Waktu clock in muncul dan tersimpan
3. **Expected**: Clock out masih menampilkan "--:--:--" sampai tombol clock out diklik
4. Klik tombol Clock Out
5. **Expected**: Waktu clock out muncul dan tersimpan

## 4. Authentication Flow End-to-End
### Test Steps:
1. Login dengan kredensial valid
2. Navigate ke berbagai halaman (dashboard, profile, dll)
3. **Expected**: Semua API calls berhasil tanpa error token
4. Logout
5. **Expected**: Token dibersihkan dan redirect ke login
6. Coba akses halaman yang memerlukan authentication
7. **Expected**: Redirect ke login

## Login Credentials untuk Testing:
- Email: `user@gmail.com`, Password: `user123` (Employee)
- Email: `admin@gmail.com`, Password: `admin123` (Admin)
- Email: `ahmad@gmail.com`, Password: `ahmad123` (Employee)
- Email: `sarah@gmail.com`, Password: `sarah123` (Employee)

## Expected Behavior Summary:
1. ✅ Remember Me menyimpan dan memuat kredensial
2. ✅ Token disimpan dengan benar di ApiService setelah login
3. ✅ Clock display menampilkan "--:--:--" ketika belum ada clock in/out
4. ✅ Activity Summary memuat data tanpa error token
5. ✅ Logout membersihkan token dan kredensial (jika remember me tidak dicentang)