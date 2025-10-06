# 🔑 LOGIN CREDENTIALS

## Credential untuk Testing Aplikasi BPR Absence

### 👤 **User Accounts (Role: Employee)**

#### 1. Ahmad Wijaya (IT Department)
- **Email**: `ahmad.wijaya@bpr.com`
- **Password**: `password123`
- **Position**: Software Developer
- **Department**: IT Department

#### 2. Siti Rahayu (Finance)
- **Email**: `siti.rahayu@bpr.com`
- **Password**: `password123`
- **Position**: Financial Analyst
- **Department**: Finance

#### 3. Budi Santoso (Operations)
- **Email**: `budi.santoso@bpr.com`
- **Password**: `password123`
- **Position**: Operations Manager
- **Department**: Operations

#### 4. User Test (NEW)
- **Email**: `user@gmail.com`
- **Password**: `user123`
- **Position**: Junior Developer
- **Department**: IT Department

---

### 👨‍💼 **Admin Accounts (Role: Administrator)**

#### 1. Dr. Sarah Manager
- **Email**: `sarah.manager@bpr.com`
- **Password**: `admin123456`
- **Position**: General Manager
- **Department**: Management

#### 2. Admin Test (NEW)
- **Email**: `admin@gmail.com`
- **Password**: `admin123`
- **Position**: System Administrator
- **Department**: Management

---

## 🎯 **Quick Test Login**

### Untuk Employee Dashboard:
```
Email: ahmad.wijaya@bpr.com
Password: password123
```

### Untuk User Baru:
```
Email: user@gmail.com
Password: user123
```

### Untuk Admin Dashboard:
```
Email: sarah.manager@bpr.com
Password: admin123456
```

### Untuk Admin Baru:
```
Email: admin@gmail.com
Password: admin123
```

---

## 📋 **Status Data yang Tersedia**

### ✅ **Data yang sudah ada di Firestore:**
- 6 Users dengan Firebase Authentication (4 users lama + 2 users baru)
- 7 Attendance records (untuk minggu ini)
- 5 Assignments/Tasks
- 3 Leave requests
- 2 QR Codes untuk lokasi
- 1 Settings configuration
- 3 Notifications

### 🔐 **Firebase Authentication:**
- Semua users sudah dibuat di Firebase Auth
- Password sudah di-hash dengan bcrypt
- Token JWT siap untuk API authentication

### 🗄️ **Database Collections:**
- `users` - Data profil karyawan
- `attendance` - Record kehadiran
- `assignments` - Task/assignment data
- `leave_requests` - Permohonan cuti
- `qr_codes` - QR code untuk lokasi
- `settings` - Pengaturan aplikasi
- `notifications` - Notifikasi user

---

## 🚀 **Cara Testing**

1. **Start Backend Server:**
   ```bash
   cd backend
   npm start
   ```

2. **Start Frontend App:**
   ```bash
   cd frontend
   flutter run
   ```

3. **Login dengan salah satu credential di atas**

4. **Test Features:**
   - Clock in/out dengan QR Code: `BPR_MainOffice_1759584606`
   - View attendance history
   - Manage assignments
   - Submit leave requests
   - Admin dashboard (jika login sebagai admin)

---

## ⚠️ **Catatan Penting**

- Password ini hanya untuk **development/testing**
- Jangan gunakan password ini di production
- Semua data adalah dummy data untuk testing
- QR Code location: Kantor Pusat BPR Adiarta Reksacipta

---

*Last Updated: October 6, 2025*