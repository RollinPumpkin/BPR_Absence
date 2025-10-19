import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/data/providers/user_provider.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/attendance.dart';
import 'package:frontend/data/services/attendance_service.dart';

import 'widgets/date_row.dart';
import 'widgets/attendance_stat.dart';
import 'widgets/divider.dart';
import 'widgets/attendance_card.dart';
import 'widgets/section_lined_title.dart';
import 'pages/attendance_form_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final AttendanceService _attendanceService = AttendanceService();
  List<Attendance> _attendanceRecords = [];
  List<Attendance> _filteredAttendanceRecords = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedStatusFilter; // Filter by status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendanceData();
    });
  }

  Future<void> _loadAttendanceData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('🔄 Loading attendance data from Firestore...');
      
      // Get attendance records from Firestore - get all statuses
      final response = await _attendanceService.getAttendanceRecords(
        limit: 100, // Increase limit to get more records including all statuses
      );

      print('📊 API Response: ${response.success}');
      print('📊 Response Data: ${response.data}');
      
      if (response.success && response.data != null) {
        setState(() {
          _attendanceRecords = response.data!.items;
          _filteredAttendanceRecords = _attendanceRecords; // Initialize filtered list
          _isLoading = false;
        });
        
        print('✅ Loaded ${_attendanceRecords.length} attendance records from Firestore');
        
        // Debug: Print first few records
        for (int i = 0; i < _attendanceRecords.length && i < 3; i++) {
          final attendance = _attendanceRecords[i];
          print('👤 Record $i: ${attendance.userName} - ${attendance.status} - ${attendance.date}');
        }
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load attendance data';
          _attendanceRecords = [];
          _filteredAttendanceRecords = [];
          _isLoading = false;
        });
        print('❌ Failed to load attendance: ${response.message}');
      }
    } catch (error) {
      setState(() {
        _error = 'Error loading attendance data: $error';
        _attendanceRecords = [];
        _filteredAttendanceRecords = [];
        _isLoading = false;
      });
      print('❌ Exception loading attendance: $error');
    }
  }

  void _applyStatusFilter(String? status) {
    setState(() {
      _selectedStatusFilter = status;
      if (status == null) {
        _filteredAttendanceRecords = _attendanceRecords;
      } else {
        _filteredAttendanceRecords = _attendanceRecords.where((attendance) {
          final attendanceStatus = attendance.status.toLowerCase();
          switch (status.toLowerCase()) {
            case 'present':
              return attendanceStatus == 'present';
            case 'late':
              return attendanceStatus == 'late';
            case 'sick':
              return attendanceStatus == 'sick' || attendanceStatus == 'sick_leave';
            case 'leave':
              return attendanceStatus == 'leave' || attendanceStatus == 'absent' || attendanceStatus == 'annual_leave';
            default:
              return true;
          }
        }).toList();
      }
    });
    
    print('🔍 Filter applied: $status');
    print('📊 Filtered results: ${_filteredAttendanceRecords.length} records');
  }

  Widget _buildStatsFromData() {
    // Calculate stats from real attendance data (use original data for stats)
    int presentCount = 0;
    int lateCount = 0;
    int sickCount = 0;
    int leaveCount = 0;

    print('🔢 Calculating statistics from ${_attendanceRecords.length} records...');

    for (final attendance in _attendanceRecords) {
      final status = attendance.status.toLowerCase().trim();
      print('📊 Status: "$status" for ${attendance.userName}');
      
      switch (status) {
        case 'present':
          presentCount++;
          break;
        case 'late':
          lateCount++;
          break;
        case 'sick':
        case 'sick_leave':
          sickCount++;
          break;
        case 'leave':
        case 'absent':
        case 'annual_leave':
          leaveCount++;
          break;
        default:
          print('⚠️ Unknown status: "$status"');
          // Count unknown status as absent/leave
          leaveCount++;
          break;
      }
    }

    print('📈 Final stats: Present=$presentCount, Late=$lateCount, Sick=$sickCount, Leave=$leaveCount');

    return _StatsBar(
      stats: [
        _StatItem('Present', presentCount.toString(), AppColors.primaryGreen, 
                  onTap: () => _applyStatusFilter(presentCount > 0 ? 'present' : null)),
        _StatItem('Late', lateCount.toString(), AppColors.primaryRed,
                  onTap: () => _applyStatusFilter(lateCount > 0 ? 'late' : null)),
        _StatItem('Sick', sickCount.toString(), AppColors.primaryYellow,
                  onTap: () => _applyStatusFilter(sickCount > 0 ? 'sick' : null)),
        _StatItem('Leave', leaveCount.toString(), AppColors.accentBlue,
                  onTap: () => _applyStatusFilter(leaveCount > 0 ? 'leave' : null)),
      ],
    );
  }

  List<Map<String, dynamic>> _generateAttendanceDisplayData() {
    print('🔄 Generating attendance display data...');
    print('📊 Total filtered records: ${_filteredAttendanceRecords.length}');
    
    if (_filteredAttendanceRecords.isEmpty) {
      print('⚠️ No filtered attendance records to display');
      return [];
    }

    final displayData = _filteredAttendanceRecords.map((attendance) {
      final status = attendance.status.toLowerCase().trim();
      
      // Determine status color based on attendance status - handle all cases
      Color statusColor;
      String displayStatus = attendance.status; // Keep original for display
      
      switch (status) {
        case 'present':
          statusColor = AppColors.primaryGreen;
          break;
        case 'late':
          statusColor = AppColors.primaryRed;
          break;
        case 'sick':
        case 'sick_leave':
          statusColor = AppColors.primaryYellow;
          displayStatus = 'Sick'; // Normalize display text
          break;
        case 'leave':
        case 'absent':
        case 'annual_leave':
          statusColor = AppColors.accentBlue;
          displayStatus = 'Leave'; // Normalize display text
          break;
        default:
          statusColor = AppColors.neutral400;
      }

      final displayItem = {
        'name': attendance.userName ?? 'Unknown User',
        'division': attendance.department ?? 'Unknown Department',
        'status': displayStatus, // Use normalized display status
        'statusColor': statusColor,
        'clockIn': attendance.checkInTime ?? '-',
        'clockOut': attendance.checkOutTime ?? '-',
        'date': attendance.formattedDate,
        'attendance': attendance,
      };

      // Debug log for each item
      print('👤 ${displayItem['name']} - Status: ${displayItem['status']} (${status}) - Date: ${displayItem['date']}');
      
      return displayItem;
    }).toList();
    
    print('✅ Generated ${displayData.length} attendance display items');
    
    // Group by status for verification
    final statusCounts = <String, int>{};
    for (final item in displayData) {
      final status = item['status'].toString().toLowerCase();
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    print('📊 Status breakdown in display data: $statusCounts');
    
    return displayData;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _selectedStatusFilter,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _applyStatusFilter(value);
                  },
                ),
              ),
              ListTile(
                title: const Text('Present'),
                leading: Radio<String?>(
                  value: 'present',
                  groupValue: _selectedStatusFilter,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _applyStatusFilter(value);
                  },
                ),
              ),
              ListTile(
                title: const Text('Late'),
                leading: Radio<String?>(
                  value: 'late',
                  groupValue: _selectedStatusFilter,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _applyStatusFilter(value);
                  },
                ),
              ),
              ListTile(
                title: const Text('Sick'),
                leading: Radio<String?>(
                  value: 'sick',
                  groupValue: _selectedStatusFilter,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _applyStatusFilter(value);
                  },
                ),
              ),
              ListTile(
                title: const Text('Leave'),
                leading: Radio<String?>(
                  value: 'leave',
                  groupValue: _selectedStatusFilter,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _applyStatusFilter(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportAttendanceExcel() async {
    try {
      print('📊 Exporting ${_filteredAttendanceRecords.length} attendance records...');
      
      final excel = Excel.createExcel();
      final sheet = excel['Attendance Report'];
      excel.setDefaultSheet('Attendance Report');

      // Headers
      const headers = [
        'Employee ID', 'Name', 'Department', 'Date', 
        'Status', 'Check In', 'Check Out', 'Notes'
      ];
      
      for (var c = 0; c < headers.length; c++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
        cell.value = TextCellValue(headers[c]);
        cell.cellStyle = CellStyle(bold: true);
      }

      // Data rows
      for (var r = 0; r < _filteredAttendanceRecords.length; r++) {
        final attendance = _filteredAttendanceRecords[r];
        final values = [
          attendance.employeeId ?? 'N/A',
          attendance.userName ?? 'Unknown User',
          attendance.department ?? 'Unknown Department',
          attendance.formattedDate,
          attendance.status,
          attendance.checkInTime ?? 'N/A',
          attendance.checkOutTime ?? 'N/A',
          attendance.notes ?? 'N/A',
        ];
        
        for (var c = 0; c < values.length; c++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
              .value = TextCellValue(values[c]);
        }
      }

      // Save file
      final saved = excel.save();
      if (saved == null) throw 'Failed to generate file bytes';
      final bytes = Uint8List.fromList(saved);
      
      final filterText = _selectedStatusFilter != null ? '_${_selectedStatusFilter}' : '';
      final filename = 'attendance_report${filterText}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      await FileSaver.instance.saveFile(
        name: filename,
        bytes: bytes,
        mimeType: MimeType.microsoftExcel,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${_filteredAttendanceRecords.length} records to Excel successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
      
      print('✅ Excel export completed: $filename');
    } catch (e) {
      print('❌ Export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceData = _generateAttendanceDisplayData();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.neutral500),
            onPressed: _loadAttendanceData,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAttendanceData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      
                      // Tanggal
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: DateRow(),
                      ),
                      const SizedBox(height: 12),

                      // Statistics from real data
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildStatsFromData(),
                      ),

                      const SizedBox(height: 10),

                      // Section title
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
                            _showFilterDialog();
                          },
                          icon: Icon(
                            Icons.filter_list, 
                            size: 18,
                            color: _selectedStatusFilter != null 
                                ? AppColors.primaryBlue 
                                : AppColors.neutral800,
                          ),
                          label: Text(
                            _selectedStatusFilter ?? 'Filter',
                            style: TextStyle(
                              color: _selectedStatusFilter != null 
                                  ? AppColors.primaryBlue 
                                  : AppColors.neutral800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _selectedStatusFilter != null 
                                ? AppColors.primaryBlue 
                                : AppColors.neutral800,
                            side: BorderSide(
                              color: _selectedStatusFilter != null 
                                  ? AppColors.primaryBlue 
                                  : AppColors.dividerGray,
                            ),
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
                          onPressed: () => _exportAttendanceExcel(),
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

                // List attendance cards from Firestore data
                if (attendanceData.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined, 
                            size: 64, 
                            color: AppColors.neutral400
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No attendance records found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...attendanceData.map((attendance) => AttendanceCard(
                    name: attendance['name'],
                    division: attendance['division'],
                    status: attendance['status'],
                    statusColor: attendance['statusColor'],
                    clockIn: attendance['clockIn'],
                    clockOut: attendance['clockOut'],
                    date: attendance['date'],
                    user: null, // We don't have User object, just attendance data
                  )).toList(),
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
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
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
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  const _StatItem(this.label, this.value, this.color, {this.onTap});
}
