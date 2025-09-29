import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/core/constants/colors.dart';

import 'widgets/letter_card.dart';
import 'widgets/add_letter_type_popup.dart';
import 'widgets/view_letter_type_popup.dart';
import 'pages/add_letter_page.dart';
import 'pages/letter_acceptance_page.dart';

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';

class LetterPage extends StatelessWidget {
  const LetterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Toolbar (Filter / Export / Add Data / Add & View Letter Type)
              const _LetterToolbar(),
              const SizedBox(height: 16),

              // Search
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Employee',
                  prefixIcon: const Icon(Icons.search, color: AppColors.neutral500),
                  filled: true,
                  fillColor: AppColors.pureWhite,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.dividerGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.dividerGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // List Letter
              LetterCard(
                name: 'Septa Puma',
                date: '27 Agustus 2024',
                type: "Doctor's Note",
                status: 'Waiting Approval',
                statusColor: AppColors.primaryYellow,
                absence: 'Absence',
                absenceColor: AppColors.primaryYellow,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LetterAcceptancePage()),
                  );
                },
              ),
              const SizedBox(height: 12),
              LetterCard(
                name: 'Septa Puma',
                date: '27 Agustus 2024',
                type: "Doctor's Note",
                status: 'Rejected',
                statusColor: AppColors.primaryRed,
                absence: 'Absence',
                absenceColor: AppColors.primaryRed,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LetterAcceptancePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // Bottom Nav
      bottomNavigationBar: const CustomBottomNavRouter(
        currentIndex: 3,
        items: AdminNavItems.items,
      ),
    );
  }
}

class _LetterToolbar extends StatelessWidget {
  const _LetterToolbar();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // Filter
          OutlinedButton.icon(
            onPressed: () {
              // TODO: buka dialog / bottom sheet filter
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
          const SizedBox(width: 8),

          // Export → Excel
          OutlinedButton(
            onPressed: () => _exportLettersExcel(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.primaryRed),
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Export', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),

          // Add Data
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddLetterPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text('Add Data', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),

          // Add Letter Type (popup)
          ElevatedButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => const AddLetterTypePopup());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child:
                const Text('Add Letter Type', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),

          // View Letter Type (popup)
          ElevatedButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => const ViewLetterTypePopup());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child:
                const Text('View Letter Type', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ===== Export helper =====
Future<void> _exportLettersExcel(BuildContext context) async {
  // TODO: ganti ke data asli dari state/VM/repo kamu
  final rows = <Map<String, String>>[
    {
      'Name': 'Septa Puma',
      'Date': '27 Agustus 2024',
      'Type': "Doctor's Note",
      'Status': 'Waiting Approval',
      'Absence': 'Absence',
    },
    {
      'Name': 'Septa Puma',
      'Date': '27 Agustus 2024',
      'Type': "Doctor's Note",
      'Status': 'Rejected',
      'Absence': 'Absence',
    },
  ];

  try {
    final excel = Excel.createExcel();
    final sheet = excel['Letters'];
    excel.setDefaultSheet('Letters');

    // header
    const headers = ['Name', 'Date', 'Type', 'Status', 'Absence'];
    for (var c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // data
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      final values = [
        row['Name'] ?? '',
        row['Date'] ?? '',
        row['Type'] ?? '',
        row['Status'] ?? '',
        row['Absence'] ?? '',
      ];
      for (var c = 0; c < values.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
            .value = TextCellValue(values[c]);
      }
    }

    final bytes = Uint8List.fromList(excel.save()!);
    final filename = 'letters_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    await FileSaver.instance.saveFile(
      name: filename,
      bytes: bytes,
      fileExtension: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Letters exported successfully'),
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
