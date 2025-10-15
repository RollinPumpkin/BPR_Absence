# 🧪 LOGIN FLOW TEST GUIDE

## 📋 **PRE-TEST CHECKLIST**

### 1. Clear Browser Cache
```javascript
// Paste di browser console (F12)
localStorage.clear();
sessionStorage.clear();
console.log('✅ Cache cleared');
location.reload(true);
```

### 2. Verify Servers Running
- Backend: http://localhost:3000 ✅
- Frontend: http://localhost:8080 ✅

## 🔍 **TEST SCENARIOS**

### Test 1: Admin Login Flow
```
Credentials:
- Email: admin@gmail.com
- Password: 123456

Expected Results:
✅ Login successful
✅ Route to /admin/dashboard
✅ Console shows: role "super_admin", employee_id "SUP001"
✅ Admin features accessible
```

### Test 2: User Login Flow  
```
Credentials:
- Email: user@gmail.com
- Password: 123456

Expected Results:
✅ Login successful
✅ Route to /user/dashboard
✅ Console shows: role "employee"
✅ User features only
```

## 🔎 **EXPECTED CONSOLE OUTPUT**

### Admin Login Success:
```
🎯 AUTH_PROVIDER DEBUG: User role: "super_admin"
🎯 AUTH_PROVIDER DEBUG: Employee ID: "SUP001"
🎯 LOGIN_PAGE DEBUG: Has admin role: true
🎯 LOGIN_PAGE DEBUG: Should access admin: true
🚀 NAVIGATION: About to navigate to /admin/dashboard
🧭 NAVIGATION REPLACE: /login → /admin/dashboard
```

### User Login Success:
```
🎯 AUTH_PROVIDER DEBUG: User role: "employee"
🎯 LOGIN_PAGE DEBUG: Has admin role: false
🎯 LOGIN_PAGE DEBUG: Should access admin: false
🚀 NAVIGATION: About to navigate to /user/dashboard
🧭 NAVIGATION REPLACE: /login → /user/dashboard
```

## ⚠️ **TROUBLESHOOTING**

### If Admin Goes to User Dashboard:
1. Check console for actual role received
2. Verify using exact email: admin@gmail.com
3. Verify using exact password: 123456
4. Clear cache completely and retry

### If Login Fails:
1. Check backend server is running
2. Check network tab for API errors
3. Verify credentials in browser console
4. Check Firebase connection

## 📝 **TEST EXECUTION STEPS**

1. **Clear cache & refresh page**
2. **Open browser console (F12)**
3. **Login with admin@gmail.com + 123456**
4. **Record console output**
5. **Verify navigation to admin dashboard**
6. **Logout**
7. **Login with user@gmail.com + 123456**
8. **Verify navigation to user dashboard**

## 🎯 **SUCCESS CRITERIA**

- ✅ Admin credentials → Admin dashboard
- ✅ User credentials → User dashboard  
- ✅ Correct role detection in console
- ✅ Proper navigation logging
- ✅ No routing errors or incorrect redirects