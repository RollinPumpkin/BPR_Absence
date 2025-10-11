# 🔐 USER CREDENTIALS FOR LOGIN TESTING

## ✅ FIREBASE CONFIG FIXED
- ✅ API Key updated in `web/index.html`
- ✅ Using valid Firebase project: `bpr-absens`
- ✅ Firebase NPM Server running on port 3000
- ✅ Flutter Web App running on port 8080

## 👑 ADMIN ACCOUNTS (Recommended for Testing)

### 1. Admin BPR
- **📧 Email**: `admin@bpr.com`
- **🔒 Password**: `123456`
- **👤 Name**: Admin BPR
- **🆔 Employee ID**: ADM001
- **🔐 Role**: ADMIN

### 2. Admin Gmail
- **📧 Email**: `admin@gmail.com`
- **🔒 Password**: `123456`
- **👤 Name**: Admin Test
- **🆔 Employee ID**: ADM002
- **🔐 Role**: ADMIN
- **✅ Status**: Available in Firebase Auth

### 3. Super Admin
- **📧 Email**: `superadmin@bpr.com`
- **🔒 Password**: `123456`
- **👤 Name**: Super Administrator
- **🆔 Employee ID**: SUP001
- **🔐 Role**: SUPER_ADMIN

## 👤 EMPLOYEE ACCOUNTS

### 1. User Test
- **📧 Email**: `user@gmail.com`
- **🔒 Password**: `123456`
- **👤 Name**: User Test
- **🆔 Employee ID**: EMP005
- **🔐 Role**: EMPLOYEE
- **✅ Status**: Available in Firebase Auth

### 2. Ahmad Wijaya
- **📧 Email**: `ahmad.wijaya@bpr.com`
- **🔒 Password**: `123456`
- **👤 Name**: Ahmad Wijaya
- **🆔 Employee ID**: EMP001
- **🔐 Role**: EMPLOYEE
- **✅ Status**: Available in Firebase Auth

### 3. Siti Rahayu
- **📧 Email**: `siti.rahayu@bpr.com`
- **🔒 Password**: `123456`
- **👤 Name**: Siti Rahayu
- **🆔 Employee ID**: EMP002
- **🔐 Role**: EMPLOYEE
- **✅ Status**: Available in Firebase Auth

## 🎯 TESTING STEPS

1. **Open Flutter App**: http://localhost:8080/#/login
2. **Try Admin Login First**:
   - Email: `admin@gmail.com`
   - Password: `123456`
3. **If Admin fails, try User**:
   - Email: `user@gmail.com`
   - Password: `123456`

## 🔍 TROUBLESHOOTING

### ✅ Firebase Config Status
- [x] API Key: AIzaSyCKaOBxr8z7Yo96mP3bQ9h4FE0jQz8Z_Cw
- [x] Project ID: bpr-absens
- [x] Auth Domain: bpr-absens.firebaseapp.com
- [x] Storage Bucket: bpr-absens.appspot.com

### 🔗 Available in Firebase Auth
- ✅ `admin@gmail.com`
- ✅ `user@gmail.com` 
- ✅ `ahmad.wijaya@bpr.com`
- ✅ `siti.rahayu@bpr.com`
- ✅ `budi.santoso@bpr.com`
- ✅ `sarah.manager@bpr.com`

### 📊 Database Status
- **Total Firestore Users**: 19
- **Total Firebase Auth Users**: 6
- **Firebase NPM Server**: ✅ Running
- **Flutter Web App**: ✅ Running

## 🚀 Quick Test Commands

```bash
# Test Firebase server health
curl http://localhost:3000/health

# Open Flutter app
start http://localhost:8080

# Check Firebase server logs
# Check terminal running npm run firebase-server
```

---
💡 **Note**: If login still fails, check browser console for detailed error messages.