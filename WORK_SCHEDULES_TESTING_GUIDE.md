# 📅 Work Schedule Management - Testing Guide

## ✅ Fitur yang Telah Diimplementasikan

### 1. **Database (Firestore)**
- ✅ Collection `work_schedules` dengan 6 roles:
  - Employee (08:00-17:00, toleransi 15 menit)
  - Admin (08:00-17:00, toleransi 15 menit)
  - Super Admin (08:00-17:00, toleransi 15 menit)
  - Security (3 shift: Pagi 06:00-14:00, Siang 14:00-22:00, Malam 22:00-06:00, toleransi 10 menit)
  - Office Boy (07:00-16:00, toleransi 10 menit)
  - Account Officer (08:30-17:30, toleransi 15 menit)

### 2. **Backend API Endpoints**
- ✅ `GET /api/work-schedules` - Get all schedules (Admin only)
- ✅ `GET /api/work-schedules/:role` - Get schedule by role
- ✅ `PUT /api/work-schedules/:role` - Update schedule (Admin only)
- ✅ `POST /api/work-schedules` - Create new schedule (Admin only)
- ✅ `DELETE /api/work-schedules/:role` - Delete schedule (Admin only)
- ✅ `POST /api/attendance/clock-in` - Clock in with auto late detection
- ✅ `POST /api/attendance/clock-out` - Clock out

### 3. **Frontend (Admin Panel)**
- ✅ Work Schedules Management Page
- ✅ Edit Schedule Dialog
- ✅ Support untuk Regular dan Shift mode
- ✅ Navigation menu updated
- ✅ Routes configured

---

## 🚀 Cara Testing

### **Step 1: Start Backend Server**

```bash
cd c:\laragon\www\BPR_Absence\backend
npm start
```

Pastikan server berjalan di `http://localhost:3000`

---

### **Step 2: Verifikasi Database**

Jalankan script untuk cek data work schedules:

```bash
cd c:\laragon\www\BPR_Absence\backend
node -e "const admin = require('firebase-admin'); const path = require('path'); const serviceAccountPath = path.join(__dirname, 'bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json'); const serviceAccount = require(serviceAccountPath); admin.initializeApp({ credential: admin.credential.cert(serviceAccount) }); const db = admin.firestore(); db.collection('work_schedules').get().then(snap => { console.log('Found', snap.size, 'schedules'); snap.forEach(doc => console.log('-', doc.id)); process.exit(0); });"
```

Output yang diharapkan:
```
Found 6 schedules
- employee
- admin
- super_admin
- security
- office_boy
- account_officer
```

---

### **Step 3: Test Backend API (Via Postman/cURL)**

#### A. Login dulu untuk dapat token:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin@bpr.com\",\"password\":\"password123\"}"
```

Copy `token` dari response.

#### B. Test GET All Schedules:

```bash
curl -X GET http://localhost:3000/api/work-schedules \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### C. Test GET Schedule by Role:

```bash
curl -X GET http://localhost:3000/api/work-schedules/employee \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### D. Test UPDATE Schedule:

```bash
curl -X PUT http://localhost:3000/api/work-schedules/employee \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d "{\"work_start_time\":\"08:30:00\",\"late_threshold_minutes\":20}"
```

---

### **Step 4: Start Frontend**

```bash
cd c:\laragon\www\BPR_Absence\frontend
flutter run -d chrome --web-port=8080
```

Atau jika sudah ada yang running, cukup refresh browser.

---

### **Step 5: Login ke Admin Panel**

1. Buka browser: `http://localhost:8080`
2. Login dengan:
   - **Email**: `admin@bpr.com`
   - **Password**: `password123`
3. Klik menu **Schedule** (icon jam) di bottom navigation

---

### **Step 6: Test Work Schedules Page**

#### Yang Harus Terlihat:

1. **List of All Roles** dengan card masing-masing:
   - Employee (Karyawan)
   - Admin
   - Super Admin
   - Security (dengan 3 shifts)
   - Office Boy
   - Account Officer

2. **Informasi di setiap card**:
   - Icon role
   - Nama role (display name)
   - Jam masuk/pulang (untuk regular mode)
   - List shifts (untuk shift mode)
   - Toleransi keterlambatan
   - Hari kerja

3. **Tombol Edit** di setiap card

---

### **Step 7: Test Edit Schedule Dialog**

1. **Klik tombol Edit** pada salah satu card (misalnya Employee)
2. Dialog akan muncul dengan form:
   - Display Name (editable)
   - Mode (Regular/Shift) - radio button
   - Jam Masuk & Pulang (untuk regular mode)
   - Toleransi (editable, dalam menit)
   - Hari Kerja (checkboxes)

3. **Ubah beberapa nilai**, misalnya:
   - Jam Masuk: dari 08:00:00 ke 08:30:00
   - Toleransi: dari 15 ke 20 menit
   - Uncheck Saturday

4. **Klik "Save Changes"**
5. Should show success message
6. Dialog close
7. List refresh dengan data baru

---

### **Step 8: Test Shift Mode (Security)**

