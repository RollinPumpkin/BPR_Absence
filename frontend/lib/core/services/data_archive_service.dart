import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;

/// Auto Archive Service
/// Automatically archives data older than 1 month to Excel files in ZIP
/// Soft deletes from Firestore but preserves in Excel format
class DataArchiveService {
  static final DataArchiveService _instance = DataArchiveService._internal();
  factory DataArchiveService() => _instance;
  DataArchiveService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _archiveTimer;

  // Collections to archive (users excluded)
  final List<String> _collectionsToArchive = [
    'attendance',
    'assignments',
    'letters',
  ];

  /// Start automatic archiving schedule (runs daily at midnight)
  void startAutoArchive() {
    // Calculate time until next midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    // Schedule first run at midnight
    Timer(timeUntilMidnight, () {
      _performArchive();
      // Then schedule daily runs
      _archiveTimer = Timer.periodic(const Duration(days: 1), (_) {
        _performArchive();
      });
    });

    print('📦 Auto-archive scheduled (runs daily at midnight)');
  }

  /// Stop automatic archiving
  void stopAutoArchive() {
    _archiveTimer?.cancel();
    _archiveTimer = null;
    print('📦 Auto-archive stopped');
  }

  /// Manually trigger archive process
  Future<bool> performManualArchive() async {
    try {
      await _performArchive();
      return true;
    } catch (e) {
      print('❌ Manual archive failed: $e');
      return false;
    }
  }

