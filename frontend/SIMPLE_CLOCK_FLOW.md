# FigmaClockCard - Simple Direct Flow

## Flow yang Sudah Diperbaiki:

### **1. Navigation Flow**
```
Dashboard (UserHeader) → Click Clock In/Out Button → FigmaClockCard (Full Screen)
```

### **2. FigmaClockCard Features**
- **AppBar**: Dengan tombol back dan title "Clock In/Out"
- **Simple Layout**: Container dengan clock display dan buttons
- **Per-User Storage**: Menggunakan `clock_in_{userId}_{date}` format
- **Auto Reload**: UserHeader reload data saat kembali dari FigmaClockCard

### **3. Display Logic**
- **Before Clock In**: Clock In `--:--:--`, Clock Out `--:--:--`
- **After Clock In**: Clock In `09:15:30`, Clock Out `--:--:--`  
- **After Clock Out**: Clock In `09:15:30`, Clock Out `17:30:45`

### **4. Button States**
- **Clock In Button**: 
  - Active: "In" (hijau) - jika belum clock in
  - Disabled: "Clocked In" (abu-abu) - jika sudah clock in
  
- **Clock Out Button**:
  - Active: "Out" (merah) - jika sudah clock in tapi belum clock out
  - Disabled: "Clocked Out" (abu-abu) - jika sudah clock out

### **5. User Experience**
1. User di dashboard klik "In" button → Navigate ke FigmaClockCard
2. FigmaClockCard menampilkan current state (--:--:-- atau waktu tersimpan)
3. User klik button yang sesuai untuk save waktu
4. SnackBar konfirmasi muncul
5. User klik back arrow → Kembali ke dashboard
6. Dashboard auto-reload dan menampilkan waktu yang baru disave

### **6. Storage System**
- **Key Format**: `clock_in_{userId}_{date}` dan `clock_out_{userId}_{date}`
- **Per User**: Setiap user memiliki data terpisah
- **Per Day**: Data di-reset setiap hari di midnight

## Testing Flow:

### **Test 1: Fresh User**
1. Login user baru
2. Dashboard: Clock In `--:--:--`, Clock Out `--:--:--`
3. Klik "In" → FigmaClockCard: Clock In `--:--:--`, Clock Out `--:--:--`
4. Klik "In" button → Clock In saved dengan waktu saat ini
5. Back to dashboard → Clock In menampilkan waktu tersimpan

### **Test 2: Clock Out Flow**
1. Setelah clock in
2. Klik "Out" → FigmaClockCard: Clock In `09:15:30`, Clock Out `--:--:--`
3. Klik "Out" button → Clock Out saved
4. Back to dashboard → Both times tersimpan

### **Test 3: Multi User**
1. User A clock in
2. Logout, login User B
3. User B klik clock button → Melihat `--:--:--` (tidak terpengaruh User A)

## Expected Results:
- ✅ Simpel direct flow tanpa callback complexity
- ✅ Full screen FigmaClockCard dengan AppBar
- ✅ Per-user storage yang konsisten
- ✅ Auto reload data saat kembali ke dashboard
- ✅ Clear button states dan feedback