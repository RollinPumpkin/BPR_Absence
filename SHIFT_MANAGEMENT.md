# Shift Management System Documentation

## Overview
Sistem manajemen shift untuk mengatur jadwal kerja karyawan Security dan Office Boy yang memiliki pola kerja berbeda dari karyawan regular.

## Fitur Utama

### 1. **Shift Definitions** (Definisi Shift)
- Mengelola jenis-jenis shift yang tersedia
- Setiap shift memiliki:
  - **Name**: Nama shift (e.g., "Shift Pagi", "Shift Malam")
  - **Start Time**: Jam mulai shift (format HH:mm)
  - **End Time**: Jam selesai shift (format HH:mm)
  - **Color**: Warna identifikasi shift
  - **Description**: Deskripsi optional

#### Akses:
- Admin Dashboard → Shift Management → Shift Settings
- URL: `/admin/shifts/definitions`

#### Operasi:
- ✅ **Create**: Tambah shift baru
- ✅ **Edit**: Edit shift yang ada
- ✅ **Delete**: Hapus shift (swipe left pada mobile/web)
  - ⚠️ Tidak bisa hapus shift yang sedang digunakan dalam assignment

### 2. **Shift Roster** (Jadwal Shift Harian)
- Mengatur assignment shift per hari untuk karyawan Security
- Interface kalender untuk memilih tanggal
- Dua section: Morning Shift dan Evening Shift
- Assign/unassign karyawan ke shift tertentu

#### Akses:
- Admin Dashboard → Shift Management → Shift Roster
- URL: `/admin/shifts/roster`

#### Fitur:
- 📅 Date picker dengan navigasi prev/next
- 👥 List karyawan Security yang aktif
- ✅ Assign karyawan ke shift (morning/evening)
- ❌ Unassign karyawan dari shift
- 🔄 Auto-reload setelah assign/unassign

### 3. **Employee Shift Configuration** (Konfigurasi Shift Karyawan)
- Set tipe shift per karyawan saat create/edit employee
- Tiga tipe shift:
  1. **Single Shift**: Jam kerja regular (08:00-17:00)
  2. **Double Shift (Morning/Evening)**: Dua shift bergantian
     - Morning: 06:00-14:00
     - Evening: 18:00-02:00
  3. **Custom Hours**: Jam kerja custom (e.g., Office Boy 06:00-18:00)

#### Auto-configuration berdasarkan Role:
- **Employee/Account Officer**: Single Shift (08:00-17:00)
- **Security**: Double Shift (06:00-14:00 + 18:00-02:00)
- **Office Boy**: Custom Hours (06:00-18:00)

#### Akses:
- Admin → Employees → Edit Employee
- Field "Shift Type" akan auto-fill berdasarkan role

## Backend API

### Base URL: `/api/shifts`

#### 1. Get Shift Assignments
```http
GET /api/shifts/assignments
Query Parameters:
  - startDate: yyyy-MM-dd (required)
  - endDate: yyyy-MM-dd (required)
  - employeeId: string (optional)
  - role: string (optional)
```

#### 2. Create/Update Shift Assignment
```http
POST /api/shifts/assignments
Body:
{
  "date": "2024-01-15",
  "employee_id": "SC001",
  "employee_name": "John Doe",
  "role": "security",
  "shift_type": "morning",
  "shift_start_time": "06:00",
  "shift_end_time": "14:00",
  "notes": "Optional notes"
}
```

#### 3. Bulk Create Assignments
```http
POST /api/shifts/assignments/bulk
Body:
{
  "assignments": [
    { date, employee_id, ... },
    { date, employee_id, ... }
  ]
}
```

#### 4. Delete Assignment
```http
DELETE /api/shifts/assignments/:assignmentId
```

#### 5. Get Shift Definitions
```http
GET /api/shifts/definitions
Returns: Array of shift types
```

#### 6. Create/Update Shift Definition
```http
POST /api/shifts/definitions
Body:
{
  "id": "optional-for-update",
  "name": "Shift Pagi",
  "start_time": "06:00",
  "end_time": "14:00",
  "color": "#FFA500",
  "description": "Optional description"
}
```

#### 7. Delete Shift Definition
```http
DELETE /api/shifts/definitions/:definitionId
Note: Will fail if shift is being used in assignments
```

## Database Collections

### 1. `shift_definitions`
Stores available shift types.

**Schema:**
```javascript
{
  id: string (auto),
  name: string,
  start_time: string (HH:mm),
  end_time: string (HH:mm),
  color: string (#RRGGBB),
  description: string,
  created_at: timestamp,
  created_by: string (userId),
  updated_at: timestamp,
  updated_by: string (userId)
}
```

**Default Shifts:**
- Shift Pagi: 06:00-14:00 (Orange)
- Shift Malam: 18:00-02:00 (Blue)
- Regular: 08:00-17:00 (Green)

### 2. `shift_assignments`
Stores daily shift assignments.

