# 📧 **Real Email Setup Guide for BPR Absence System**

## 🎯 **Current Status**
- ✅ Your Gmail (`septapuma@gmail.com`) is registered in the system
- ✅ Login credentials: `septapuma@gmail.com` / `123456`
- ✅ Forgot password generates reset tokens and saves to database
- ⚠️ **Currently in Demo Mode** - no real emails sent yet

---

## 🚀 **To Enable REAL Email Sending:**

### **Option 1: Use Your Personal Gmail (Quick Test)**

1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate an App Password:**
   - Go to: https://myaccount.google.com/apppasswords
   - Select app: "Mail" 
   - Select device: "Windows Computer"
   - Copy the generated 16-character password

3. **Update Email Configuration:**
   ```bash
   # In your terminal, set environment variables:
   set EMAIL_USER=septapuma@gmail.com
   set EMAIL_PASS=your-16-character-app-password
   ```

4. **Restart the backend server:**
   ```bash
   cd c:\laragon\www\BPR_Absence\backend
   npm start
   ```

### **Option 2: Use a Dedicated App Email (Recommended)**

1. **Create a new Gmail account** for the app (e.g., `bpr-absence-system@gmail.com`)
2. **Follow the same App Password setup** as Option 1
3. **Update the email service configuration** in `backend/services/emailService.js`

---

## 🧪 **Testing Steps:**

### **1. Test with Demo Mode (Current)**
```bash
curl -X POST http://localhost:3000/api/auth/forgot-password \
     -H "Content-Type: application/json" \
     -d '{"email":"septapuma@gmail.com"}'
```
**Expected Response:** `"demo": true, "emailSent": false`

### **2. Test with Real Emails (After Setup)**
- Same curl command as above
- **Expected Response:** `"emailSent": true` 
- **Check your Gmail inbox** for the reset email

### **3. Frontend Testing**
1. Open: http://localhost:8080/#/forgot-password
2. Enter: `septapuma@gmail.com`
3. Click "Reset password"
4. Check response message and your Gmail inbox

---

## 📋 **What Happens When You Test:**

### **Current Demo Mode:**
- ✅ Validates email exists in system
- ✅ Generates secure reset token
- ✅ Saves reset token to Firebase (`password_resets` collection)
- ✅ Returns success message
- ❌ **No real email sent** (falls back to demo mode)

### **With Real Email Setup:**
- ✅ All above steps
- ✅ **Sends actual HTML email** to your Gmail
- ✅ Email contains secure reset link
- ✅ Link expires in 24 hours
- ✅ Professional email template with BPR branding

---

## 🔗 **Reset Link Format:**
```
http://localhost:8080/#/reset-password?token=abc123xyz789&email=septapuma@gmail.com
```

## 🗄️ **Database Structure:**
The system creates a `password_resets` collection with:
```json
{
  "email": "septapuma@gmail.com",
  "token": "secure-random-token",
  "expires_at": "2025-10-20T12:00:00Z",
  "created_at": "2025-10-19T12:00:00Z", 
  "used": false
}
```

---

## ⚡ **Quick Start (Test Right Now):**

1. **Test the forgot password page:**
   - Visit: http://localhost:8080/#/forgot-password
   - Enter: `septapuma@gmail.com`
   - Click "Reset password"

2. **You should see:** `"Password reset instructions sent to your email"`

3. **To enable real emails:** Follow Option 1 above

---

## 🔒 **Security Features:**
- ✅ Secure random token generation
- ✅ 24-hour expiration
- ✅ One-time use tokens
- ✅ Email validation
- ✅ Rate limiting ready
- ✅ HTML email templates

**Your account is ready to test! The forgot password feature is fully functional - just needs email service configuration for real email delivery.**