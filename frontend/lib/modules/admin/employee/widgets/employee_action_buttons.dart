import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/employee/pages/add_data_page.dart';

class EmployeeActionButtons extends StatelessWidget {
  const EmployeeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Filter (netral, outline)
        OutlinedButton.icon(
          onPressed: () {
            // TODO: open filter sheet / dialog
          },
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.neutral800,
            side: const BorderSide(color: AppColors.dividerGray),
            backgroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),

        // Import (hijau)
        ElevatedButton.icon(
          onPressed: () {
            // TODO: import handler
          },
          icon: const Icon(Icons.file_upload_outlined, size: 18),
          label: const Text('Import'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),

        // Export (merah) -> Excel
        ElevatedButton.icon(
          onPressed: () => _exportEmployeesExcel(context),
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('Export'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),

        // Add Data (biru)
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEmployeePage()),
            );
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

/// ===== Excel export (excel ^4.0.2 + file_saver ^0.2.12) =====
Future<void> _exportEmployeesExcel(BuildContext context) async {
  // TODO: ganti dengan data asli dari state/provider/repository kamu
  final data = <Map<String, String>>[
    {
      'Name': 'Septa Puma',
      'Division': 'IT Divisi',
      'Position': 'Manager',
      'Phone': '+62 73832',
      'Status': 'Active',
    },
    {
      'Name': 'Anindya Nurhaliza',
      'Division': 'Finance',
      'Position': 'Staff',
      'Phone': '+62 81234',
      'Status': 'Active',
    },
  ];

  try {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Employees'];
    excel.setDefaultSheet('Employees');

    // Header
    const headers = ['Name', 'Division', 'Position', 'Phone', 'Status'];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Rows
    for (final row in data) {
      sheet.appendRow([
        TextCellValue(row['Name'] ?? ''),
        TextCellValue(row['Division'] ?? ''),
        TextCellValue(row['Position'] ?? ''),
        TextCellValue(row['Phone'] ?? ''),
        TextCellValue(row['Status'] ?? ''),
      ]);
    }

    // Bold header (baris 0)
    for (var c = 0; c < headers.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.cellStyle = CellStyle(bold: true);
    }

    // Simpan
    final bytes = Uint8List.fromList(excel.save()!);
    final filename = 'employees_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    await FileSaver.instance.saveFile(
      name: filename,
      bytes: bytes,
      mimeType: MimeType.microsoftExcel,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported employees to Excel'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }
}
