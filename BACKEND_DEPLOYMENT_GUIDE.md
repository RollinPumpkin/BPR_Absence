# Panduan Deploy Backend ke DomainNesia cPanel

## Persiapan

### 1. Cek Dukungan Node.js di cPanel
- Login ke cPanel DomainNesia
- Cari menu **"Setup Node.js App"** atau **"Node.js Selector"**
- Pastikan Node.js versi 16+ tersedia

### 2. File yang Perlu Diupload
```
backend/
├── config/
├── middleware/
├── routes/
├── services/
├── bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json
├── server.js
├── package.json
├── .env (buat manual di server)
└── firestore.rules (optional)
```

**⚠️ JANGAN upload folder:**
- `node_modules/` ← **PENTING! CloudLinux akan buat symlink otomatis**
- `.git/` (jika ada)
- File development/testing (test-*.js, show-*.js, dll)

**Kenapa `node_modules` tidak boleh diupload?**
- CloudLinux NodeJS Selector membuat virtual environment terpisah
- `node_modules` akan dibuat sebagai symlink otomatis
- Dependencies akan diinstall via "Run NPM Install" di cPanel
- Jika ada folder `node_modules` manual, akan error: *"application should not contain folder/file with such name"*

---

## Langkah-Langkah Deployment

### STEP 1: Upload File Backend

#### ⚠️ PENTING: cPanel File Manager tidak bisa upload folder langsung!

#### **Opsi A: ZIP + Upload + Extract (PALING MUDAH) ✅**
1. **Buat ZIP file** di komputer lokal:
   - Jalankan file `PACK_BACKEND_FOR_CPANEL.bat` di workspace
   - Akan membuat file `backend/backend-deploy.zip`
   
2. **Upload ke cPanel:**
   - Login ke cPanel → Buka **"File Manager"**
   - Masuk ke **Home Directory** (jangan masuk public_html!)
   - Klik **"Upload"** (tombol di toolbar atas)
   - Upload file `backend-deploy.zip`
   - Tunggu sampai 100% complete

3. **Extract di Server:**
   - Kembali ke File Manager
   - Klik kanan file `backend-deploy.zip`
   - Pilih **"Extract"**
   - Pilih lokasi extract (biasanya current directory)
   - Klik **"Extract Files"**
   - ✅ Semua folder dan file akan otomatis terbuat!

4. **Tampilkan Hidden Files & Rename .env:**
   - Di File Manager, klik tombol **"Settings"** (icon gear ⚙️ di kanan atas)
   - Centang **"Show Hidden Files (dotfiles)"**
   - Klik **"Save"**
   - Sekarang file `.env.production` akan terlihat
   - Masuk ke folder `backend`
   - Rename `.env.production` → `.env` (klik kanan → Rename)

