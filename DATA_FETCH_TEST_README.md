# 🧪 DATA FETCH TEST SCRIPT

Script untuk memverifikasi bahwa semua data berhasil di-fetch dari database (Firestore) ke frontend dengan baik dan benar.

## 📋 Apa yang Ditest?

Script ini akan mengetes 5 kategori data utama:

### 1. ✅ **Assignments (Penugasan)**
- Fetch semua assignments
- Fetch upcoming assignments
- Validasi data structure (ID, title, status, priority, due date)
- Check apakah data lengkap

### 2. ✅ **Letters (Surat)**
- Fetch sent letters (surat terkirim)
- Fetch received letters (surat diterima)
- Validasi data structure (ID, subject, status, type)
- Check apakah data lengkap

### 3. ✅ **Attendance (Kehadiran)**
- Fetch attendance records
- Filter by date range (bulan ini)
- Validasi data structure (ID, date, status, check in/out time)
- Check apakah data lengkap

### 4. ✅ **Users (Pengguna)**
- Fetch all users
- Validasi data structure (ID, name, email, role, department)
- Check apakah data lengkap

### 5. ✅ **Employees (Karyawan)**
- Fetch all employees
- Validasi data structure (ID, name, email, department)
- Check apakah data lengkap

## 🚀 Cara Menjalankan

### Opsi 1: Menggunakan Batch File (Windows)
```bash
# Double-click file ini:
RUN_DATA_FETCH_TEST.bat
```

### Opsi 2: Manual dari Terminal
```bash
# Masuk ke folder frontend
cd frontend

# Jalankan test
dart run test_data_fetch.dart
```

### Opsi 3: Menggunakan Flutter
```bash
cd frontend
flutter run test_data_fetch.dart
```

## 📊 Output yang Diharapkan

Jika SEMUA data berhasil di-fetch dengan baik:

```
========================================
🚀 STARTING DATA FETCH TEST
========================================

✅ API Service initialized

📋 TEST 1: Fetching Assignments...
  → Testing getAllAssignments()...
    ✓ Fetched 10 assignments
    ✓ Sample assignment:
      - ID: abc123
      - Title: Update Database
      - Status: pending
      - Priority: high
      - Due Date: 2025-11-30
  → Testing getUpcomingAssignments()...
    ✓ Fetched 5 upcoming assignments
  ✅ Assignments fetch: SUCCESS

✉️ TEST 2: Fetching Letters...
  → Testing getSentLetters()...
    ✓ Fetched 3 sent letters
    ✓ Sample letter:
      - ID: xyz789
      - Subject: Leave Request
      - Status: approved
      - Type: sick_leave
  → Testing getReceivedLetters()...
    ✓ Fetched 2 received letters
  ✅ Letters fetch: SUCCESS

📅 TEST 3: Fetching Attendance Records...
  → Testing getAttendanceRecords()...
    ✓ Fetched 20 attendance records
    ✓ Sample attendance:
      - ID: att001
      - Date: 2025-11-28
      - Status: present
      - Check In: 08:00
      - Check Out: 17:00
  ✅ Attendance fetch: SUCCESS

👥 TEST 4: Fetching Users...
  → Testing getAllUsers()...
    ✓ Fetched 15 users
    ✓ Sample user:
      - ID: usr001
      - Name: John Doe
      - Email: john@example.com
      - Role: employee
      - Department: IT
  ✅ Users fetch: SUCCESS

👔 TEST 5: Fetching Employees...
  → Testing getAllEmployees()...
    ✓ Fetched 15 employees
    ✓ Sample employee:
      - ID: emp001
      - Name: Jane Smith
      - Email: jane@example.com
      - Department: HR
  ✅ Employees fetch: SUCCESS

========================================
📊 TEST SUMMARY
========================================
✅ PASSED - assignments
✅ PASSED - letters
✅ PASSED - attendance
✅ PASSED - users
✅ PASSED - employees

Total Tests: 5
Passed: 5
Failed: 0
Success Rate: 100.0%
========================================

🎉 ALL TESTS PASSED! Data fetch working perfectly!
```

## ❌ Jika Ada Error

Jika ada test yang GAGAL, output akan menampilkan:

```
========================================
📊 TEST SUMMARY
========================================
✅ PASSED - assignments
❌ FAILED - letters
✅ PASSED - attendance
✅ PASSED - users
✅ PASSED - employees

Total Tests: 5
Passed: 4
Failed: 1
Success Rate: 80.0%
========================================

⚠️ SOME TESTS FAILED! Please check the errors above.
```

## 🔧 Troubleshooting

### Error: "No token available"
**Solusi**: Pastikan Anda sudah login ke aplikasi terlebih dahulu

### Error: "Connection timeout"
**Solusi**: 
1. Pastikan backend server sudah running (localhost:8080)
2. Check koneksi internet
3. Pastikan firestore sudah di-setup dengan benar

### Error: "Data incomplete"
**Solusi**: 
1. Check apakah ada data di Firestore
2. Pastikan struktur data di Firestore sesuai dengan model frontend
3. Run seeder untuk create sample data

### Error: "API response unsuccessful"
**Solusi**:
1. Check backend logs untuk error detail
2. Pastikan authentication token valid
3. Check API endpoint masih berfungsi

## 📝 Validasi yang Dilakukan

Setiap test akan memvalidasi:

1. ✅ **API Response Success**: Response dari backend sukses (success: true)
2. ✅ **Data Not Empty**: Data yang di-fetch tidak kosong (jika ada di database)
3. ✅ **Data Structure Complete**: Semua field yang required ada dan tidak kosong
4. ✅ **Data Type Correct**: Type data sesuai (String, DateTime, etc)
5. ✅ **Relationships Valid**: Foreign key valid (user_id, etc)

## 🎯 Kapan Harus Run Test Ini?

Jalankan test ini setelah:

1. ✅ Setiap kali update backend API
2. ✅ Setelah update data model di frontend
3. ✅ Setelah update Firestore structure
4. ✅ Sebelum deploy ke production
5. ✅ Setelah fix bug terkait data fetching
6. ✅ Untuk verify data sync working properly

## 🔍 Check Database Firestore

Sebelum run test, pastikan di Firestore sudah ada data:

1. Buka Firebase Console
2. Pilih project BPR Absence
3. Masuk ke Firestore Database
4. Check collections:
   - `assignments` - harus ada data assignment
   - `letters` - harus ada data surat
   - `attendance` atau `attendance_submissions` - harus ada data kehadiran
   - `users` - harus ada data user
5. Jika belum ada data, run seeder terlebih dahulu

## 💡 Tips

- Untuk hasil terbaik, pastikan database ada sample data
- Jika test gagal, check backend logs untuk detail error
- Test ini tidak mengubah data di database (read-only)
- Safe untuk dijalankan berkali-kali
- Bisa dijalankan di development dan production environment

## 📞 Support

Jika ada masalah dengan test script:
1. Check error message di console
2. Check backend logs
3. Verify Firestore data structure
4. Check API endpoints di backend routes

---

**Created**: November 28, 2025
**Version**: 1.0.0
**Author**: BPR Absence Development Team
