# BPR Absence Backend API dengan Firebase

Backend API untuk Sistem Manajemen Absensi BPR Adiartha Reksacipta menggunakan Node.js, Express, dan Firebase Firestore.

## Fitur Utama

- **Autentikasi & Otorisasi**
  - Autentikasi berbasis JWT
  - Kontrol akses berbasis peran (Admin/Karyawan)
  - Hash password yang aman

- **Manajemen User**
  - Registrasi dan manajemen profil user
  - Upload foto profil
  - Direktori karyawan

- **Sistem Absensi**
  - Check-in/check-out berbasis QR code
  - Pelacakan absensi real-time
  - Riwayat dan laporan absensi

- **Manajemen Cuti**
  - Pengajuan permintaan cuti
  - Workflow persetujuan admin
  - Pelacakan riwayat cuti

- **Dashboard Admin**
  - Manajemen user
  - Laporan absensi
  - Pembuatan dan manajemen QR code
  - Statistik dashboard

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: Firebase Firestore
- **Autentikasi**: JWT (JSON Web Tokens)
- **Password Hashing**: bcryptjs
- **File Upload**: multer
- **QR Code**: qrcode
- **Validasi**: Joi
- **Keamanan**: helmet, cors, express-rate-limit

## Instalasi

### 1. Setup Firebase