#### **Opsi B: Via FTP (Untuk Upload Besar/Update Cepat)**
1. Download **FileZilla** (https://filezilla-project.org/)
2. **Koneksi ke cPanel FTP:**
   - Host: `ftp.domainanda.com` (cek di cPanel → FTP Accounts)
   - Username: (dari cPanel FTP Accounts)
   - Password: (password FTP Anda)
   - Port: 21
3. **Upload via drag-and-drop:**
   - Di panel kiri (lokal): pilih folder `backend/`
   - Di panel kanan (server): drag folder ke home directory
   - FTP akan upload semua file dan folder sekaligus
   - ⏱️ Bisa lebih lama tapi struktur folder tetap sama

#### **Opsi C: Via SSH + Git (Paling Advanced)**
```bash
# Login SSH ke cPanel
cd ~
git clone https://github.com/YourUsername/BPR_Absence.git
cd BPR_Absence/backend
npm install --production
```

---

### STEP 2: Setup Node.js Application di cPanel

1. **Buka "Setup Node.js App"** di cPanel
2. **Klik "Create Application"**
3. **Konfigurasi:**
   - **Node.js Version:** Pilih versi terbaru (16+, 18+ recommended)
   - **Application Mode:** Production
   - **Application Root:** Isi path folder backend (contoh: `backend`)
   - **Application URL:** Kosongkan (akan akses via API subdomain/path)
   - **Application Startup File:** `server.js`
   - **Environment Variables:** (tambahkan nanti di Step 3)
4. **Klik "Create"**

**Catatan Port:**
- cPanel biasanya assign port otomatis (bukan 3000)
- Catat port yang diberikan untuk konfigurasi nanti

---

### STEP 3: Install Dependencies

1. Di halaman **Node.js App**, klik tombol **"Run NPM Install"**
   - Tunggu sampai selesai (bisa 2-5 menit)
   - Jika gagal, gunakan Terminal SSH (lihat cara alternatif di bawah)

2. **Atau via SSH Terminal:**
   ```bash
   cd ~/backend
   npm install --production
   ```

---

### STEP 4: Setup Environment Variables (.env)

**PENTING:** Jangan upload file .env dari lokal! Buat manual di server untuk keamanan.

1. **Via cPanel File Manager:**
   - Buka folder backend
   - Klik **"+ File"** → Buat file baru: `.env`
   - Edit file dan isi dengan konfigurasi production:

```env
# Environment
NODE_ENV=production
PORT=XXXX  # Port dari cPanel Node.js App (biasanya auto-assigned)

# Firebase Admin SDK
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@bpr-absens.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDvy2ikWKA2Kyak\n07Ss5prWaAMZfFOYMonmyHWpt0bqXDFRnqdd068jo667uU3vCym3/YJ5pqw++GOC\nKVfiIW3TWnWdRhIkwb6Kq4kzHYzTv9PrN/D1quKIavkBU+MBhlBMVeZqXLHowIv5\nW6eQdb6J5Kprev67r4PuAdCoudwcKClvZ77ShcEPEr4L3dSwVnYe6SYoUTdwiLi1\nbUXy8hNw8EOovda49KXyFb/1lWkLOEzFiu9AQmQ/6S9F6MKfZtmh1ZzLk8L/ssBE\naCLTp96QDUnqR3KtFVtxvfx/LecVOi2LXeH+JitB2/u5ZVBRKmTmNcx7ksXUGTs3\nUUahLt0JAgMBAAECggEAHXYEahCuGl73KqViBiN3nuOnjIA0YGIb2ZFZDMbE591M\n0pDR/O/u4suPl7vJYexMA1waUCo/RlChH9Lxhl8CDcddj5BA1r2WVJYvpJU7AfcI\nU9a10ZEIWlH+PCtbcWAC9JCnNFElgImg3jw5sZYYbfunSSOS3BSmel2ZuRPLVwqx\nQY1VS9kGPDalOkxeNyO5lWjmyl1Mtpf033ljF0rj5QLRD8efNHZBPe3kPUceVg/i\n99JhDteUeQ0CaJR2tJWkWeoVUWei9PW2wL8FvPu/5/Zl84QS8+Asy4P7IPFerCiC\nCu5yoWoOSF9HQoFchVr80zMtO7/Zir2RbXD4fW7mYwKBgQD8ai1lPgbDfPCRzviy\n4VQZnjoZEBP+PvttGND2bV5+Hz4FBLhIfqbDKcRpZaJXm+o/C6OkdzFynb4+QGcO\nKz7Yqy55Xqa20ih8Uf60YPoD7jO1Pamm/Wlt24ivXS1DIM62A35k9NjcctP/hkxF\nj7AvHhqFvfgOtn3AgcOG1+wRvwKBgQDzM1egXRhs/D/wbK8GBpZH+FXv0eGnetDZ\nG50y5BBF/a3gQdSoKee1mOytoqjTUyOQtfn68DdTO0nIcF10ufcAKrZcPeNgQQpQ\ndYmWFZTUkvM2+ucsAftx2rXQOM834tT8HRk0AojXVZ5Zxrao8fqWqaHHFbPwm2Ao\nMARPqZIzNwKBgQDJQGrzZvIDmbFBwDDghvID/vk5lG0scNEMmhW59Ve63XQYkjvQ\naVLTFpEoq8U1bvXk0IXoErTVOto9TiIc1PQl0s6aLJJl/8gR31piPVP6IEkP/5st\nrq0Jz1j64SK+fAD0dHKpUeM6WT+YY16as8b4ulrRObb3HB/FhnD8KVpqhwKBgQCp\n4Ikq2RyAtEqtVB2FpgA/UXYlyINJC37qyGEr9SZw3VwhM5qpxGu365QXTXGD+6Ty\nJkrxP+5FUzqcqfB94pBoK22qTQiQaZ4cyZ1LmtOVEPiWxPfJQ7ExvEYXpjcIoIeJ\ne4HpVIPldkbgCu/4Xt5dcywv9jb0sHOgXroEMzyOTQKBgC2tXcDGYAtoYwkOh4OM\nc7E7U6hBxh8NURc9HRkSIDWYs5Qej22lrGnGGMgKRDbNcsXkUcL6Uvo4qJea2N0F\nHvtQ15BKEr8SHYoVVk9hEfOQVfS0VBceumynjJQ21hmDIChM4bB16+A5Ml9ZljWW\nie7gto4Uew033Qqlove427ev\n-----END PRIVATE KEY-----\n"
FIREBASE_PROJECT_ID=bpr-absens

# JWT
JWT_SECRET=3ad74e369361550363cba455f12ca93a624a641febcbc4d65d23671f0f0d4f394439c576cfafda02981b88bef3b28fab3739901f4b5079da3bce65fb0b0ce4fa
JWT_EXPIRES_IN=7d

# Email (Gmail SMTP)
EMAIL_USER=septapuma@gmail.com
EMAIL_PASS=GANTI_DENGAN_APP_PASSWORD_GMAIL

# Upload
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880

# CORS
FRONTEND_URL=https://DOMAIN-ANDA.com

# Rate limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

2. **Setting Environment Variables di cPanel (Alternatif):**
   - Bisa juga set di **Node.js App** → **Environment Variables**
   - Tambahkan key-value pairs (tapi .env file lebih praktis)

**PENTING - Ubah nilai:**
- `PORT` → Port yang diberikan cPanel
- `EMAIL_PASS` → App Password Gmail (bukan password Gmail biasa)
- `FRONTEND_URL` → Domain production Anda

---

### STEP 5: Setup Proxy dengan .htaccess (Agar Bisa Diakses dari Domain)

Jika ingin API accessible dari subdomain (misal: `api.domainanda.com`):

1. **Setup Subdomain di cPanel:**
   - **cPanel → Domains → Create a New Domain**
   - Subdomain: `api` atau `backend`
   - Document Root: Arahkan ke folder khusus (misal: `public_html/api`)

2. **Buat .htaccess di Document Root subdomain:**
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://localhost:PORT_CPANEL/$1 [P,L]
```

**Ganti `PORT_CPANEL`** dengan port dari Node.js App cPanel

3. **Atau Gunakan Reverse Proxy di Apache Config** (minta ke support DomainNesia jika perlu)

---

### STEP 6: Start Aplikasi

1. **Di halaman "Setup Node.js App":**
   - Klik tombol **"Restart"** atau **"Start App"**
   - Status harus berubah jadi **"Running"**

2. **Cek Status:**
   - Lihat apakah ada error di log
   - Klik **"View Logs"** untuk debugging

---

### STEP 7: Testing

#### Test 1: Health Endpoint
```bash
curl https://api.domainanda.com/health
# atau
curl http://domainanda.com:PORT/health
```

Expected response:
```json
{
  "status": "OK",
  "timestamp": "...",
  "clientIp": "..."
}
```

#### Test 2: Login API
```bash
curl -X POST https://api.domainanda.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}'
```

#### Test 3: Dari Browser
Buka di browser:
```
https://api.domainanda.com/health
```

---

### STEP 8: Update Flutter Config

Edit `frontend/lib/data/constants/server_config.dart`:

```dart
class ServerConfig {
  // Production Server
  static const String productionServerHost = "api.domainanda.com"; // GANTI
  static const int productionServerPort = 443; // HTTPS
  static const bool useHttpsInProduction = true; // Gunakan HTTPS
  
  // Matikan Ngrok untuk production
  static const bool useNgrok = false;
  
  static String get baseUrl {
    if (useNgrok) {
      return ngrokUseHttps 
          ? 'https://$ngrokUrl'
          : 'http://$ngrokUrl:$ngrokPort';
    }
    
    // Production mode
    if (kReleaseMode || useHttpsInProduction) {
      return 'https://$productionServerHost';
    }
    
    // Development mode
    return 'http://$productionServerHost:$productionServerPort';
  }
}
```

---

## Troubleshooting

### Masalah 1: Node.js App Tidak Start
**Solusi:**
```bash
# Via SSH Terminal
cd ~/backend
npm install
node server.js  # Test manual dulu
```

Cek error di console, biasanya:
- Missing dependencies
- Environment variables salah
- Port conflict

### Masalah 2: Cannot Access API dari Domain
**Cek:**
- Apakah .htaccess proxy benar?
- Apakah subdomain sudah propagate? (tunggu 5-15 menit)
- Cek Apache error log di cPanel

### Masalah 3: Firebase Connection Error
**Cek:**
- File `bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json` sudah diupload?
- Path di `config/database.js` sudah benar?
```javascript
const serviceAccount = require('../bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
```

### Masalah 4: CORS Error dari Frontend
**Solusi:**
Update `.env` di server:
```env
FRONTEND_URL=https://domainanda.com
```

Dan pastikan di `server.js`:
```javascript
app.use(cors({
  origin: process.env.FRONTEND_URL,
  credentials: true
}));
```

### Masalah 5: Upload File Tidak Jalan
**Cek:**
- Folder `uploads/` sudah dibuat dan punya permission 755
```bash
mkdir uploads
chmod 755 uploads
```

---

## Monitoring & Maintenance

### 1. Restart App Otomatis
cPanel Node.js App biasanya auto-restart jika crash. Tapi bisa juga setup PM2:

```bash
# Install PM2
npm install -g pm2

# Start dengan PM2
pm2 start server.js --name bpr-backend

# Auto-restart on server reboot
pm2 startup
pm2 save
```

### 2. Cek Logs
- **Via cPanel:** Node.js App → View Logs
- **Via SSH:**
```bash
tail -f ~/backend/logs/app.log  # jika ada logging
pm2 logs bpr-backend  # jika pakai PM2
```

### 3. Update Code
Jika ada update:
1. Upload file baru via FTP/File Manager
2. Restart Node.js App di cPanel
```bash
# Atau via SSH
cd ~/backend
git pull  # jika pakai Git
npm install  # jika ada dependency baru
pm2 restart bpr-backend  # jika pakai PM2
```

---

## Security Checklist

- [ ] File `.env` TIDAK terexpose ke public (jangan taruh di public_html)
- [ ] Firebase credentials JSON tidak bisa diakses via web
- [ ] JWT_SECRET pakai value production yang berbeda dari development
- [ ] Gmail App Password dipakai (bukan password akun)
- [ ] CORS hanya allow domain production
- [ ] NODE_ENV=production
- [ ] Rate limiting aktif
- [ ] HTTPS/SSL certificate installed (via cPanel SSL/TLS)
- [ ] Firewall rules di server OK

---

## Alternatif Deployment

Jika cPanel susah atau limited:

### Opsi 1: VPS (DigitalOcean/Vultr/AWS)
- Lebih flexible, full control
- Butuh setup manual Nginx/Apache reverse proxy
- Biaya mulai $5-10/bulan

### Opsi 2: Heroku / Railway / Render
- Free tier available
- Auto deployment dari Git
- Built-in database & monitoring

### Opsi 3: Vercel / Netlify (Serverless)
- Cocok untuk Next.js API Routes
- Perlu refactor backend jadi serverless functions

---

## Support

Jika masih ada masalah:
1. Screenshot error dari cPanel logs
2. Share struktur folder yang sudah diupload
3. Cek browser console untuk CORS/network errors
4. Test endpoint pakai Postman/curl dulu sebelum dari Flutter

**DomainNesia Support:**
- Live Chat: https://www.domainesia.com/
- Ticket support untuk technical issues
