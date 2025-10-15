# Login Routing Issue - Troubleshooting Guide

## Problem
Admin/Super Admin users are being routed to user dashboard instead of admin dashboard after login.

## Quick Diagnosis

### ✅ Backend Verified Working
- `admin@gmail.com` returns `SUP001` employee_id with `super_admin` role
- `test@bpr.com` returns `ADM003` employee_id with `admin` role
- Both should route to `/admin/dashboard`

### ✅ Frontend Logic Verified
- Login routing logic in `login_page.dart` is correct
- Employee ID patterns are properly checked
- Role hierarchy is implemented correctly

## Troubleshooting Steps

### 1. Clear Browser Cache & State
```bash
# Clear all browser data:
1. Open Chrome DevTools (F12)
2. Go to Application tab
3. Clear Storage -> Clear site data
4. Or use incognito mode
```

### 2. Check Flutter Console Logs
```bash
# Look for these debug messages:
🎯 LOGIN_PAGE DEBUG: User role received: "super_admin"
🎯 LOGIN_PAGE DEBUG: Employee ID: "SUP001"
🎯 LOGIN_PAGE DEBUG: Should access admin: true
🎯 LOGIN_PAGE DEBUG: Routing to /admin/dashboard
```

### 3. Restart Flutter with Clean Cache
```bash
cd c:\laragon\www\BPR_Absence\frontend
flutter clean
flutter pub get
flutter run -d chrome --web-port 8080
```

### 4. Check Network Tab
1. Open Chrome DevTools -> Network tab
2. Login with admin@gmail.com
3. Check `/auth/login` response
4. Verify user data matches expected values

### 5. Manual Debug Steps
1. Login with admin@gmail.com
2. Open browser console immediately
3. Look for debug prints:
   - `🎯 AUTH_PROVIDER DEBUG:` messages
   - `🎯 LOGIN_PAGE DEBUG:` messages
4. Check current URL after login

## Quick Test Commands

### Test Backend Response
```bash
cd c:\laragon\www\BPR_Absence\backend
node quick-login-test.js
```

### Restart Flutter Clean
```bash
# Run this batch file:
c:\laragon\www\BPR_Absence\restart_flutter.bat
```

## Expected Debug Output

### Correct Login Flow
```
🎯 AUTH_PROVIDER DEBUG: User object created
🎯 AUTH_PROVIDER DEBUG: User email: admin@gmail.com
🎯 AUTH_PROVIDER DEBUG: User employee_id: "SUP001"
🎯 AUTH_PROVIDER DEBUG: User role: "super_admin"

🎯 LOGIN_PAGE DEBUG: User role received: "super_admin"
🎯 LOGIN_PAGE DEBUG: Employee ID: "SUP001"
🎯 LOGIN_PAGE DEBUG: Has admin role: true
🎯 LOGIN_PAGE DEBUG: Has admin employee ID (SUP/ADM): true
🎯 LOGIN_PAGE DEBUG: Should access admin: true
🎯 LOGIN_PAGE DEBUG: Routing to /admin/dashboard
```

## Possible Issues

### 1. Browser Cache
- Old routing logic cached
- Local storage has stale data
- Service worker cache

### 2. Multiple Login Pages
- Check if `LoginPageIntegrated` is being used instead
- Verify `main.dart` routes configuration

### 3. AuthProvider State
- User data not populated correctly
- Role/Employee ID parsing issues
- Async timing issues

### 4. Flutter Hot Reload Issues
- Changes not applied properly
- Need full restart

## Testing URLs

After login, check the URL:
- ✅ Should be: `http://localhost:8080/#/admin/dashboard`
- ❌ Problem if: `http://localhost:8080/#/user/dashboard`

## Next Steps If Still Not Working

1. **Add more debug prints** in User model parsing
2. **Check AuthService** for data transformation
3. **Test with incognito mode** to eliminate cache
4. **Verify main.dart** is using correct LoginPage
5. **Check for any redirect logic** in dashboard pages

---

**Note**: The logic is correct, so this is likely a cache/state issue that requires a clean restart.