1. **Buat project Firebase baru**:
   - Kunjungi [Firebase Console](https://console.firebase.google.com/)
   - Klik "Create a project"
   - Ikuti langkah-langkah setup

2. **Enable Firestore Database**:
   - Di Firebase Console, pilih "Firestore Database"
   - Klik "Create database"
   - Pilih "Start in test mode" untuk development

3. **Generate Service Account Key**:
   - Pergi ke Project Settings → Service Accounts
   - Klik "Generate new private key"
   - Download file JSON dan simpan dengan aman

### 2. Setup Backend

1. **Install dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Environment Setup**
   ```bash
   copy .env.example .env
   ```
   
   Update file `.env` dengan konfigurasi Firebase Anda:
   ```env
   NODE_ENV=development
   PORT=3000
   
   # Firebase Configuration
   FIREBASE_PROJECT_ID=your-firebase-project-id
   FIREBASE_PRIVATE_KEY_ID=your-private-key-id
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
   FIREBASE_CLIENT_ID=your-client-id
   FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project.iam.gserviceaccount.com
   
   JWT_SECRET=your_super_secret_jwt_key
   JWT_EXPIRES_IN=7d
   
   FRONTEND_URL=http://localhost:3000
   ```

3. **Jalankan aplikasi**
   ```bash
   # Development mode
   npm run dev
   
   # Production mode
   npm start
   ```

## Integrasi dengan Flutter

Backend ini telah disesuaikan dengan aplikasi Flutter frontend yang sudah ada, dengan dukungan untuk:

- **State Management**: Kompatibel dengan Provider dan GetX yang digunakan di frontend
- **HTTP Client**: Optimized untuk Dio yang digunakan di frontend Flutter
- **Response Format**: Konsisten dengan format yang diharapkan Flutter app
- **CORS**: Dikonfigurasi untuk mendukung Flutter development dan production

### Headers yang Diperlukan untuk Flutter
```dart
final headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token', // Untuk endpoint yang memerlukan auth
};
```

### Contoh Integrasi dengan Dio (sesuai pubspec.yaml Flutter)
```dart
// Login
final response = await dio.post(
  'http://localhost:3000/api/auth/login',
  data: {
    'email': email,
    'password': password,
  },
);

// Check In dengan QR Code Scanner
final response = await dio.post(
  'http://localhost:3000/api/attendance/checkin',
  data: {
    'qr_code': scannedQrCode,
    'location': 'Kantor BPR Adiartha Reksacipta',
    'notes': 'Masuk tepat waktu',
  },
  options: Options(headers: headers),
);
```

## Struktur Database Firestore

### Collections sesuai dengan kebutuhan aplikasi Flutter

#### `users` - Data Karyawan BPR
```json
{
  "employee_id": "BPR001",
  "full_name": "John Doe",
  "email": "john.doe@bpr.com",
  "password": "hashed_password",
  "role": "employee", // "admin" atau "employee"
  "department": "Operasional",
  "position": "Staff",
  "phone": "081234567890",
  "profile_image": "/uploads/profile.jpg",
  "is_active": true,
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

#### `attendance` - Data Absensi Harian
```json
{
  "user_id": "user_document_id",
  "date": "2025-08-21",
  "check_in_time": "08:00:00",
  "check_out_time": "17:00:00",
  "check_in_location": "Kantor BPR Adiartha Reksacipta",
  "check_out_location": "Kantor BPR Adiartha Reksacipta",
  "status": "present", // "present", "late", "absent", "sick", "leave"
  "notes": "Masuk tepat waktu",
  "qr_code_used": "BPR_Office_1234567890",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

#### `leave_requests` - Pengajuan Cuti
```json
{
  "user_id": "user_document_id",
  "leave_type": "annual", // "sick", "annual", "personal", "emergency"
  "start_date": "2025-08-25",
  "end_date": "2025-08-27",
  "reason": "Liburan tahunan",
  "status": "pending", // "pending", "approved", "rejected"
  "approved_by": "admin_user_id",
  "approved_at": "timestamp",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

#### `qr_codes` - QR Code untuk Check-in
```json
{
  "code": "BPR_Office_1692614400000",
  "location": "Kantor BPR Adiartha Reksacipta",
  "is_active": true,
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

## API Endpoints untuk Flutter Integration

### Autentikasi (sesuai dengan login_page.dart)
- `POST /api/auth/login` - Login untuk splash → login flow
- `POST /api/auth/register` - Registrasi karyawan baru
- `GET /api/auth/verify` - Verifikasi token untuk persistent login
- `PUT /api/auth/change-password` - Ubah password

### Dashboard Admin (sesuai dengan admin/dashboard)
- `GET /api/admin/dashboard-stats` - Statistik untuk admin dashboard
- `GET /api/admin/users` - Daftar semua karyawan
- `GET /api/admin/attendance-reports` - Laporan absensi
- `GET /api/admin/leave-requests` - Permintaan cuti yang perlu disetujui

### User/Employee Features
- `GET /api/users/profile` - Profil karyawan
- `PUT /api/users/profile` - Update profil
- `POST /api/users/profile/picture` - Upload foto profil (image_picker integration)
- `GET /api/users/dashboard` - Dashboard data untuk karyawan

### Absensi dengan QR Code (mobile_scanner integration)
- `POST /api/attendance/checkin` - Check in dengan QR scan
- `POST /api/attendance/checkout` - Check out
- `GET /api/attendance/today` - Status absensi hari ini
- `GET /api/attendance/summary` - Ringkasan absensi bulanan

### QR Code Management (qr_flutter integration)
- `POST /api/admin/generate-qr` - Generate QR code baru
- `GET /api/admin/qr-codes` - Daftar QR code
- `PUT /api/admin/qr-codes/:id/toggle` - Aktifkan/nonaktifkan QR code

## Response Format (konsisten dengan Flutter expectations)

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    // Response data sesuai kebutuhan Flutter widgets
  }
}
```

### Error Response (untuk error handling di Flutter)
```json
{
  "success": false,
  "message": "Error description untuk ditampilkan ke user",
  "details": "Technical details untuk debugging"
}
```

## CORS Configuration untuk Flutter Development

```javascript
// Sudah dikonfigurasi untuk mendukung Flutter development
const corsOptions = {
  origin: [
    'http://localhost:3000',   // Web development
    'http://localhost:8080',   // Flutter web
    'http://localhost:8081',   // Flutter development server
    'http://10.0.2.2:3000',    // Android emulator
    'http://127.0.0.1:3000',   // Local development
    process.env.FRONTEND_URL   // Production URL
  ],
  credentials: true
};
```

## Integration dengan Flutter Packages

### Dio HTTP Client
```dart
// Konfigurasi base URL untuk development
final dio = Dio(BaseOptions(
  baseUrl: 'http://localhost:3000/api',
  connectTimeout: 5000,
  receiveTimeout: 3000,
));
```

### SharedPreferences untuk Token Storage
```dart
// Simpan token setelah login berhasil
await SharedPreferences.getInstance().then((prefs) {
  prefs.setString('auth_token', response.data['data']['token']);
});
```

### Image Picker Integration
```dart
// Upload foto profil
FormData formData = FormData.fromMap({
  'profile_image': await MultipartFile.fromFile(
    imageFile.path,
    filename: 'profile.jpg',
  ),
});
```

## Development Workflow

1. **Setup Firebase Project**
2. **Configure .env file**
3. **Install dependencies**: `npm install`
4. **Start development server**: `npm run dev`
5. **Test dengan Flutter app**

## Production Deployment

1. Update Firebase security rules
2. Set production environment variables
3. Configure HTTPS
4. Update CORS untuk production domain
5. Setup monitoring dan logging

## Troubleshooting Flutter Integration

### Common Issues:
1. **CORS Error**: Pastikan frontend URL ada di CORS config
2. **Token Expired**: Implement token refresh di Flutter
3. **Network Error**: Cek koneksi dan base URL
4. **Image Upload**: Pastikan format file sesuai dengan validation

### Debug Tips:
```bash
# Monitor backend logs
npm run dev

# Test endpoints dengan curl
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@bpr.com","password":"password123"}'
```

## License

ISC License - Project BPR Adiartha Reksacipta by 911 Team
