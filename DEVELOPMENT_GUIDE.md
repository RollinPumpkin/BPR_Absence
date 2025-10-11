# BPR Absence Development Environment

## Konfigurasi Server

### Firebase NPM Server
- **Port**: 3000
- **URL**: http://localhost:3000
- **Script**: `npm run firebase-server`

### Flutter Web App
- **Port**: 8080
- **URL**: http://localhost:8080
- **Script**: `flutter run -d chrome --web-port=8080`

## Cara Menjalankan

### Option 1: Manual (Recommended)
1. **Start Firebase Server**:
   ```bash
   cd backend
   npm run firebase-server
   ```

2. **Start Flutter App**:
   ```bash
   cd frontend
   flutter run -d chrome --web-port=8080
   ```

### Option 2: Automated Script
Jalankan file `start_development_servers.bat` dari root directory.

## Konfigurasi Koneksi

- Firebase NPM Server menggunakan port 3000
- Flutter menggunakan port default yang tersedia
- API endpoints dikonfigurasi di `frontend/lib/data/constants/api_constants.dart`
- Server config di `frontend/lib/data/constants/server_config.dart`

## Troubleshooting

### Port 8080 Error
Jika ada error port 8080 sudah digunakan, gunakan salah satu solusi:
1. Gunakan port default Flutter (recommended)
2. Gunakan port alternatif: `flutter run -d chrome --web-port=3030`
3. Stop aplikasi yang menggunakan port 8080

### Firebase Connection Error
1. Pastikan Firebase server berjalan di port 3000
2. Check Firebase config di `web/index.html`
3. Verifikasi API key dan project ID

## File Scripts

- `backend/start_firebase_server.bat` - Start Firebase NPM server
- `frontend/start_flutter_default.bat` - Start Flutter dengan port default
- `start_development_servers.bat` - Start kedua server sekaligus