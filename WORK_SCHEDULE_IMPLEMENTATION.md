# Work Schedule Implementation - Complete ✅

## Overview
Work schedule sekarang bisa diedit oleh admin langsung di **Information Profile** dari setiap employee di Employee Database page. Tidak ada collection terpisah, semua data tersimpan di user document masing-masing.

## Implementation Details

### 1. Backend Changes

#### New API Endpoint
```
PUT /api/admin/users/:id
```
- Update user profile termasuk work schedule
- Admin only access (middleware: auth + adminAuth)
- Fields yang bisa diupdate:
  - `work_start_time`: String format HH:mm (e.g., "08:00")
  - `work_end_time`: String format HH:mm (e.g., "17:00")
  - `late_threshold_minutes`: Integer (e.g., 15)

**File:** `backend/routes/admin.js`

#### Updated Attendance Logic
```
POST /api/attendance/submit
```
- Sekarang mengambil work schedule dari user document
- Automatic late detection berdasarkan:
  - `work_start_time` dari user
  - `late_threshold_minutes` dari user
- Status otomatis:
  - `present`: Clock in sebelum atau tepat di threshold
  - `late`: Clock in setelah threshold

**File:** `backend/routes/attendance.js`

### 2. Frontend Changes

#### Employee Model Update
**File:** `frontend/lib/modules/admin/employee/models/employee.dart`

Tambah 3 fields baru:
```dart
final String? workStartTime;      // "08:00"
final String? workEndTime;        // "17:00"
final int? lateThresholdMinutes;  // 15
```

#### Edit Page Enhancement
**File:** `frontend/lib/modules/admin/employee/pages/edit_page.dart`

Tambah section **Work Schedule** dengan:
- **Work Start Time**: Time picker untuk pilih jam mulai kerja
- **Work End Time**: Time picker untuk pilih jam selesai kerja
- **Late Threshold (Minutes)**: Input angka untuk toleransi keterlambatan

### 3. Database Structure

#### Firestore Collection: `users`
Setiap user document sekarang memiliki field tambahan:

```json
{
  "full_name": "Employee User",
  "email": "employee@bpr.com",
  "role": "employee",
  // ... existing fields ...
  
  "work_start_time": "08:00",          // ← New
  "work_end_time": "17:00",            // ← New
  "late_threshold_minutes": 15         // ← New
}
```

## How to Use

### Admin: Set Work Schedule

1. **Buka Employee Database page**
   ```
   http://localhost:8080/#/admin/employees
   ```

2. **Klik card employee** yang ingin diedit

3. **Klik tombol Edit** (icon pensil)

4. **Scroll ke section "Work Schedule"**

5. **Set jadwal kerja:**
   - Work Start Time: Klik dan pilih jam mulai kerja (default: 08:00)
   - Work End Time: Klik dan pilih jam selesai kerja (default: 17:00)
   - Late Threshold: Input toleransi dalam menit (default: 15)

6. **Klik Save**

### Employee: Clock In with Auto Late Detection

1. **Buka aplikasi dan login**

2. **Submit attendance** seperti biasa

3. **System otomatis detect:**
   - Jika clock in <= (work_start_time + late_threshold_minutes):
     - Status: `present` ✅
   
   - Jika clock in > (work_start_time + late_threshold_minutes):
     - Status: `late` ⏰

## Example Scenario

### User: John Doe
```
Work Start Time: 08:00
Late Threshold: 15 minutes
```

**Tolerance Window: 08:00 - 08:15**

| Clock In Time | Status | Reason |
|--------------|--------|--------|
| 07:50 | ✅ present | Sebelum jam mulai |
| 08:00 | ✅ present | Tepat jam mulai |
| 08:10 | ✅ present | Masih dalam threshold (15 menit) |
| 08:15 | ✅ present | Tepat di batas threshold |
| 08:16 | ⏰ late | Melewati threshold |
| 08:30 | ⏰ late | Terlambat 30 menit |

## Testing Guide

### 1. Test Update Work Schedule

```bash
# Test update user work schedule
curl -X PUT http://localhost:3000/api/admin/users/USER_ID \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "work_start_time": "09:00",
    "work_end_time": "18:00",
    "late_threshold_minutes": 30
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "User updated successfully"
}

```

### 2. Test Late Detection

**Setup:**
- Set work_start_time: "08:00"
- Set late_threshold_minutes: 15

**Test Case 1: On Time (07:55)**
```bash
curl -X POST http://localhost:3000/api/attendance/submit \
  -H "Authorization: Bearer EMPLOYEE_TOKEN" \
  -F "type=attendance" \
  -F "startDate=2025-11-27" \
  -F "endDate=2025-11-27" \
  -F "latitude=-6.200000" \
  -F "longitude=106.816666" \
  -F "address=Office" \
  -F "image=@photo.jpg"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "status": "present",
    "is_late": false
  }
}
```

**Test Case 2: Late (08:20)**
```json
{
  "success": true,
  "data": {
    "status": "late",
    "is_late": true
  }
}
```

### 3. Test Frontend UI

1. **Start backend:**
   ```bash
   cd backend
   npm start
   ```

2. **Start frontend:**
   ```bash
   cd frontend
   flutter run -d chrome --web-port=8080
   ```

3. **Login as admin:**
   ```
   Email: admin@bpr.com
   Password: admin123
   ```

4. **Navigate:**
   - Admin Dashboard → Employee Database
   - Click any employee card
   - Click Edit button
   - Scroll to "Work Schedule" section
   - Edit work start time, end time, and threshold
   - Click Save

5. **Verify:**
   - Check Firestore console
   - Verify user document updated with new values

## Files Modified

### Backend
- ✅ `backend/routes/admin.js` - Added PUT /api/admin/users/:id endpoint
- ✅ `backend/routes/attendance.js` - Updated late detection logic

### Frontend
- ✅ `frontend/lib/data/models/user.dart` - Added 3 work schedule fields + fromJson/toJson
- ✅ `frontend/lib/modules/admin/employee/models/employee.dart` - Added 3 new fields
- ✅ `frontend/lib/modules/admin/employee/pages/edit_page.dart` - Added Work Schedule section with time pickers
- ✅ `frontend/lib/modules/admin/employee/pages/details_page.dart` - Display work schedule info
- ✅ `frontend/lib/modules/admin/employee/widgets/employee_card.dart` - Map work schedule from User to Employee

## Features

✅ **Individual Work Schedules** - Setiap employee punya jadwal sendiri
✅ **No New Collection** - Data tersimpan di user document (simple & clean)
✅ **Admin-Friendly UI** - Time picker yang mudah digunakan
✅ **Automatic Late Detection** - System otomatis deteksi keterlambatan
✅ **Flexible Threshold** - Admin bisa set toleransi per employee
✅ **No Breaking Changes** - Tidak merusak code existing

## Default Values

Jika employee belum di-set work schedule:
- work_start_time: `"08:00"`
- work_end_time: `"17:00"`
- late_threshold_minutes: `15`

## Notes

- Work schedule hanya untuk detection, bukan enforcement
- Status `late` vs `present` hanya untuk reporting
- Admin bisa set schedule berbeda per employee (fleksibel untuk shift, security, dll)
- Field `work_end_time` belum digunakan untuk logic, tapi tersedia untuk future features (overtime detection, etc)

## Implementation Status

🟢 **COMPLETE** - Ready to use!

All features tested and working without errors.
