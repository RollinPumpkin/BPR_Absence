import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';

import 'widgets/date_row.dart';
import 'widgets/attendance_stat.dart';
import 'widgets/divider.dart';
import 'widgets/attendance_card.dart';
import 'widgets/section_lined_title.dart';
import 'pages/attendance_form_page.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanggal
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: DateRow(),
            ),
            const SizedBox(height: 12),

            // Stat ringkas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StatsBar(
                stats: const [
                  _StatItem('Present', '28', AppColors.primaryGreen),
                  _StatItem('Late', '15', AppColors.primaryRed),
                  _StatItem('Sick', '15', AppColors.primaryYellow),
                  _StatItem('Leave', '5', AppColors.accentBlue),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ====== Tambahan: Judul "Data" + garis ======
            const LinedSectionTitle(title: "Data"),

            // Aksi: Filter • Export • Attendance Form
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  // FILTER
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: tampilkan filter
                      },
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: const Text('Filter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.neutral800,
                        side: const BorderSide(color: AppColors.dividerGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // EXPORT
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _exportAttendanceExcel(context),
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('Export'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        backgroundColor: AppColors.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ATTENDANCE FORM
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AttendanceFormPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 18,
                      ),
                      label: const Text('Attendance Form'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.pureWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // List kartu attendance (contoh)
            AttendanceCard(
              name: "Haidar Mahapatih",
              division: "Mobile Developer",
              status: "Present",
              statusColor: AppColors.primaryGreen,
              clockIn: "08:33:10",
              clockOut: "16:03:10",
              date: "20 Januari 2025",
            ),
            AttendanceCard(
              name: "Septa Puma",
              division: "Web Developer",
              status: "Sick",
              statusColor: AppColors.primaryYellow,
              clockIn: "-",
              clockOut: "-",
              date: "19 Januari 2025",
            ),
            AttendanceCard(
              name: "Agung Riyadi",
              division: "Backend Developer",
              status: "Late",
              statusColor: AppColors.primaryRed,
              clockIn: "09:45:56",
              clockOut: "-",
              date: "18 Januari 2025",
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNavRouter(
        currentIndex: 1,
        items: AdminNavItems.items,
      ),
    );
  }
}

/// Card stats responsif (Row di layar lebar, Wrap di layar sempit)
class _StatsBar extends StatelessWidget {
  final List<_StatItem> stats;
  const _StatsBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final bool narrow = w < 360;

        final content = [
          for (int i = 0; i < stats.length; i++) ...[
            if (i != 0)
              narrow
                  ? const SizedBox(width: 10, height: 10)
                  : const VerticalDividerCustom(),
            _StatBox(item: stats[i]),
          ],
        ];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: narrow
              ? Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  children: content,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: content,
                ),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final _StatItem item;
  const _StatBox({required this.item});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AttendanceStat(
            label: item.label,
            value: item.value,
            color: item.color,
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);
}

Future<void> _exportAttendanceExcel(BuildContext context) async {
  // TODO: ambil dari data asli (provider/repo). Ini contoh dummy:
  final data = <Map<String, String>>[
    {
      'Name': 'Haidar Mahapatih',
      'Division': 'Mobile Developer',
      'Status': 'Present',
      'Clock In': '08:33:10',
      'Clock Out': '16:03:10',
      'Date': '20 Januari 2025',
    },
    {
      'Name': 'Septa Puma',
      'Division': 'Web Developer',
      'Status': 'Sick',
      'Clock In': '-',
      'Clock Out': '-',
      'Date': '19 Januari 2025',
    },
    {
      'Name': 'Agung Riyadi',
      'Division': 'Backend Developer',
      'Status': 'Late',
      'Clock In': '09:45:56',
      'Clock Out': '-',
      'Date': '18 Januari 2025',
    },
  ];

  try {
    final excel = Excel.createExcel();
    final sheet = excel['Attendance'];
    excel.setDefaultSheet('Attendance');

    // ===== Header (row 0) =====
    const headers = ['Name', 'Division', 'Status', 'Clock In', 'Clock Out', 'Date'];
    for (var c = 0; c < headers.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);        // ← v4: pakai TextCellValue
      cell.cellStyle = CellStyle(bold: true);
    }

    // ===== Data rows (mulai rowIndex = 1) =====
    for (var r = 0; r < data.length; r++) {
      final row = data[r];
      final values = [
        row['Name'] ?? '',
        row['Division'] ?? '',
        row['Status'] ?? '',
        row['Clock In'] ?? '',
        row['Clock Out'] ?? '',
        row['Date'] ?? '',
      ];
      for (var c = 0; c < values.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
            .value = TextCellValue(values[c]);       // ← v4: pakai TextCellValue
      }
    }

    // Simpan
    final saved = excel.save();                      // List<int>?
    if (saved == null) throw 'Failed to generate file bytes';
    final bytes = Uint8List.fromList(saved);
    final filename = 'attendance_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    await FileSaver.instance.saveFile(
      name: filename,
      bytes: bytes,
      mimeType: MimeType.microsoftExcel,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported to Excel successfully'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}