**Schema:**
```javascript
{
  id: string (auto),
  date: string (yyyy-MM-dd),
  employee_id: string,
  employee_name: string,
  role: string,
  shift_type: string (morning/evening/regular),
  shift_start_time: string (HH:mm),
  shift_end_time: string (HH:mm),
  notes: string,
  created_at: timestamp,
  created_by: string (userId),
  updated_at: timestamp,
  updated_by: string (userId)
}
```

**Indexes:**
- `date` + `employee_id` (unique compound)
- `date`
- `employee_id`
- `role`

## Frontend Structure

### Pages
```
frontend/lib/modules/admin/shifts/
├── shift_roster_page.dart          # Daily shift assignment UI
├── shift_definitions_page.dart     # Shift types management UI
└── widgets/
    └── shift_management_menu.dart  # Quick access menu widget
```

### Services
```
frontend/lib/data/services/
└── shift_service.dart              # API service for shift operations
```

### Models
```
frontend/lib/data/models/
├── user.dart                       # Added: shiftType, shift2StartTime, shift2EndTime
└── employee.dart                   # Added: shiftType, shift2StartTime, shift2EndTime
```

## Integration with Attendance System

### Security Role Clock-in Validation
When Security tries to clock in:
1. System checks `shift_assignments` collection for today's date + employee_id
2. If no assignment found → **Error**: "You don't have a shift assigned for today"
3. If assignment exists → Use shift times as work schedule
4. Attendance record stores:
   - `shift_type`: morning/evening
   - `shift_start_time`: from assignment
   - `shift_end_time`: from assignment

### Example Flow:
```
1. Admin assigns SC001 to Morning Shift (06:00-14:00) for 2024-01-15
2. SC001 opens attendance app on 2024-01-15
3. SC001 clicks Clock In at 06:05
4. System validates:
   ✅ Has shift assignment
   ✅ Within shift time window
5. Attendance created with shift info
6. Status calculation:
   - If clock_in > 06:15 → "late"
   - If clock_in ≤ 06:15 → "present"
```

## Seeding Data

### Initialize Shift Definitions
```bash
cd backend
node seed-shift-definitions.js
```

This will create:
- 3 shift definitions (Shift Pagi, Shift Malam, Regular)
- 4 sample assignments (SC001, SC002 for today and tomorrow)

## Testing Checklist

### Shift Definitions
- [ ] Create new shift
- [ ] Edit existing shift
- [ ] Delete unused shift
- [ ] Try delete shift that's in use (should fail)
- [ ] Color picker works
- [ ] Time picker works

### Shift Roster
- [ ] Load security employees from database
- [ ] Assign employee to morning shift
- [ ] Assign employee to evening shift
- [ ] Unassign employee from shift
- [ ] Navigate between dates
- [ ] Assigned employees show correctly

### Employee Configuration
- [ ] Create Security → Auto-set Double Shift
- [ ] Create Office Boy → Auto-set Custom Hours
- [ ] Create Employee → Auto-set Single Shift
- [ ] Edit employee role → Auto-update shift config
- [ ] Work schedule section hides for Double Shift
- [ ] Work schedule shows for Single/Custom

### Attendance Integration
- [ ] Security without assignment → Clock-in blocked
- [ ] Security with morning shift → Can clock in morning
- [ ] Security with evening shift → Can clock in evening
- [ ] Shift info stored in attendance record
- [ ] Status calculated correctly (late vs present)

## Future Enhancements

### Planned Features:
1. **Shift Rotation Pattern**
   - Auto-generate rotation (e.g., 2 days morning, 2 days evening, 1 day off)
   - Template-based assignment

2. **Shift Swap Requests**
   - Employee can request shift swap with colleague
   - Admin approval workflow

3. **Shift Calendar View**
   - Monthly view of all assignments
   - Visual indicators per employee
   - Export to PDF/Excel

4. **Shift Reports**
   - Total hours per employee per month
   - Shift distribution statistics
   - Overtime calculation

5. **Office Boy Shift Management**
   - Similar to Security but with different patterns
   - Support for rotating days off

6. **Notifications**
   - Remind employee of tomorrow's shift
   - Alert when unassigned
   - Notify when shift changed

## Troubleshooting

### Issue: "You don't have a shift assigned"
**Solution**: 
1. Go to Shift Roster
2. Select today's date
3. Assign employee to appropriate shift

### Issue: Shift definition not showing in roster
**Solution**:
1. Go to Shift Definitions
2. Verify shift exists
3. Check start_time and end_time format (HH:mm)
4. Reload page

### Issue: Cannot delete shift definition
**Reason**: Shift is being used in assignments
**Solution**:
1. Go to Shift Roster
2. Find and delete all assignments using this shift
3. Then delete the shift definition

### Issue: Security employees not loading
**Check**:
1. Backend server running?
2. User Service API working?
3. Are there users with role='security' in database?
4. Check browser console for errors

## Support

For issues or questions, contact:
- Backend: Check `backend/routes/shifts.js`
- Frontend: Check `frontend/lib/modules/admin/shifts/`
- Documentation: This file

---

**Last Updated**: January 2025  
**Version**: 1.0.0
