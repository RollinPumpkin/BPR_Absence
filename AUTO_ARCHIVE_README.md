# Auto-Archive System Documentation

## Overview
Sistem auto-archive otomatis menghapus data lama (>30 hari) dari Firestore dan menyimpannya ke dalam file Excel yang dikompres dalam ZIP.

## 🎯 Features

### 1. **Auto-Archive Schedule**
- Berjalan otomatis setiap hari jam 00:00 (midnight)
- Mengarsip data yang lebih lama dari 30 hari
- Tidak mengarsip data users

### 2. **Soft Delete**
- Data ditandai dengan flag `is_deleted: true`
- Data tetap ada di database (bisa di-restore)
- Tidak menghapus permanen

### 3. **Export ke Excel**
- Satu file Excel per collection:
  - `attendance_archive_YYYYMMDD.xlsx`
  - `assignments_archive_YYYYMMDD.xlsx`
  - `letters_archive_YYYYMMDD.xlsx`
- Semua field di-export ke kolom Excel
- Timestamp dikonversi ke format readable

### 4. **ZIP Compression**
- Semua Excel files dikompres jadi 1 ZIP
- Include file `metadata.json` dengan info:
  - Tanggal archive
  - Jumlah files
  - List files
- Auto-download ke browser

### 5. **Manual Trigger**
- Admin bisa trigger archive manual dari UI
- Route: `/admin/archive`
- Menampilkan statistics:
  - Pending archive count
  - Already deleted count

## 🚀 Usage

### Automatic Mode
```dart
// Di main.dart - sudah di-setup
final archiveService = DataArchiveService();
archiveService.startAutoArchive();
```

### Manual Trigger (Admin UI)
1. Navigate ke `/admin/archive`
2. Lihat statistics
3. Klik "Run Archive Now"
4. ZIP file akan auto-download

### Programmatic Usage
```dart
import 'package:frontend/core/services/data_archive_service.dart';

final service = DataArchiveService();

// Get statistics
final stats = await service.getArchiveStatistics();
print(stats);
// Output:
// {
//   'attendance': {'pending_archive': 150, 'already_deleted': 20},
//   'assignments': {'pending_archive': 80, 'already_deleted': 15},
//   'letters': {'pending_archive': 120, 'already_deleted': 30}
// }

// Manual archive
bool success = await service.performManualArchive();

// Restore archived data
await service.restoreArchivedData('attendance', ['doc1', 'doc2']);

// Permanent delete (older than 6 months)
await service.permanentlyDeleteArchivedData(
  'attendance', 
  Duration(days: 180)
);
```

## 📊 Collections Archived

| Collection | Description | Excluded Fields |
|------------|-------------|-----------------|
| `attendance` | Clock in/out records | None |
| `assignments` | Task assignments | None |
| `letters` | Leave/permit letters | None |
| `users` | **NOT ARCHIVED** | All excluded |

## 🔧 Configuration

### Change Archive Period
```dart
// In data_archive_service.dart
final cutoffDate = DateTime.now().subtract(
  const Duration(days: 30)  // Change this value
);
```

### Change Schedule Time
```dart
// In startAutoArchive()
Timer.periodic(const Duration(days: 1), (_) {
  _performArchive(); // Runs every 24 hours
});
```

### Add/Remove Collections
```dart
final List<String> _collectionsToArchive = [
  'attendance',
  'assignments',
  'letters',
  // Add more here
];
```

## 📁 Output Format

### ZIP Structure
```
data_archive_20251202_143022.zip
├── metadata.json
├── attendance_archive_20251202.xlsx
├── assignments_archive_20251202.xlsx
└── letters_archive_20251202.xlsx
```

### Metadata JSON
```json
{
  "archived_at": "2025-12-02T14:30:22.123Z",
  "total_files": 3,
  "files": [
    "attendance_archive_20251202.xlsx",
    "assignments_archive_20251202.xlsx",
    "letters_archive_20251202.xlsx"
  ],
  "description": "Auto-archived data older than 30 days"
}
```

### Excel Format
| id | employee_id | date | check_in_time | ... | archived_at |
|----|-------------|------|---------------|-----|-------------|
| abc123 | EMP001 | 2025-10-15 | 08:30:00 | ... | 2025-12-02 14:30:22 |

## ⚠️ Important Notes

1. **Storage**: ZIP files auto-download ke browser, pastikan ada storage space
2. **Backup**: Simpan ZIP files di lokasi aman (external drive/cloud)
3. **Firestore**: Soft-deleted data masih kena quota, pertimbangkan hard delete setelah 6-12 bulan
4. **Users**: Data users TIDAK PERNAH di-archive atau dihapus
5. **Performance**: Archive process bisa memakan waktu untuk data besar (>10k records)

## 🛠️ Maintenance

### View Archived Data
Data yang sudah di-archive masih bisa dilihat dengan query:
```dart
await firestore
  .collection('attendance')
  .where('is_deleted', isEqualTo: true)
  .get();
```

### Restore Data
```dart
await service.restoreArchivedData('attendance', ['docId1', 'docId2']);
```

### Hard Delete (Permanent)
Hapus permanen data yang sudah di-soft-delete >180 hari:
```dart
await service.permanentlyDeleteArchivedData(
  'attendance',
  Duration(days: 180)
);
```

## 🔐 Security

- **Admin Only**: Hanya admin yang bisa akses archive page
- **Audit Trail**: Setiap archive tercatat dengan timestamp
- **No User Data**: Users collection tidak pernah ter-archive

## 📝 Logs

Console output saat archive berjalan:
```
📦 ========== STARTING DATA ARCHIVE ==========
🕐 Time: 2025-12-02 00:00:00
📅 Archiving data older than: 2025-11-02

📂 Processing collection: attendance
  ⏳ Processed 500 records...
  ⏳ Processed 1000 records...
✅ Archived 1250 records from attendance

📂 Processing collection: assignments
✅ Archived 450 records from assignments

📂 Processing collection: letters
✅ Archived 680 records from letters

✅ ========== ARCHIVE COMPLETED ==========
📊 Total collections archived: 3
📁 ZIP file created and downloaded
```

## 🐛 Troubleshooting

### Archive tidak jalan otomatis
- Cek console logs saat app start
- Pastikan Firebase initialized
- Cek timer: `_archiveTimer?.isActive`

### Excel file kosong
- Cek apakah ada data >30 hari
- Cek `created_at` field di documents
- Verify dengan `getArchiveStatistics()`

### ZIP tidak download
- Web only feature - tidak work di mobile
- Cek browser pop-up blocker
- Cek browser download settings

## 📞 Support

Untuk pertanyaan atau issues, check:
- Console logs untuk error details
- Archive statistics di admin panel
- Firestore console untuk verify data state
