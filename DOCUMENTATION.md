# BPR Absence Management System - Complete Documentation

**Project by "911" Team - BPR Adiartha Reksacipta Internship**

---

## 📑 Table of Contents

1. [Project Overview](#project-overview)
2. [Security Guide - Firebase Credentials](#security-guide)
3. [Notification System](#notification-system)
4. [Work Schedule Management](#work-schedule-management)
5. [Backend Deployment](#backend-deployment)
6. [Mobile Connection & Troubleshooting](#mobile-connection)
7. [APK Build Guide](#apk-build-guide)
8. [Development Workflow](#development-workflow)

---

## 1. Project Overview {#project-overview}

### Tech Stack
- **Frontend**: Flutter (Web & Mobile)
- **Backend**: Node.js + Express
- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth + JWT
- **Hosting**: DomainNesia cPanel

### Key Features
- ✅ Real-time attendance tracking with GPS
- ✅ Leave request management
- ✅ Assignment distribution
- ✅ Admin notification system
- ✅ Individual work schedules
- ✅ Automatic late detection
- ✅ Photo capture for attendance
- ✅ Role-based access control

### Project Structure
```
BPR_Absence/
├── backend/                    # Node.js API Server
│   ├── config/                 # Database & Firebase config
│   ├── middleware/             # Auth & validation
│   ├── routes/                 # API endpoints
│   └── server.js               # Main entry point
├── frontend/                   # Flutter Application
│   ├── lib/
│   │   ├── core/               # Services & constants
│   │   ├── data/               # Models & API
│   │   ├── modules/            # Feature modules
│   │   └── widgets/            # Shared widgets
│   └── pubspec.yaml
└── DOCUMENTATION.md            # This file
```

---

## 2. Security Guide - Firebase Credentials {#security-guide}

### ⚠️ CRITICAL: Firebase Admin SDK Key Management

#### 2.1 Generate New Firebase Admin SDK Key

**Step 1: Access Firebase Console**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **BPR Absens**

**Step 2: Navigate to Service Accounts**
1. Click **Project Settings** (⚙️ gear icon)
2. Go to **Service Accounts** tab
3. Scroll down to **Firebase Admin SDK** section

**Step 3: Generate New Private Key**
1. Click **Generate new private key** button
2. Confirm by clicking **Generate key**
3. A JSON file will be downloaded (e.g., `bpr-absens-firebase-adminsdk-fbsvc-abc123xyz.json`)

**Step 4: Save the Key Securely**
1. Rename the downloaded file to something like: `bpr-absens-firebase-adminsdk-fbsvc-NEW.json`
2. Move it to: `backend/` folder
3. **DO NOT commit this file to Git** (already protected by .gitignore)

#### 2.2 Update Backend Configuration

**Delete Old Exposed Key:**
```cmd
cd backend
del bpr-absens-firebase-adminsdk-fbsvc-da2d17d44d.json
```

**Update config/database.js:**

Find this line (around line 10):
```javascript
const serviceAccountPath = path.join(__dirname, '..', 'bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
```

Change to your new key filename:
```javascript
const serviceAccountPath = path.join(__dirname, '..', 'bpr-absens-firebase-adminsdk-fbsvc-NEW.json');
```

#### 2.3 Revoke Old Compromised Key

1. In Firebase Console → **Project Settings** → **Service Accounts**
2. Click **Manage service account permissions** (opens Google Cloud Console)
3. Find the service account: `firebase-adminsdk-fbsvc@bpr-absens.iam.gserviceaccount.com`
4. Click on the service account email
5. Go to **KEYS** tab
6. Find old keys and delete them (Click **⋮** → **Delete**)

#### 2.4 Security Best Practices

**✅ DO:**
- Use `.gitignore` to exclude all Firebase credentials
- Store credentials in environment variables for production
- Use different keys for development and production
- Rotate keys regularly (every 6 months)
- Enable Firebase App Check for additional security

**❌ DON'T:**
- Commit Firebase credentials to Git
- Share credentials via email/chat
- Use the same key across multiple environments
- Hardcode credentials in source code

**.gitignore Protection:**
```gitignore
# Firebase credentials (already configured)
backend/*firebase*adminsdk*.json
backend/google-services.json
backend/*.zip
.env
.env.local
.env.production
```

#### 2.5 Environment Variables Setup

**backend/.env.production:**
```env
# Environment
NODE_ENV=production
PORT=3000

# Firebase Admin SDK (DO NOT COMMIT)
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@bpr-absens.iam.gserviceaccount.com
FIREBASE_PROJECT_ID=bpr-absens
FIREBASE_ADMIN_KEY_PATH=./bpr-absens-firebase-adminsdk-fbsvc-NEW.json

# JWT
JWT_SECRET=your_unique_production_jwt_secret_here
JWT_EXPIRES_IN=7d

# Email (Gmail SMTP)
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your_gmail_app_password

# CORS
FRONTEND_URL=https://your-production-domain.com
```

---

## 3. Notification System {#notification-system}

### 3.1 Overview

Complete real-time notification system with two components:
1. **Admin Notifications**: Account requests from login page
2. **User Notifications**: Assignments and daily clock-in reminders

### 3.2 Admin Notification System

#### Features
- 🔔 Real-time notifications using Firestore listeners
- 📝 Account request form on login page
- 👥 Role-based access (admin, super_admin, account_officer)
- ✅ Approve/reject requests directly from dashboard
- 🔢 Unread counter badge

#### Architecture

**Service:** `frontend/lib/core/services/admin_notification_service.dart`

**Key Methods:**
```dart
// Initialize with user context
await adminNotificationService.initialize();

// Create notification from login page
await createAccountRequest(
  fullName: 'John Doe',
  email: 'john@example.com',
  phone: '081234567890',
  division: 'IT',
  additionalNotes: 'Urgent request',
);

// Start real-time listener (admin only)
startNotificationsListener();

// Mark as read
await markAsRead(notificationId);

// Update request status
await updateAccountRequestStatus(
  notificationId: id,
  status: 'approved',
  adminNotes: 'Account created',
);
```

#### Firestore Structure

**Collection:** `admin_notifications`

```javascript
{
  type: 'account_request',
  title: 'New Account Request',
  message: 'John Doe requested account access',
  
  data: {
    full_name: 'John Doe',
    email: 'john@example.com',
    phone: '081234567890',
    division: 'IT',
    additional_notes: 'Urgent request'
  },
  
  is_read: false,
  target_roles: ['admin', 'super_admin', 'account_officer'],
  status: 'pending', // pending, approved, rejected
  
  created_at: Timestamp,
  created_by: 'system',
  read_at: Timestamp,
  read_by: 'user_id',
  processed_at: Timestamp,
  processed_by: 'admin_id',
  admin_notes: 'Account created'
}
```

#### UI Components

**1. NotificationBell Widget**
- Location: `frontend/lib/widgets/notification_bell.dart`
- Shows in admin dashboard header
- Red badge with unread count
- Opens bottom sheet on tap

**2. NotificationBottomSheet**
- Slide-up panel with notification list
- "Mark all read" button
- Visual indicators (blue dot for unread)
- Tap to open detail dialog

**3. NotificationDetailDialog**
- Full-screen dialog with request details
- Approve/Reject buttons
- Status badge (pending/approved/rejected)
- Loading states and error handling

**4. AccountRequestDialog**
- Form on login page
- Fields: Name, Email, Phone, Division, Notes
- Validation and error handling

#### Usage Guide

**For Users (Login Page):**
1. Open login page
2. Click "Request Account" link
3. Fill in the form
4. Click "Submit Request"
5. Wait for admin approval

**For Admins:**
1. Login to admin dashboard
2. See notification bell with badge (if new requests)
3. Click bell to open notification panel
4. Click notification to see details
5. Click "Approve" or "Reject"

### 3.3 User Notification System

#### Features
- 📱 Android local notifications
- ⏰ Daily clock-in reminder (7:30 AM)
- 📋 Assignment notifications
- 🔔 Real-time updates via Firestore

#### Service

**Location:** `frontend/lib/core/services/user_notification_service.dart`

**Key Features:**
```dart
// Initialize Android notifications
await _initializeAndroidNotifications();

// Schedule daily clock-in reminder (7:30 AM)
await scheduleDailyClockInReminder();

// Create assignment notification
await createAssignmentNotification(
  userId: 'user_id',
  title: 'New Assignment',
  description: 'You have a new task',
);

// Show Android notification
await _showAndroidNotification(
  id: 1,
  title: 'Clock In Reminder',
  body: 'Don't forget to clock in today!',
);
```

#### Android Configuration

**Add to AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

<application>
    <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    <receiver android:name="com.dexterous.flutterlocalnotifications.BootReceiver">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
        </intent-filter>
    </receiver>
</application>
```

#### Dependencies

**pubspec.yaml:**
```yaml
dependencies:
  flutter_local_notifications: ^17.2.4
  timezone: ^0.9.4
  cloud_firestore: ^latest
  shared_preferences: ^latest
```

---

## 4. Work Schedule Management {#work-schedule-management}

### 4.1 Overview

Individual work schedules for each employee with automatic late detection. No separate collection needed - all data stored in user documents.

### 4.2 Features

- ✅ Individual schedules per employee
- ✅ Admin can edit from Employee Database
- ✅ Automatic late detection
- ✅ Flexible threshold per employee
- ✅ Time picker UI for easy editing

### 4.3 Database Structure

**Firestore Collection:** `users`

Each user document includes:
```javascript
{
  "full_name": "Employee User",
  "email": "employee@bpr.com",
  "role": "employee",
  
  // Work Schedule (NEW)
  "work_start_time": "08:00",          // Format: HH:mm
  "work_end_time": "17:00",            // Format: HH:mm
  "late_threshold_minutes": 15         // Minutes tolerance
}
```

### 4.4 Default Values

If not set:
- work_start_time: `"08:00"`
- work_end_time: `"17:00"`
- late_threshold_minutes: `15`

### 4.5 Late Detection Logic

**Example:**
```
Work Start Time: 08:00
Late Threshold: 15 minutes
Tolerance Window: 08:00 - 08:15
```

| Clock In Time | Status | Reason |
|--------------|--------|--------|
| 07:50 | ✅ present | Before start time |
| 08:00 | ✅ present | Exact start time |
| 08:10 | ✅ present | Within threshold |
| 08:15 | ✅ present | At threshold boundary |
| 08:16 | ⏰ late | Exceeds threshold |
| 08:30 | ⏰ late | Late 30 minutes |

### 4.6 How to Use

**Admin - Set Work Schedule:**

1. Login as admin
2. Navigate to Employee Database
3. Click employee card
4. Click Edit button (pencil icon)
5. Scroll to "Work Schedule" section
6. Set:
   - Work Start Time (time picker)
   - Work End Time (time picker)
   - Late Threshold (in minutes)
7. Click Save

**Backend API:**

```bash
# Update user work schedule
PUT /api/admin/users/:id
Authorization: Bearer ADMIN_TOKEN
Content-Type: application/json

{
  "work_start_time": "09:00",
  "work_end_time": "18:00",
  "late_threshold_minutes": 30
}
```

**Employee - Attendance:**

When employee submits attendance:
1. System fetches user's work schedule
2. Compares clock-in time with (work_start_time + late_threshold_minutes)
3. Sets status automatically:
   - `present`: On time
   - `late`: Exceeds threshold

### 4.7 Files Modified

**Backend:**
- `backend/routes/admin.js` - Added PUT endpoint
- `backend/routes/attendance.js` - Updated late detection

**Frontend:**
- `frontend/lib/data/models/user.dart` - Added 3 fields
- `frontend/lib/modules/admin/employee/models/employee.dart` - Added fields
- `frontend/lib/modules/admin/employee/pages/edit_page.dart` - Added UI
- `frontend/lib/modules/admin/employee/pages/details_page.dart` - Display info

---

## 5. Backend Deployment {#backend-deployment}

### 5.1 Deployment to DomainNesia cPanel

#### 5.1.1 Prerequisites

**Check cPanel Node.js Support:**
1. Login to cPanel
2. Look for **"Setup Node.js App"** or **"Node.js Selector"**
3. Verify Node.js 16+ is available

#### 5.1.2 Files to Upload

```
backend/
├── config/
├── middleware/
├── routes/
├── services/
├── bpr-absens-firebase-adminsdk-fbsvc-NEW.json
├── server.js
├── package.json
└── .env (create manually on server)
```

**⚠️ DO NOT Upload:**
- `node_modules/` (CloudLinux creates symlink automatically)
- `.git/`
- Test files (`test-*.js`, `show-*.js`)

#### 5.1.3 Upload Methods

**Method A: ZIP + Extract (Recommended)**

1. **Create ZIP file:**
   - Zip the entire `backend/` folder
   - Exclude `node_modules/`

2. **Upload to cPanel:**
   - Login to cPanel → **File Manager**
   - Navigate to Home Directory (NOT public_html)
   - Click **Upload**
   - Upload the ZIP file
   - Wait for 100% completion

3. **Extract:**
   - Right-click the ZIP file
   - Select **Extract**
   - Choose destination
   - Click **Extract Files**

4. **Show Hidden Files:**
   - Click **Settings** (⚙️ icon)
   - Check **"Show Hidden Files (dotfiles)"**
   - Rename `.env.production` → `.env`

**Method B: FTP Upload**

1. Use FileZilla or similar FTP client
2. Connect to cPanel FTP:
   - Host: `ftp.yourdomain.com`
   - Username: (from cPanel FTP Accounts)
   - Password: (your FTP password)
   - Port: 21
3. Drag and drop `backend/` folder
4. FTP preserves folder structure

#### 5.1.4 Setup Node.js Application

1. Open **"Setup Node.js App"** in cPanel
2. Click **"Create Application"**
3. Configure:
   - **Node.js Version:** Latest (16+, 18+ recommended)
   - **Application Mode:** Production
   - **Application Root:** `backend`
   - **Application URL:** (leave empty)
   - **Application Startup File:** `server.js`
4. Click **"Create"**

**Note:** cPanel assigns port automatically (not 3000)

#### 5.1.5 Install Dependencies

**Option 1: Via cPanel**
- Click **"Run NPM Install"** button
- Wait 2-5 minutes

**Option 2: Via SSH**
```bash
cd ~/backend
npm install --production
```

#### 5.1.6 Environment Variables

Create `.env` file manually in backend folder:

```env
# Environment
NODE_ENV=production
PORT=XXXX  # Port from cPanel (auto-assigned)

# Firebase Admin SDK
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@bpr-absens.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_PROJECT_ID=bpr-absens

# JWT
JWT_SECRET=production_secret_key_here
JWT_EXPIRES_IN=7d

# Email (Gmail SMTP)
EMAIL_USER=youremail@gmail.com
EMAIL_PASS=gmail_app_password

# Upload
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880

# CORS
FRONTEND_URL=https://yourdomain.com

# Rate limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

**Important:** Change these values:
- `PORT` → Port from cPanel
- `EMAIL_PASS` → Gmail App Password (not regular password)
- `FRONTEND_URL` → Your production domain

#### 5.1.7 Setup Subdomain & Proxy

**Create Subdomain:**
1. cPanel → **Domains** → **Create a New Domain**
2. Subdomain: `api` (becomes api.yourdomain.com)
3. Document Root: Point to `public_html/api`

**Create .htaccess for Proxy:**

In subdomain document root:
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://localhost:PORT_FROM_CPANEL/$1 [P,L]
```

Replace `PORT_FROM_CPANEL` with the port assigned by Node.js App.

#### 5.1.8 Start Application

1. In **"Setup Node.js App"** page
2. Click **"Restart"** or **"Start App"**
3. Status should show **"Running"**
4. Check logs if errors occur

#### 5.1.9 Testing

**Test Health Endpoint:**
```bash
curl https://api.yourdomain.com/health
```

Expected response:
```json
{
  "status": "OK",
  "timestamp": "...",
  "clientIp": "..."
}
```

**Test Login API:**
```bash
curl -X POST https://api.yourdomain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}'
```

**Test from Browser:**
```
https://api.yourdomain.com/health
```

#### 5.1.10 Update Flutter Config

**frontend/lib/data/constants/server_config.dart:**
```dart
class ServerConfig {
  static const String productionServerHost = "api.yourdomain.com";
  static const int productionServerPort = 443; // HTTPS
  static const bool useHttpsInProduction = true;
  
  static const bool useNgrok = false; // Disable for production
  
  static String get firebaseServerUrl {
    if (kReleaseMode || useHttpsInProduction) {
      return 'https://$productionServerHost';
    }
    return 'http://$productionServerHost:$productionServerPort';
  }
}
```

### 5.2 Troubleshooting Deployment

**Problem: Node.js App Won't Start**

Solution:
```bash
# Via SSH
cd ~/backend
npm install
node server.js  # Test manually
```

Common causes:
- Missing dependencies
- Wrong environment variables
- Port conflict

**Problem: Cannot Access API from Domain**

Check:
- Is .htaccess proxy configured correctly?
- Has subdomain propagated? (wait 5-15 minutes)
- Check Apache error logs in cPanel

**Problem: Firebase Connection Error**

Check:
- Firebase Admin SDK JSON file uploaded?
- Path correct in `config/database.js`?
- Environment variables set correctly?

**Problem: CORS Error**

Update `.env`:
```env
FRONTEND_URL=https://yourdomain.com
```

Verify in `server.js`:
```javascript
app.use(cors({
  origin: process.env.FRONTEND_URL,
  credentials: true
}));
```

**Problem: File Upload Not Working**

Check permissions:
```bash
mkdir uploads
chmod 755 uploads
```

### 5.3 Monitoring & Maintenance

**Logs:**
- Via cPanel: Node.js App → View Logs
- Via SSH: `tail -f ~/backend/logs/app.log`

**Update Code:**
1. Upload new files via FTP/File Manager
2. Restart Node.js App in cPanel
3. Or via SSH:
```bash
cd ~/backend
git pull  # if using Git
npm install  # if dependencies changed
```

**Auto-restart with PM2 (Advanced):**
```bash
npm install -g pm2
pm2 start server.js --name bpr-backend
pm2 startup
pm2 save
```

---

## 6. Mobile Connection & Troubleshooting {#mobile-connection}

### 6.1 Network Configuration

#### 6.1.1 Get Your PC IP Address

**Windows:**
```cmd
ipconfig
```

Look for **"Wi-Fi"** adapter → **IPv4 Address** (e.g., `192.168.1.100`)

#### 6.1.2 Update Server Config

**frontend/lib/data/constants/server_config.dart:**
```dart
static const String localServerHost = '192.168.1.100'; // YOUR IP HERE
static const int localServerPort = 3000;
```

### 6.2 Timeout Configuration

**frontend/lib/data/services/api_service.dart:**
```dart
// Extended timeout for mobile connections
connectTimeout: const Duration(seconds: 120), // 2 minutes
receiveTimeout: const Duration(seconds: 120),
sendTimeout: const Duration(seconds: 120),

// Keep connection alive
persistentConnection: true,
followRedirects: true,
maxRedirects: 5,

headers: {
  'Connection': 'keep-alive',
}
```

### 6.3 Retry Mechanism

Automatic retry with exponential backoff:
```dart
const maxRetries = 3;
if (_shouldRetry(error) && retryCount < maxRetries) {
  final delaySeconds = 2 * (retryCount + 1); // 2s, 4s, 8s
  await Future.delayed(Duration(seconds: delaySeconds));
  // Retry request...
}
```

### 6.4 CORS Configuration

**backend/server.js:**
```javascript
// Allow all origins in development
if (process.env.NODE_ENV === 'development') {
  console.log(`✅ CORS Allowed (Development): ${origin || 'no-origin'}`);
  callback(null, true);
}
```

### 6.5 Firewall Setup

**Windows Firewall Rule:**

Create file: `add-firewall-rule.bat`
```batch
@echo off
echo Adding Windows Firewall rule for Node.js port 3000...

netsh advfirewall firewall add rule ^
  name="Node.js Server - Port 3000" ^
  dir=in action=allow protocol=TCP localport=3000

echo Rule added successfully!
pause
```

Run as Administrator.

### 6.6 Testing Mobile Connection

**Step 1: Start Backend**
```cmd
cd backend
node server.js
```

**Step 2: Test from PC**
```cmd
curl http://localhost:3000/health
curl http://192.168.1.100:3000/health
```

**Step 3: Test from Mobile Browser**

Open browser on phone:
```
http://192.168.1.100:3000/health
```

Should see:
```json
{
  "status": "OK",
  "timestamp": "2025-12-05T10:30:00.000Z"
}
```

**Step 4: Test Flutter App**

1. Ensure phone and PC on same Wi-Fi
2. Build or run Flutter app
3. Try login

### 6.7 Troubleshooting Mobile Connection

**Problem: Connection Timeout (120 seconds)**

Diagnosis:
- Backend not running
- Firewall blocking port 3000
- Phone and PC on different networks

Solution:
1. Start backend: `cd backend && node server.js`
2. Add firewall rule (run bat file as admin)
3. Verify both devices on same Wi-Fi
4. Test with mobile browser first

**Problem: Network Unreachable**

Solution:
1. Check IP with `ipconfig` - ensure correct IP
2. Phone and PC MUST be on same Wi-Fi
3. Don't use VPN
4. Test ping from phone to PC

**Problem: Still Timeout After Fixes**

Advanced Solutions:

1. **Check if port 3000 is open:**
```cmd
netstat -ano | findstr :3000
```

2. **Test from CMD:**
```cmd
curl http://localhost:3000/health
curl http://192.168.1.100:3000/health
```

3. **Temporarily disable firewall (for testing only):**
```cmd
netsh advfirewall set allprofiles state off
```
(Re-enable after test!)

4. **Check Windows Defender:**
- Windows Security → Firewall & network protection
- Allow an app through firewall
- Find "Node.js" → Check Private and Public

5. **Test with browser first:**
- Open: `http://192.168.1.100:3000/health` on phone browser
- If works = backend OK, problem in Flutter app
- If fails = network/firewall issue

### 6.8 Performance Notes

**Expected Response Times:**
- Localhost (PC): < 1 second ✅
- Wi-Fi (same network): 1-5 seconds ✅
- Mobile data: 10-60 seconds ⚠️
- Slow network: up to 120 seconds 🐌

**Timeout Configuration:**
- ⏱️ Connect: 120 seconds
- ⏱️ Receive: 120 seconds
- ⏱️ Send: 120 seconds
- 🔄 Retry: 3 attempts (2s, 4s, 8s backoff)

### 6.9 Quick Test Checklist

- [ ] Backend running (`node server.js`)
- [ ] Firewall rule added (port 3000)
- [ ] Phone and PC on same Wi-Fi
- [ ] IP correct in `server_config.dart`
- [ ] Test page accessible in mobile browser
- [ ] Health endpoint OK
- [ ] Login from app successful

---

## 7. APK Build Guide {#apk-build-guide}

### 7.1 Prerequisites

**Install Java 17 LTS:**
- Download from: https://adoptium.net/
- Install to: `C:\Program Files\Java\jdk-17`
- Set JAVA_HOME environment variable

**Why Java 17?**
- Kotlin compiler doesn't support Java 25
- Flutter requires Java 11-17
- Java 17 is LTS (Long Term Support)

### 7.2 Android Configuration

#### 7.2.1 Firebase Setup

**File:** `frontend/android/app/build.gradle.kts`

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Must be enabled
}

dependencies {
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    implementation("com.google.firebase:firebase-analytics")
    
    // MultiDex (required for Firebase)
    implementation("androidx.multidex:multidex:2.0.1")
}
```

#### 7.2.2 MultiDex Configuration

```kotlin
android {
    defaultConfig {
        applicationId = "BPR.Absens"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        
        multiDexEnabled = true // ✅ Required for Firebase
    }
}
```

#### 7.2.3 MainApplication Setup

**File:** `frontend/android/app/src/main/kotlin/BPR/Absens/MainApplication.kt`

```kotlin
package BPR.Absens

import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex
import android.content.Context

class MainApplication : FlutterApplication() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
```

#### 7.2.4 AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application
        android:name=".MainApplication"
        android:label="BPR Absence"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Notification receivers -->
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:name="com.dexterous.flutterlocalnotifications.BootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>
        
        <!-- MainActivity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

#### 7.2.5 Google Services JSON

Ensure `google-services.json` exists:
```
frontend/android/app/google-services.json
```

Download from Firebase Console if missing:
1. Firebase Console → Project Settings
2. Your apps → Android app
3. Click "google-services.json" download button

### 7.3 Build Commands

#### 7.3.1 Build Script (Recommended)

Create: `build-apk.bat`
```batch
@echo off
echo ========================================
echo Building APK with Java 17
echo ========================================

REM Set Java 17
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo Using Java:
java -version

echo.
echo Cleaning previous build...
cd frontend
call flutter clean

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Building APK (Release)...
call flutter build apk --release

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Location:
echo frontend\build\app\outputs\flutter-apk\app-release.apk
echo.
pause
```

Run: Double-click `build-apk.bat`

#### 7.3.2 Manual Build

```cmd
REM Set Java 17
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;%PATH%"

REM Navigate to frontend
cd frontend

REM Clean previous builds
flutter clean

REM Get dependencies
flutter pub get

REM Build release APK
flutter build apk --release

REM Build debug APK (for testing)
flutter build apk --debug

REM Build split APKs (smaller files, per architecture)
flutter build apk --split-per-abi
```

#### 7.3.3 Build Output

**Release APK:**
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```

**Debug APK:**
```
frontend/build/app/outputs/flutter-apk/app-debug.apk
```

**Split APKs:**
```
frontend/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
frontend/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
frontend/build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### 7.4 Installing APK

#### 7.4.1 Via ADB (USB)

```cmd
REM Connect phone via USB
REM Enable USB Debugging on phone

REM Install APK
adb install frontend\build\app\outputs\flutter-apk\app-release.apk

REM If already installed, use -r to reinstall
adb install -r frontend\build\app\outputs\flutter-apk\app-release.apk
```

#### 7.4.2 Via File Transfer

1. Copy APK to phone storage
2. Open file manager on phone
3. Tap the APK file
4. Click "Install"
5. Allow installation from unknown sources if prompted

### 7.5 Troubleshooting APK Build

**Problem: "Gradle build failed"**

Solution:
```cmd
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

**Problem: "java.lang.IllegalArgumentException: 25.0.1"**

Solution:
- Install Java 17 LTS
- Use build script with JAVA_HOME set
- Verify: `java -version` should show version 17

**Problem: "MultiDex Error"**

Solution:
- Ensure `multiDexEnabled = true` in build.gradle.kts
- Add MultiDex dependency
- Create MainApplication.kt with MultiDex.install()

**Problem: "Firebase not initialized"**

Solution:
- Check `google-services.json` exists
- Verify Firebase plugin enabled in build.gradle.kts
- Ensure Firebase BOM dependency added

**Problem: APK Force Close on Launch**

Solution:
1. Build debug APK: `flutter build apk --debug`
2. Install to device
3. Check logs: `adb logcat *:E`
4. Look for specific error messages
5. Common causes:
   - Missing MainApplication.kt
   - Firebase configuration error
   - MultiDex not installed

**Problem: APK Size Too Large (>100MB)**

Solution:
- Use split APKs: `flutter build apk --split-per-abi`
- This creates 3 separate APKs (~30MB each)
- Upload all to Play Store (will auto-select correct one)

### 7.6 APK Size Comparison

- Debug APK: ~85 MB (includes debug symbols)
- Release APK: ~55-60 MB (optimized)
- Split APK: 3 files @ ~30 MB each (per architecture)

### 7.7 Build Checklist

- [ ] Java 17 installed and JAVA_HOME set
- [ ] Firebase google-services.json present
- [ ] MultiDex enabled in build.gradle.kts
- [ ] MainApplication.kt created
- [ ] AndroidManifest.xml uses .MainApplication
- [ ] Flutter clean executed
- [ ] Dependencies updated (flutter pub get)
- [ ] Build completed successfully
- [ ] APK tested on physical device
- [ ] No force close on launch
- [ ] Login works
- [ ] Core features functional

---

## 8. Development Workflow {#development-workflow}

### 8.1 Local Development Setup

**Start Backend:**
```cmd
cd backend
node server.js
```

Expected output:
```
🚀 Server running on port 3000
✅ Firebase Admin initialized successfully
🌐 Local: http://localhost:3000
🌐 Network: http://192.168.1.100:3000
```

**Start Flutter Web:**
```cmd
cd frontend
flutter run -d chrome --web-port=8080
```

Access at: `http://localhost:8080`

**Start Flutter Mobile (Android):**
```cmd
cd frontend
flutter run
```

### 8.2 Testing

**Backend API Tests:**
```bash
# Health check
curl http://localhost:3000/health

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@bpr.com","password":"admin123"}'

# Get users (with auth token)
curl http://localhost:3000/api/admin/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Flutter Tests:**
```cmd
cd frontend
flutter test
```

### 8.3 Common Commands

**Clean Build:**
```cmd
cd frontend
flutter clean
flutter pub get
flutter run
```

**Update Dependencies:**
```cmd
cd frontend
flutter pub upgrade
```

**Format Code:**
```cmd
flutter format lib/
```

**Analyze Code:**
```cmd
flutter analyze
```

### 8.4 Git Workflow

**Check Status:**
```cmd
git status
```

**Commit Changes:**
```cmd
git add .
git commit -m "Your commit message"
git push origin main
```

**Pull Latest:**
```cmd
git pull origin main
```

### 8.5 Environment Variables

**Development (.env):**
```env
NODE_ENV=development
PORT=3000
JWT_SECRET=dev_secret_key
FRONTEND_URL=http://localhost:8080
```

**Production (.env.production):**
```env
NODE_ENV=production
PORT=443
JWT_SECRET=production_secret_key
FRONTEND_URL=https://yourdomain.com
```

### 8.6 Debugging

**Backend Logs:**
```javascript
console.log('🔥 Debug info:', data);
console.error('❌ Error:', error);
```

**Flutter Logs:**
```dart
print('🔥 Debug info: $data');
debugPrint('❌ Error: $error');
```

**Chrome DevTools:**
- F12 to open DevTools
- Console tab for logs
- Network tab for API requests
- Sources tab for breakpoints

**Android Logs:**
```cmd
adb logcat *:E  # Errors only
adb logcat | findstr "BPR"  # Filter by app
```

---

## 📞 Support & Resources

### Documentation
- Flutter: https://docs.flutter.dev/
- Firebase: https://firebase.google.com/docs
- Node.js: https://nodejs.org/docs/
- Express: https://expressjs.com/

### Tools
- VS Code: https://code.visualstudio.com/
- Android Studio: https://developer.android.com/studio
- Postman: https://www.postman.com/
- Git: https://git-scm.com/

### Team Contact
- Project: BPR Absence Management System
- Team: "911" Internship Team
- Company: BPR Adiartha Reksacipta

---

**Last Updated:** December 5, 2025  
**Version:** 1.0  
**Status:** ✅ Production Ready
