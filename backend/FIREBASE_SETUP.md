# Firebase Setup Guide untuk BPR Absence Backend

## 1. Membuat Project Firebase

1. **Buka Firebase Console**
   - Kunjungi: https://console.firebase.google.com/
   - Login dengan akun Google

2. **Buat Project Baru**
   - Klik "Add project"
   - Nama project: `bpr-absence-system` (atau sesuai keinginan)
   - Pilih region: `asia-southeast1` (Singapura - terdekat dengan Indonesia)
   - Disable Google Analytics (opsional untuk project ini)

## 2. Setup Firestore Database

1. **Enable Firestore**
   - Di sidebar, pilih "Firestore Database"
   - Klik "Create database"
   - Pilih "Start in test mode" untuk development
   - Pilih location: `asia-southeast1`

2. **Atur Security Rules (Development)**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Allow read/write access untuk development
       // PENTING: Ubah untuk production!
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```

3. **Security Rules (Production)**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
         allow read: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
       
       // Attendance collection
       match /attendance/{attendanceId} {
         allow read, write: if request.auth != null;
       }
       
       // Leave requests
       match /leave_requests/{requestId} {
         allow create: if request.auth != null;
         allow read, update: if request.auth != null && 
           (resource.data.user_id == request.auth.uid || 
            get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
       }
       
       // QR codes (admin only)
       match /qr_codes/{qrId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
       
       // Settings (admin only)
       match /settings/{settingId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
     }
   }
   ```

## 3. Generate Service Account Key

1. **Pergi ke Project Settings**
   - Klik ⚙️ (Settings) → "Project settings"
   - Tab "Service accounts"

2. **Generate Private Key**
   - Pilih "Node.js"
   - Klik "Generate new private key"
   - Download file JSON
   - **PENTING**: Simpan file ini dengan aman, jangan commit ke Git!

3. **Extract Information dari JSON**
   File yang didownload akan berisi informasi seperti:
   ```json
   {
     "type": "service_account",
     "project_id": "bpr-absence-system",
     "private_key_id": "...",
     "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
     "client_email": "firebase-adminsdk-xxxxx@bpr-absence-system.iam.gserviceaccount.com",
     "client_id": "...",
     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
     "token_uri": "https://oauth2.googleapis.com/token",
     "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
     "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40bpr-absence-system.iam.gserviceaccount.com"
   }
   ```

## 4. Konfigurasi Environment Variables

1. **Copy .env.example ke .env**
   ```bash
   copy .env.example .env
   ```

2. **Isi Environment Variables**
   ```env
   NODE_ENV=development
   PORT=3000

   # Firebase Configuration (dari service account JSON)
   FIREBASE_PROJECT_ID=bpr-absence-system
   FIREBASE_PRIVATE_KEY_ID=private_key_id_dari_json
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nisi_private_key_dari_json\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@bpr-absence-system.iam.gserviceaccount.com
   FIREBASE_CLIENT_ID=client_id_dari_json
   FIREBASE_CLIENT_X509_CERT_URL=client_x509_cert_url_dari_json

   # JWT Configuration
   JWT_SECRET=bpr_absence_super_secret_key_2025
   JWT_EXPIRES_IN=7d

   # File Upload
   UPLOAD_PATH=./uploads
   MAX_FILE_SIZE=5242880

   # Rate Limiting
   RATE_LIMIT_WINDOW_MS=900000
   RATE_LIMIT_MAX_REQUESTS=100

   # CORS
   FRONTEND_URL=http://localhost:3000
   ```

## 5. Verifikasi Setup

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Test Connection**
   ```bash
   npm run dev
   ```

3. **Cek Log**
   Pastikan melihat:
   ```
   ✅ Firebase Admin SDK initialized successfully
   ✅ Firebase Firestore connected successfully
   ✅ Firebase collections structure ready
   ✅ App settings initialized
   🚀 BPR Absence API Server running on port 3000
   ```

4. **Test Health Endpoint**
   ```bash
   curl http://localhost:3000/health
   ```

## 6. Setup Admin User (Optional)

Untuk membuat admin user pertama, Anda bisa:

1. **Registrasi melalui API**
   ```bash
   curl -X POST http://localhost:3000/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "employee_id": "ADMIN001",
       "full_name": "Administrator",
       "email": "admin@bpr.com",
       "password": "admin123456",
       "department": "IT",
       "position": "System Administrator"
     }'
   ```

2. **Update Role ke Admin melalui Firebase Console**
   - Buka Firestore di Firebase Console
   - Cari document user yang baru dibuat
   - Edit field `role` dari `employee` ke `admin`

## 7. Frontend Flutter Integration

Untuk menghubungkan dengan Flutter app:

1. **Update base URL di Flutter**
   ```dart
   // lib/core/constants/api.dart
   class ApiConstants {
     static const String baseUrl = 'http://localhost:3000/api';
     // Untuk Android emulator: 'http://10.0.2.2:3000/api'
     // Untuk device fisik: 'http://192.168.1.xxx:3000/api'
   }
   ```

2. **Test Login dari Flutter**
   ```dart
   final response = await dio.post(
     '${ApiConstants.baseUrl}/auth/login',
     data: {
       'email': 'admin@bpr.com',
       'password': 'admin123456',
     },
   );
   ```

## 8. Troubleshooting

### Error: "Firebase initialization failed"
- Cek apakah semua environment variables sudah benar
- Pastikan private key format benar (dengan \n)
- Verifikasi project_id sesuai dengan Firebase project

### Error: "Firestore connection test failed"
- Pastikan Firestore sudah diaktifkan di Firebase Console
- Cek security rules tidak terlalu restrictive
- Verifikasi service account memiliki permissions

### Error: "Permission denied"
- Update Firestore security rules
- Pastikan service account role adalah "Firebase Admin SDK Administrator Service Agent"

### CORS Error dari Flutter
- Tambahkan IP address device/emulator ke CORS config
- Untuk Android emulator gunakan: `http://10.0.2.2:3000`
- Untuk iOS simulator gunakan: `http://localhost:3000`

## 9. Production Checklist

- [ ] Update Firestore security rules untuk production
- [ ] Set NODE_ENV=production
- [ ] Gunakan strong JWT secret
- [ ] Setup HTTPS
- [ ] Update CORS origins untuk production domain
- [ ] Setup monitoring dan alerting
- [ ] Backup strategy untuk Firestore
- [ ] Setup environment variables di server
- [ ] Test semua endpoints
- [ ] Load testing

## 10. Firebase Pricing

Firestore memiliki free tier yang cukup untuk development:
- 50K reads/day
- 20K writes/day  
- 20K deletes/day
- 1GB storage

Untuk production, monitor usage di Firebase Console dan upgrade plan jika diperlukan.

## Support

Jika mengalami masalah:
1. Cek Firebase Console untuk error logs
2. Review server logs: `npm run dev`
3. Test endpoints dengan Postman/curl
4. Periksa network connectivity
