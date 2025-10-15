# 📊 DATABASE STRUCTURE ANALYSIS - BPR ABSENCE SYSTEM

**Generated on:** October 15, 2025  
**Database:** Firestore (Firebase)  
**Environment:** Development  

---

## 📚 **COLLECTIONS OVERVIEW**

| Collection | Documents | Purpose |
|------------|-----------|---------|
| users | 22 | User accounts and employee data |
| letters | 10 | Letter/document management system |
| letter_templates | 5 | Pre-defined letter templates |
| attendance | 5 | Employee attendance tracking |
| leave_requests | 5 | Leave/vacation request management |
| assignments | 5 | Task assignment system |
| notifications | 3 | System notifications |
| qr_codes | 5 | QR codes for attendance check-in |
| settings | 2 | Application configuration |

---

## 👥 **USERS COLLECTION**

### **Schema Structure:**
```json
{
  "full_name": "string",
  "email": "string (unique)",
  "employee_id": "string (unique)",
  "department": "string",
  "position": "string", 
  "phone": "string",
  "password": "string (hashed)",
  "role": "employee | admin | super_admin",
  "profile_image": "string (url)",
  "is_active": "boolean",
  "firebase_uid": "string (nullable)",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### **Role Distribution:**
- **Employee**: 14 users
- **Admin**: 4 users  
- **Super Admin**: 4 users
- **Total**: 22 users

### **Key Admin Users:**
1. **SUP001** - admin@gmail.com (Super Admin) ✅ Firebase linked
2. **SUP999** - superadmin@test.com (Super Admin) ✅ Firebase linked  
3. **ADM999** - admin@test.com (Admin) ✅ Firebase linked
4. **ADM001** - test@bpr.com (Admin) ✅ Firebase linked

### **Firebase Integration Status:**
- **Linked to Firebase**: 6 users
- **Not linked**: 16 users

---

## 📄 **LETTERS COLLECTION**

### **Schema Structure:**
```json
{
  "sender_id": "string (user ID)",
  "recipient_id": "string", 
  "subject": "string",
  "content": "string",
  "letter_type": "sick_leave | work_certificate | family_leave | appreciation",
  "letter_number": "string (auto-generated)",
  "letter_date": "date",
  "priority": "normal | high | urgent",
  "status": "pending | approved | rejected | waiting_approval",
  "requires_response": "boolean",
  "response_deadline": "date",
  "attachments": "array",
  "cc_recipients": "array",
  "template_used": "string (nullable)",
  "reference_number": "string (nullable)",
  "read_at": "timestamp (nullable)",
  "response_received": "boolean",
  "response_content": "string (nullable)",
  "response_date": "timestamp (nullable)",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### **Status Distribution:**
- **Pending**: 7 letters (needs admin approval)
- **Approved**: 2 letters
- **Waiting Approval**: 1 letter
- **Total**: 10 letters

### **Letter Types:**
- Sick Leave (Cuti Sakit)
- Work Certificate (Surat Keterangan Kerja) 
- Family Leave (Izin Keperluan Keluarga)
- Appreciation Letter

---

## 📋 **LETTER_TEMPLATES COLLECTION**

### **Available Templates:**
1. **Appreciation Letter** - Recognition/appreciation template
2. **Sick Leave** - Medical leave request template  
3. **Work Certificate** - Employment verification template
4. **Family Leave** - Family emergency leave template
5. **General Letter** - Multi-purpose template

### **Template Variables:**
- `{{employee_name}}`
- `{{achievement_description}}`
- `{{period}}`
- `{{sender_name}}`
- `{{sender_position}}`

---

## ⏰ **ATTENDANCE COLLECTION**

### **Schema Structure:**
```json
{
  "user_id": "string",
  "date": "date (YYYY-MM-DD)",
  "check_in_time": "time (HH:MM:SS)",
  "check_out_time": "time (HH:MM:SS)",
  "check_in_location": "string",
  "check_out_location": "string", 
  "status": "present | late | absent | half_day",
  "notes": "string",
  "qr_code_used": "string",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

---

## 📱 **QR_CODES COLLECTION**

### **Active QR Codes:**
1. **BPR_MainOffice_1759822591017** - Kantor Pusat BPR Adiartha Reksacipta
2. **BPR_Branch1_1759822592018** - Cabang Denpasar
3. **BPR_Branch2_1759822593018** - Cabang Ubud  
4. **BPR_MainOffice_1759584606** - Main Office (Legacy)
5. **BPR_Branch_9876543210** - Branch Office (Legacy)

---

## 📋 **LEAVE_REQUESTS COLLECTION**

### **Leave Types:**
- Annual Leave
- Sick Leave
- Emergency Leave

### **Status Options:**
- Pending
- Approved  
- Rejected

---

## 📝 **ASSIGNMENTS COLLECTION**

### **Current Assignments:**
- Client Portfolio Review (Completed)
- Employee Performance Evaluation (In Progress)
- Develop Mobile App Features (In Progress)

---

## ⚙️ **SETTINGS COLLECTION**

### **Application Configuration:**
```json
{
  "app_name": "BPR Absence Management",
  "work_start_time": "08:00",
  "work_end_time": "17:00", 
  "late_threshold_minutes": 15,
  "attendance_radius_meters": 100,
  "qr_code_expiry_hours": 24,
  "notification_enabled": true,
  "auto_checkout_enabled": false
}
```

---

## 🔔 **NOTIFICATIONS COLLECTION**

### **Notification Types:**
- Assignment updates
- Leave request notifications
- General system alerts

---

## 🔍 **DATABASE INSIGHTS**

### **Strengths:**
✅ Well-structured schema with proper relationships  
✅ Comprehensive letter management system  
✅ Multi-role user authentication (employee/admin/super_admin)  
✅ Template-based document generation  
✅ QR code-based attendance tracking  
✅ Flexible notification system  

### **Areas for Improvement:**
⚠️ Many users not linked to Firebase authentication  
⚠️ Some leave requests missing employee_id references  
⚠️ Inconsistent data in some legacy records  

### **Security Features:**
🔒 Password hashing (bcrypt)  
🔒 Role-based access control  
🔒 Firebase UID linkage for enhanced security  
🔒 Timestamp tracking for audit trails  

---

## 📊 **STATISTICS SUMMARY**

| Metric | Count |
|--------|-------|
| Total Collections | 9 |
| Total Users | 22 |
| Pending Letters | 7 |
| Active QR Codes | 5 |
| Leave Requests | 5 |
| Active Assignments | 3 |
| Admin Users | 8 |

---

*This analysis was generated automatically by examining the Firestore database structure and sample data.*