  /// Main archive process
  Future<void> _performArchive() async {
    print('\n📦 ========== STARTING DATA ARCHIVE ==========');
    print('🕐 Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);
      
      print('📅 Archiving data older than: ${DateFormat('yyyy-MM-dd').format(cutoffDate)}');
      
      // Archive each collection
      final Map<String, List<Map<String, dynamic>>> archivedData = {};
      
      for (final collection in _collectionsToArchive) {
        print('\n📂 Processing collection: $collection');
        final data = await _archiveCollection(collection, cutoffTimestamp);
        if (data.isNotEmpty) {
          archivedData[collection] = data;
          print('✅ Archived ${data.length} records from $collection');
        } else {
          print('ℹ️ No old records found in $collection');
        }
      }

      if (archivedData.isEmpty) {
        print('\nℹ️ No data to archive. All data is recent.');
        return;
      }

      // Create Excel files for each collection
      final Map<String, Uint8List> excelFiles = {};
      for (final entry in archivedData.entries) {
        final excelBytes = _createExcelFile(entry.key, entry.value);
        excelFiles['${entry.key}_archive_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx'] = excelBytes;
      }

      // Create ZIP file
      final zipBytes = _createZipFile(excelFiles);

      // Download ZIP file
      _downloadZipFile(zipBytes, 'data_archive_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.zip');

      print('\n✅ ========== ARCHIVE COMPLETED ==========');
      print('📊 Total collections archived: ${archivedData.length}');
      print('📁 ZIP file created and downloaded');
      
    } catch (e, stackTrace) {
      print('❌ Archive process failed: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Archive a specific collection
  Future<List<Map<String, dynamic>>> _archiveCollection(
    String collectionName,
    Timestamp cutoffTimestamp,
  ) async {
    try {
      // Query old records
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('created_at', isLessThan: cutoffTimestamp)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final archivedRecords = <Map<String, dynamic>>[];

      // Batch delete for efficiency
      final batch = _firestore.batch();
      int batchCount = 0;
      const batchLimit = 500; // Firestore batch limit

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['archived_at'] = Timestamp.now();
        archivedRecords.add(data);

        // Soft delete: mark as deleted instead of actual deletion
        batch.update(doc.reference, {
          'is_deleted': true,
          'deleted_at': Timestamp.now(),
        });

        batchCount++;

        // Commit batch if limit reached
        if (batchCount >= batchLimit) {
          await batch.commit();
          batchCount = 0;
          print('  ⏳ Processed ${archivedRecords.length} records...');
        }
      }

      // Commit remaining
      if (batchCount > 0) {
        await batch.commit();
      }

      return archivedRecords;
    } catch (e) {
      print('❌ Error archiving $collectionName: $e');
      return [];
    }
  }

  /// Create Excel file from data
  Uint8List _createExcelFile(String collectionName, List<Map<String, dynamic>> data) {
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];

    if (data.isEmpty) {
      return Uint8List(0);
    }

    // Get all unique keys for headers
    final Set<String> allKeys = {};
    for (final record in data) {
      allKeys.addAll(record.keys);
    }
    final headers = allKeys.toList()..sort();

    // Write headers
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = headers[i] as CellValue;
    }

    // Write data rows
    for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
      final record = data[rowIndex];
      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        final key = headers[colIndex];
        final value = record[key];
        
        // Convert value to string representation
        String cellValue;
        if (value is Timestamp) {
          cellValue = DateFormat('yyyy-MM-dd HH:mm:ss').format(value.toDate());
        } else if (value is List) {
          cellValue = value.join(', ');
        } else if (value is Map) {
          cellValue = jsonEncode(value);
        } else {
          cellValue = value?.toString() ?? '';
        }

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex + 1))
            .value = cellValue as CellValue;
      }
    }

    // Generate Excel bytes
    final excelBytes = excel.encode();
    return Uint8List.fromList(excelBytes!);
  }

  /// Create ZIP file containing multiple Excel files
  Uint8List _createZipFile(Map<String, Uint8List> files) {
    final archive = Archive();

    // Add metadata file
    final metadata = {
      'archived_at': DateTime.now().toIso8601String(),
      'total_files': files.length,
      'files': files.keys.toList(),
      'description': 'Auto-archived data older than 30 days',
    };
    final metadataJson = jsonEncode(metadata);
    archive.addFile(ArchiveFile(
      'metadata.json',
      metadataJson.length,
      metadataJson.codeUnits,
    ));

    // Add each Excel file
    for (final entry in files.entries) {
      archive.addFile(ArchiveFile(
        entry.key,
        entry.value.length,
        entry.value,
      ));
    }

    // Compress to ZIP
    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);
    return Uint8List.fromList(zipBytes!);
  }

  /// Download ZIP file (web platform)
  void _downloadZipFile(Uint8List zipBytes, String filename) {
    try {
      final blob = html.Blob([zipBytes], 'application/zip');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
      
      print('📥 ZIP file downloaded: $filename');
    } catch (e) {
      print('❌ Error downloading file: $e');
    }
  }

  /// Get archive statistics
  Future<Map<String, dynamic>> getArchiveStatistics() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      final stats = <String, dynamic>{};

      for (final collection in _collectionsToArchive) {
        // Count old records
        final oldRecords = await _firestore
            .collection(collection)
            .where('created_at', isLessThan: cutoffTimestamp)
            .where('is_deleted', isEqualTo: false)
            .get();

        // Count deleted records
        final deletedRecords = await _firestore
            .collection(collection)
            .where('is_deleted', isEqualTo: true)
            .get();

        stats[collection] = {
          'pending_archive': oldRecords.size,
          'already_deleted': deletedRecords.size,
        };
      }

      return stats;
    } catch (e) {
      print('❌ Error getting archive statistics: $e');
      return {};
    }
  }

  /// Restore archived data (if needed)
  Future<bool> restoreArchivedData(String collectionName, List<String> documentIds) async {
    try {
      final batch = _firestore.batch();

      for (final docId in documentIds) {
        final docRef = _firestore.collection(collectionName).doc(docId);
        batch.update(docRef, {
          'is_deleted': false,
          'restored_at': Timestamp.now(),
        });
      }

      await batch.commit();
      print('✅ Restored ${documentIds.length} records from $collectionName');
      return true;
    } catch (e) {
      print('❌ Error restoring data: $e');
      return false;
    }
  }

  /// Permanently delete archived data (hard delete)
  Future<bool> permanentlyDeleteArchivedData(String collectionName, Duration olderThan) async {
    try {
      final cutoffDate = DateTime.now().subtract(olderThan);
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('is_deleted', isEqualTo: true)
          .where('deleted_at', isLessThan: cutoffTimestamp)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('ℹ️ No archived data to permanently delete');
        return true;
      }

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('🗑️ Permanently deleted ${querySnapshot.size} archived records from $collectionName');
      return true;
    } catch (e) {
      print('❌ Error permanently deleting data: $e');
      return false;
    }
  }
}
