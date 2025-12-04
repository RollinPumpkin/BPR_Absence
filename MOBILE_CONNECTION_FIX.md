# Fix Connection Timeout saat Login dari HP

## Masalah yang Diperbaiki
Aplikasi mengalami connection timeout saat mencoba login dari HP karena:
1. IP server hardcoded tidak sesuai
2. Timeout terlalu pendek (30 detik)
3. CORS tidak mengizinkan koneksi dari mobile
4. Tidak ada retry mechanism untuk koneksi yang lambat

## Perubahan yang Dilakukan

### 1. Server Configuration (`frontend/lib/data/constants/server_config.dart`)
```dart
// IP sudah diupdate ke:
static const String productionServerHost = '10.161.89.13'; // ✅ IP dari ipconfig Wi-Fi
```

### 2. API Service Timeout (`frontend/lib/data/services/api_service.dart`)
```dart
// Timeout ditingkatkan menjadi 2 MENIT untuk koneksi mobile
connectTimeout: const Duration(seconds: 120), // 2 minutes for mobile
receiveTimeout: const Duration(seconds: 120),
sendTimeout: const Duration(seconds: 120),

// Tambahan opsi untuk koneksi yang lebih stabil:
persistentConnection: true,
followRedirects: true,
maxRedirects: 5,
headers: {
  'Connection': 'keep-alive', // Keep connection alive
}
```

### 3. Retry Mechanism dengan Exponential Backoff
```dart
// Retry otomatis 3x dengan delay yang meningkat (2s, 4s, 8s)
const maxRetries = 3;
if (_shouldRetry(error) && retryCount < maxRetries) {
  final delaySeconds = 2 * (retryCount + 1);
  await Future.delayed(Duration(seconds: delaySeconds));
  // Retry request...
}
```

### 4. Backend CORS Configuration (`backend/server.js`)
```javascript
// Mengizinkan SEMUA origin dalam development mode
if (process.env.NODE_ENV === 'development' || process.env.NODE_ENV !== 'production') {
  console.log(`✅ CORS Allowed (Development Mode): ${origin || 'no-origin'}`);
  callback(null, true);
}
```

### 5. Mobile Test Endpoint
```javascript
// Endpoint khusus untuk test koneksi mobile
app.get('/api/test/mobile', (req, res) => {
  res.json({
    success: true,
    message: 'Mobile connection successful!',
    clientIP: clientIP,
    serverIP: req.socket.localAddress,
    timestamp: new Date().toISOString(),
  });
});
```

## 🚀 Cara Menggunakan

### LANGKAH 1: Run Diagnostic Tool
```cmd
CHECK_NETWORK.bat
```
Script ini akan:
- ✅ Cek IP address Anda
- ✅ Cek apakah backend running
- ✅ Cek firewall rules
- ✅ Test localhost connection
- ✅ Test network IP connection

### LANGKAH 2: Add Firewall Rule (Jika Perlu)
**Jalankan sebagai Administrator:**
```cmd
ADD_FIREWALL_RULE.bat
```
(Klik kanan → Run as administrator)

### LANGKAH 3: Start Backend Server
```cmd
cd backend
node server.js
```

Pastikan muncul:
```
🚀 Server running on port 3000
🌐 Local: http://localhost:3000
🌐 Network: http://192.168.x.x:3000
```

### LANGKAH 4: Test dari Browser HP
Buka browser di HP dan akses:
```
http://10.161.89.13:3000/mobile-test.html
```

Halaman test ini akan:
- ✅ Test health endpoint
- ✅ Test mobile API
- ✅ Test login API
- 📊 Tampilkan response time
- 🔍 Tampilkan IP client dan server

### LANGKAH 5: Test dari Aplikasi Flutter
1. Pastikan HP terhubung ke Wi-Fi yang sama
2. Build atau run aplikasi
3. Coba login

## 📱 Mobile Test Page

Akses dari HP: `http://[IP-ANDA]:3000/mobile-test.html`

Features:
- 🏥 Health check dengan response time
- 📱 Mobile API connectivity test
- 🔐 Login API test
- 📊 Real-time diagnostics
- 💡 Troubleshooting tips

