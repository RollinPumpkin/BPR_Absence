# Multi-User Platform Implementation Guide

## Overview
BPR Absence Management System telah berhasil diupgrade menjadi platform multi-user dengan sistem employee_id yang terstruktur untuk memisahkan data berdasarkan peran dan departemen.

## 🏗️ Architecture

### Employee ID Structure
Sistem menggunakan format employee_id yang terstruktur berdasarkan peran:

- **ADM001-ADM999**: Administrator
- **EMP001-EMP999**: General Employees (IT, Finance, HR, etc.)
- **AC001-AC999**: Account Officers
- **SCR001-SCR999**: Security Personnel
- **001-999**: General Staff

### Data Separation
Semua data di Firestore dipisahkan berdasarkan `employee_id`:
- **users**: Profile dan informasi login
- **attendance**: Catatan kehadiran per employee
- **assignments**: Tugas yang diberikan per employee
- **letters**: Surat/permohonan per employee

## 👥 User Accounts

### Login Credentials
```
Admin:
- Email: admin@bpr.com
- Password: admin123
- Employee ID: ADM001

IT Department:
- Email: ahmad.wijaya@bpr.com
- Password: emp001
- Employee ID: EMP001

Finance Department:
- Email: siti.rahayu@bpr.com
- Password: emp002
- Employee ID: EMP002

HR Department:
- Email: dewi.sartika@bpr.com
- Password: emp003
- Employee ID: EMP003

Account Officers:
- Email: rizki.pratama@bpr.com
- Password: ac001
- Employee ID: AC001

- Email: maya.indira@bpr.com
- Password: ac002
- Employee ID: AC002

Security:
- Email: joko.susanto@bpr.com
- Password: scr001
- Employee ID: SCR001

- Email: budi.hartono@bpr.com
- Password: scr002
- Employee ID: SCR002

General Staff:
- Email: lisa.andriani@bpr.com
- Password: staff001
- Employee ID: 001
```

## 📊 Sample Data

### Attendance Records (October 7, 2025)
- **EMP001** (Ahmad): Present 08:00-17:00 (IT Office)
- **EMP002** (Siti): Present 08:15-17:15 (Finance Office)
- **EMP003** (Dewi): Sick Leave (HR - Flu)
- **AC001** (Rizki): Present 07:45-18:30 (Client Visit Surabaya)
- **SCR001** (Joko): Present 22:00-ongoing (Night Shift)

### Active Assignments
- **EMP001**: Develop Mobile App Features (High Priority, Due: Oct 15)
- **EMP002**: Monthly Financial Report (High Priority, Due: Oct 31)
- **EMP003**: Employee Performance Evaluation (Medium Priority, Due: Oct 20)
- **AC001**: Client Portfolio Review (Completed Oct 3)
- **SCR001**: Security System Maintenance (High Priority, Due: Oct 10)

### Pending Letters
- **EMP001**: Annual Leave Request (Bali vacation Oct 15-17)
- **EMP002**: Sick Leave Approval (Oct 5 - Approved)
- **AC001**: Business Trip Request (Surabaya Oct 7-8 - Approved)

## 🔧 Implementation Files

### Backend Scripts
- `seed-multi-user.js`: Populate Firestore with multi-user data
- `test-multi-user-access.js`: Test data separation by employee_id
- `test-login-flow.js`: Test authentication for all roles

### Frontend Updates
- `dummy_data.dart`: Updated with structured employee_id data
- `attendance_form_page.dart`: Integrated with employee_id system
- Authentication uses SharedPreferences to store employee_id

## 🚀 Deployment Instructions

### 1. Seed Database
```bash
cd backend
node seed-multi-user.js
```

### 2. Test System
```bash
# Test data access
node test-multi-user-access.js

# Test login flow
node test-login-flow.js
```

### 3. Run Frontend
```bash
cd frontend
flutter run -d web-server --web-port 8080
```

## 🔐 Security Features

### Data Isolation
- Each employee can only access their own data
- Admin can view all data across the platform
- Firestore queries filtered by employee_id

### Authentication Flow
1. User enters email/password
2. System validates credentials against users collection
3. On success, employee_id stored in SharedPreferences
4. All subsequent requests filtered by employee_id

### Role-Based Access
- **Admin**: Full system access, can view all employees' data
- **Employee**: Can only view/edit their own records
- **Account Officer**: Specialized access for credit-related tasks
- **Security**: Access to security-related functions
- **General Staff**: Basic attendance and assignment access

## 📈 Data Statistics

### User Distribution
- Admin: 1 user
- Employees: 3 users (IT, Finance, HR)
- Account Officers: 2 users
- Security: 2 users
- General Staff: 1 user
- **Total**: 9 active users

### Data Records
- Users: 9 profiles
- Attendance: 5 records (October 7, 2025)
- Assignments: 5 active tasks
- Letters: 3 leave requests

## 🎯 Testing Scenarios

### Login Testing
All 9 user accounts tested successfully:
- Valid credentials: ✅ Login successful
- Invalid credentials: ✅ Properly rejected
- Role verification: ✅ Correct role assignment

### Data Access Testing
Employee data separation verified:
- Each employee sees only their own records
- Admin can access all system data
- No data leakage between employees

### Functional Testing
Core features validated:
- Attendance recording with employee_id
- Assignment tracking per employee
- Letter/leave request system
- Camera integration with square photos
- GPS location tracking

## 🔄 Maintenance

### Adding New Users
1. Add user to Firestore users collection
2. Use appropriate employee_id format (ADM/EMP/AC/SCR/numeric)
3. Set role, department, and initial password
4. Test login and data access

### Monitoring Data
Use provided test scripts to verify:
- Data separation integrity
- Login authentication flow
- Employee_id consistency across collections

## ✅ Verification Checklist

- [x] Multi-user authentication system
- [x] Employee_id-based data separation
- [x] Role-based access control
- [x] Comprehensive dummy data
- [x] Firestore integration
- [x] Security testing passed
- [x] Data isolation verified
- [x] All login credentials working
- [x] Attendance system with employee_id
- [x] Camera integration functional
- [x] Assignment tracking per employee
- [x] Letter system per employee

## 📞 Support

For technical issues:
1. Check Firestore connection
2. Verify employee_id consistency
3. Run test scripts for validation
4. Check Flutter SharedPreferences for stored employee_id

---

**Status**: ✅ Multi-User Platform Implementation Complete
**Last Updated**: October 7, 2025
**Version**: 2.0 - Multi-User Platform