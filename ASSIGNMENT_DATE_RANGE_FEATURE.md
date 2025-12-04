# Assignment Date Range Feature ✅

## Feature Update
Assignment sekarang muncul di **semua tanggal** dari Start Date sampai Due Date di calendar.

## Perubahan

### 1. **Assignment Model** ✅
**File:** `frontend/lib/data/models/assignment.dart`

Tambah field baru:
```dart
final DateTime? startDate; // Tanggal mulai assignment
final DateTime dueDate;    // Tanggal deadline
```

Tambah getter:
```dart
String get formattedStartDate {
  if (startDate == null) return '';
  return '${startDate!.day}/${startDate!.month}/${startDate!.year}';
}
```

### 2. **Calendar Logic** ✅
**File:** `frontend/lib/modules/admin/assignment/widgets/monthly/monthly_assignment_ui.dart`

**BEFORE:**
- Assignment hanya muncul di due date saja
- Calendar merah hanya di tanggal due date

**AFTER:**
- Assignment muncul di **semua tanggal** dari start date sampai due date
- Calendar merah di **semua tanggal** dalam range tersebut

```dart
// Cek jika tanggal ada dalam range assignment
if (assignment.startDate != null) {
  final startDate = DateTime(assignment.startDate!.year, ...);
  final dueDate = DateTime(assignment.dueDate.year, ...);
  
  // Tanggal harus antara startDate dan dueDate (inclusive)
  return (checkDate >= startDate) && (checkDate <= dueDate);
}
```

### 3. **Assignment Card Display** ✅
**File:** `frontend/lib/modules/admin/assignment/widgets/monthly/assignment_card.dart`

Tampilan tanggal berubah:
- **Jika ada startDate:** "1/12/2025 - 5/12/2025"
- **Jika tidak ada startDate:** "5/12/2025" (hanya due date)

## Cara Kerja

### Contoh Assignment:
```
Name: "Liburan"
Start Date: 30/11/2025
Due Date: 30/11/2025
```

**Result:**
- Tanggal **30/11** di calendar berwarna **merah**
- Klik tanggal 30/11 → Assignment "Liburan" muncul di list
- Card menampilkan: "30/11/2025 - 30/11/2025"

### Contoh Assignment Multi-Day:
```
Name: "Project Development"
Start Date: 1/12/2025
Due Date: 15/12/2025
```

**Result:**
- Tanggal **1, 2, 3, 4, 5, ..., 15** di calendar berwarna **merah**
- Klik tanggal manapun dari 1-15 → Assignment muncul
- Card menampilkan: "1/12/2025 - 15/12/2025"

## Testing

### Test Case 1: Assignment Hari Ini
1. Add assignment dengan Start Date = Today, End Date = Today
2. **Expected:** Calendar hari ini merah, assignment muncul

### Test Case 2: Assignment Range
1. Add assignment dengan Start Date = Today, End Date = +7 days
2. **Expected:** 
   - 8 tanggal di calendar berwarna merah
   - Klik tanggal manapun dalam range → Assignment muncul
   - Card tampilkan "DD/MM/YYYY - DD/MM/YYYY"

### Test Case 3: Assignment Tanpa Start Date
1. Assignment lama yang hanya punya due date
2. **Expected:**
   - Hanya due date yang merah di calendar
   - Card hanya tampilkan due date

## Backward Compatibility

✅ **Compatible dengan assignment lama**
- Assignment lama yang tidak punya `startDate` tetap berfungsi
- Hanya tampil di due date seperti sebelumnya

## Files Modified

1. ✅ `frontend/lib/data/models/assignment.dart`
   - Added: `startDate` field
   - Added: `formattedStartDate` getter
   - Updated: `fromJson`, `toJson`, constructor

2. ✅ `frontend/lib/modules/admin/assignment/widgets/monthly/monthly_assignment_ui.dart`
   - Updated: `_hasAssignments()` - Check date range
   - Updated: `_updateSelectedDayAssignments()` - Filter by range

3. ✅ `frontend/lib/modules/admin/assignment/widgets/monthly/assignment_card.dart`
   - Updated: Date display to show range

## Next Steps

Backend sudah support `startDate` field (dikirim dari frontend saat create assignment).
Frontend sekarang:
- ✅ Parse `startDate` dari database
- ✅ Tampilkan assignment di semua tanggal dalam range
- ✅ Display date range di card

**Ready to use!** 🎉

## Hot Reload
Tekan `r` di terminal Flutter untuk reload dan test fitur baru ini.