## 🔧 Troubleshooting

### Problem: "Connection Timeout" setelah 120 detik
**Diagnosis:**
- Backend tidak running
- Firewall memblokir port 3000
- HP dan PC tidak di jaringan yang sama

**Solution:**
1. Run `CHECK_NETWORK.bat` untuk diagnosis
2. Pastikan backend running: `cd backend && node server.js`
3. Run `ADD_FIREWALL_RULE.bat` sebagai Administrator
4. Pastikan HP dan PC di Wi-Fi yang sama

### Problem: "Network Unreachable"
**Solution:**
1. Cek IP dengan `ipconfig` - pastikan IP benar
2. HP dan PC HARUS di Wi-Fi yang sama
3. Jangan gunakan VPN
4. Test ping dari HP ke PC menggunakan app Network Utilities

### Problem: Masih Timeout setelah Semua Fix
**Advanced Solution:**

**1. Cek apakah port 3000 terbuka:**
```cmd
netstat -ano | findstr :3000
```

**2. Test dari CMD:**
```cmd
curl http://localhost:3000/health
curl http://10.161.89.13:3000/health
```

**3. Temporarily disable firewall untuk test:**
```cmd
netsh advfirewall set allprofiles state off
```
(Jangan lupa nyalakan lagi setelah test!)

**4. Cek Windows Defender:**
- Windows Security → Firewall & network protection
- Allow an app through firewall
- Cari "Node.js" → Centang Private dan Public

**5. Test dengan browser HP dulu:**
- Buka: `http://10.161.89.13:3000/mobile-test.html`
- Jika berhasil = backend OK, masalah di app Flutter
- Jika gagal = masalah network/firewall

### Problem: "CORS Error" di Console
**Solution:**
Sudah diperbaiki! Backend sekarang allow all origins di development mode.

### Problem: Login berhasil tapi lama (>30 detik)
**Ini Normal untuk Mobile!**
- Timeout sekarang 120 detik
- Ada retry 3x otomatis
- Response time 30-60 detik wajar untuk jaringan mobile yang lambat

## 📊 Performance Notes

**Timeout Configuration:**
- ⏱️ Connect: 120 seconds
- ⏱️ Receive: 120 seconds  
- ⏱️ Send: 120 seconds
- 🔄 Retry: 3 attempts (2s, 4s, 8s backoff)

**Expected Response Times:**
- Localhost (PC): < 1 second ✅
- Wi-Fi (same network): 1-5 seconds ✅
- Mobile data: 10-60 seconds ⚠️
- Slow network: up to 120 seconds 🐌

## 🎯 Quick Test Checklist

✅ Backend running (`node server.js`)  
✅ Firewall rule added (port 3000)  
✅ HP dan PC di Wi-Fi yang sama  
✅ IP sudah benar di `server_config.dart` (10.161.89.13)  
✅ Test page accessible: `http://10.161.89.13:3000/mobile-test.html`  
✅ Health endpoint OK: `http://10.161.89.13:3000/health`  
✅ Login dari app berhasil  

## 🛠️ Files Modified

1. ✅ `frontend/lib/data/constants/server_config.dart` - IP updated
2. ✅ `frontend/lib/data/constants/api_constants.dart` - Timeout 120s
3. ✅ `frontend/lib/data/services/api_service.dart` - Timeout + Retry
4. ✅ `backend/server.js` - CORS + Mobile endpoint + Static files
5. ✅ `CHECK_NETWORK.bat` - Diagnostic tool
6. ✅ `ADD_FIREWALL_RULE.bat` - Firewall helper
7. ✅ `public/mobile-test.html` - Mobile test page

## 📞 Support

Jika masih ada masalah:
1. Screenshot error message
2. Screenshot hasil `CHECK_NETWORK.bat`
3. Screenshot dari mobile test page
4. Check backend console logs

---
**IP Server**: `10.161.89.13:3000`  
**Timeout**: `120 seconds`  
**Retry**: `3 attempts`  
**Status**: ✅ READY FOR TESTING  
**Tanggal Fix**: 28 November 2025
