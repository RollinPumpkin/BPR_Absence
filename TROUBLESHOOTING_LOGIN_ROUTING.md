## Panduan Troubleshooting Login Routing

### Masalah Saat Ini
- Admin/Super Admin user (SUP001, super_admin) masih diarahkan ke `/user/dashboard` instead of `/admin/dashboard`
- Backend data sudah benar, routing logic sudah benar, tapi real-world behavior masih salah

### Steps Troubleshooting

#### 1. **Clear Browser Cache Completely**
```javascript
// Paste ini di browser console (F12)
localStorage.clear();
sessionStorage.clear();
location.reload(true);
```

#### 2. **Restart Flutter dengan Clean Cache**
```bash
# Gunakan file: force_clean_flutter_restart.bat
# Atau jalankan manual:
cd frontend
flutter clean
flutter pub get
flutter run -d chrome --web-port=8080
```

#### 3. **Debug Navigation Flow**
- Sekarang ada NavigatorObserver yang akan print semua navigation
- Ada stack trace di login_page.dart
- Login dengan admin@gmail.com dan lihat console log

#### 4. **Expected Console Output (Success)**
```
🎯 LOGIN_PAGE DEBUG: User role received: "super_admin"
🎯 LOGIN_PAGE DEBUG: Employee ID: "SUP001"
🎯 LOGIN_PAGE DEBUG: Has admin role: true
🎯 LOGIN_PAGE DEBUG: Has admin employee ID: true
🎯 LOGIN_PAGE DEBUG: Should access admin: true
🚀 NAVIGATION: About to navigate to /admin/dashboard
🧭 NAVIGATION REPLACE: /login → /admin/dashboard
```

#### 5. **Expected Console Output (Problem)**
```
🎯 LOGIN_PAGE DEBUG: User role received: "super_admin"
🎯 LOGIN_PAGE DEBUG: Employee ID: "SUP001"
🎯 LOGIN_PAGE DEBUG: Has admin role: true
🎯 LOGIN_PAGE DEBUG: Has admin employee ID: true
🎯 LOGIN_PAGE DEBUG: Should access admin: true
🚀 NAVIGATION: About to navigate to /user/dashboard  ← WRONG!
🧭 NAVIGATION REPLACE: /login → /user/dashboard     ← WRONG!
```

### Next Actions
1. **Clear cache & restart sesuai instruksi di atas**
2. **Login dengan admin@gmail.com**
3. **Check console output dan bandingkan dengan expected output**
4. **Report console logs untuk analisis lebih lanjut**

### Files Modified
- `main.dart`: Added NavigatorObserver untuk track semua navigation
- `login_page.dart`: Added detailed stack trace
- `force_clean_flutter_restart.bat`: Script untuk clean restart
- `debug_fresh_test.js`: Script untuk clear browser cache