1. **Klik Edit** pada card Security
2. Dialog akan show:
   - Mode sudah terpilih: "Shift"
   - List 3 shifts dengan detail masing-masing

3. **Test Add Shift**:
   - Klik tombol "Add Shift"
   - Shift baru muncul dengan default values
   - Edit nama dan waktu shift
   - Save

4. **Test Remove Shift**:
   - Klik icon delete pada salah satu shift
   - Shift terhapus

5. **Save** dan verify

---

### **Step 9: Test Attendance dengan Schedule Baru**

Sekarang test apakah attendance system menggunakan schedule yang baru:

1. **Logout** dari admin
2. **Login** sebagai employee:
   - Email: `employee@bpr.com`
   - Password: `password123`

3. **Clock In** (pastikan waktu sekarang > 08:30 + 20 menit jika tadi diubah)
4. Check status di attendance list
5. **Expected**: Status "Late" jika waktu > threshold, "Present" jika < threshold

---

## 🧪 Test Scenarios

### Scenario 1: Regular Mode - Employee Late Detection

**Setup**:
- Employee schedule: 08:00 start, 15 min threshold (late after 08:15)

**Test**:
1. Clock in at 08:10 → Status: **Present** ✅
2. Clock in at 08:16 → Status: **Late** 🔴
3. Clock in at 09:00 → Status: **Late** 🔴

### Scenario 2: Update Employee Schedule

**Setup**:
- Change start time to 08:30
- Change threshold to 20 minutes

**Test**:
1. Clock in at 08:45 → Status: **Present** ✅ (within 08:30 + 20 min)
2. Clock in at 08:51 → Status: **Late** 🔴 (after 08:50)

### Scenario 3: Shift Mode - Security

**Setup**:
- Security has 3 shifts
- Currently using earliest shift (06:00)

**Test**:
1. Clock in at 06:05 → Status: **Present** ✅
2. Clock in at 06:15 → Status: **Late** 🔴

### Scenario 4: Work Days

**Setup**:
- Employee works Monday-Friday only

**Test**:
1. Try clock in on Saturday
2. (Future feature: Should show warning or different status)

---

## 📸 Expected Screenshots

### 1. Work Schedules List Page
![Expected: Grid of cards, each showing role info](screenshot-placeholder)

### 2. Edit Dialog - Regular Mode
![Expected: Form with time fields, threshold, days checkboxes](screenshot-placeholder)

### 3. Edit Dialog - Shift Mode
![Expected: List of shifts with add/remove buttons](screenshot-placeholder)

### 4. Success Message
![Expected: Green snackbar "Schedule updated successfully"](screenshot-placeholder)

---

## 🐛 Troubleshooting

### Issue 1: "Failed to load schedules"
**Solution**: 
- Check backend is running
- Check Firebase credentials
- Check token is valid

### Issue 2: "Access denied"
**Solution**:
- Make sure logged in as Admin or Super Admin
- Regular employees can't access work schedules page

### Issue 3: Dialog doesn't open
**Solution**:
- Check browser console for errors
- Verify edit_schedule_dialog.dart is imported correctly

### Issue 4: Save doesn't work
**Solution**:
- Check network tab for API errors
- Verify token in request headers
- Check backend logs

---

## 📝 Quick Commands

### Restart Backend
```bash
cd c:\laragon\www\BPR_Absence\backend
npm start
```

### Restart Frontend
```bash
cd c:\laragon\www\BPR_Absence\frontend
flutter run -d chrome --web-port=8080
```

### Re-seed Schedules
```bash
cd c:\laragon\www\BPR_Absence\backend
node seed-work-schedules.js
```

### Check Backend Logs
```bash
# In backend terminal, watch for:
⏰ Work Start: 08:00:00, Late Threshold: 08:15:00, Current: 08:20:00
🔴 Status: LATE (checked in after 08:15:00)
```

---

## ✅ Checklist Testing

- [ ] Backend server running
- [ ] Database seeded with 6 roles
- [ ] Can access /admin/work-schedules page
- [ ] See all 6 role cards
- [ ] Can click Edit button
- [ ] Dialog opens with correct data
- [ ] Can edit regular mode (Employee)
- [ ] Can edit shift mode (Security)
- [ ] Can add new shift
- [ ] Can remove shift
- [ ] Save button works
- [ ] Success message shows
- [ ] List refreshes after save
- [ ] Attendance clock-in uses new schedule
- [ ] Late detection works correctly

---

## 🎯 Success Criteria

✅ **Feature Complete** when:
1. Admin can view all work schedules
2. Admin can edit any schedule via UI
3. Changes save to Firestore
4. Attendance system uses updated schedules
5. Late detection works per role
6. Shift mode fully functional
7. No console errors
8. Responsive UI
9. Loading states work
10. Error handling works

---

## 📞 Need Help?

If you encounter issues:

1. Check backend console for errors
2. Check browser console for frontend errors
3. Verify Firestore has work_schedules collection
4. Test API endpoints directly with Postman
5. Check that imports are correct
6. Make sure you're logged in as admin

---

**Happy Testing! 🚀**
