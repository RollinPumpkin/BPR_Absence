# User Attendance Form Navigation - Updated Flow

## Flow yang Sudah Diubah:

### **Navigation Flow Baru**
```
Dashboard (UserHeader) → Click Clock In/Out Button → UserAttendanceFormPage
```

### **Perubahan yang Dibuat**:

1. **Import Update**: Mengubah dari `figma_clock_card.dart` ke `user_attendance_form_page.dart`
2. **Navigation Method**: `_navigateToClockCard` → `_navigateToAttendanceForm`
3. **Target Page**: `FigmaClockCard` → `UserAttendanceFormPage`

### **Button Behavior**:

#### **Clock In Button**:
- **Active**: Ketika user belum clock in → Navigate ke `UserAttendanceFormPage`
- **Disabled**: Ketika user sudah clock in → Button abu-abu "Clocked In"

#### **Clock Out Button**:
- **Active**: Ketika user sudah clock in tapi belum clock out → Navigate ke `UserAttendanceFormPage`
- **Disabled**: Ketika belum clock in atau sudah clock out → Button abu-abu

### **Expected User Journey**:

1. **User di Dashboard**: Melihat Clock In/Out display dengan `--:--:--` atau waktu tersimpan
2. **Click "In" Button**: Navigate ke `UserAttendanceFormPage` 
3. **UserAttendanceFormPage**: User mengisi form attendance (lokasi, catatan, dll)
4. **Submit Form**: Data attendance tersimpan
5. **Back to Dashboard**: Auto-reload data attendance dan clock time updates

### **Integration Points**:

- **UserHeader**: Menampilkan clock time dari SharedPreferences
- **UserAttendanceFormPage**: Form untuk input attendance data lengkap
- **Data Storage**: Per-user storage dengan format `clock_in_{userId}_{date}`
- **Auto Reload**: Dashboard refresh data setelah kembali dari form

### **Benefits of This Flow**:

1. **Comprehensive Data**: User mengisi attendance form lengkap (bukan hanya clock time)
2. **Location Tracking**: Form bisa include lokasi attendance
3. **Notes/Remarks**: User bisa tambah catatan atau keterangan
4. **Consistent UI**: Menggunakan existing UserAttendanceFormPage yang sudah ada
5. **Better UX**: Single form untuk semua attendance data

## Testing Steps:

### **Test Clock In Flow**:
1. Login user baru
2. Dashboard menampilkan Clock In `--:--:--`
3. Klik "In" button → Navigate ke UserAttendanceFormPage
4. Isi form attendance dan submit
5. Kembali ke dashboard → Clock In menampilkan waktu

### **Test Clock Out Flow**:
1. Setelah clock in
2. Klik "Out" button → Navigate ke UserAttendanceFormPage  
3. Isi form clock out dan submit
4. Kembali ke dashboard → Clock Out menampilkan waktu

### **Test Button States**:
1. Fresh user: "In" active, "Out" disabled
2. After clock in: "In" disabled ("Clocked In"), "Out" active
3. After clock out: Both disabled ("Clocked In", "Clocked Out")

## Expected Results:
- ✅ Clock In/Out buttons navigate ke UserAttendanceFormPage
- ✅ Comprehensive attendance form instead of simple clock
- ✅ Consistent per-user data storage
- ✅ Auto-reload dashboard setelah form submission
- ✅ Proper button states based on clock status