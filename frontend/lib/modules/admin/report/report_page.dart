import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/attendance_service.dart';
import 'widgets/report_filters_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/division_chart_card.dart';
import 'widgets/stat_card.dart';
import 'models/division_report.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final AttendanceService _attendanceService = AttendanceService();
  
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _reportData;
  List<DivisionReport> _reports = [];
  
  @override
  void initState() {
    super.initState();
    _loadReportData();
  }
  
  Future<void> _loadReportData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      print('📊 Loading report data from API...');
      
      // Get current month date range
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);
      
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      
      // Fetch report data from API
      final response = await _attendanceService.getAdminReport(
        startDate: startDateStr,
        endDate: endDateStr,
        reportType: 'summary',
      );
      
      if (response.success && response.data != null) {
        print('✅ Report data loaded successfully');
        print('📊 Response data: $response.data');
        print('📊 Response data keys: ${response.data!.keys}');
        
        // Check if we need to unwrap 'report' key
        Map<String, dynamic> reportData = response.data!;
        if (reportData.containsKey('report') && reportData['report'] is Map) {
          print('📊 Found nested report, unwrapping...');
          reportData = reportData['report'] as Map<String, dynamic>;
          print('📊 Unwrapped report keys: ${reportData.keys}');
        }
        
        print('📊 Department breakdown: ${reportData['department_breakdown']}');
        print('📊 Department daily breakdown: ${reportData['department_daily_breakdown']}');
        
        setState(() {
          _reportData = reportData;
          _reports = _generateReportsFromData(reportData);
          _isLoading = false;
        });
        
        print('✅ Generated ${_reports.length} reports');
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load report data';
          _isLoading = false;
        });
        print('❌ Failed to load report: ${response.message}');
      }
    } catch (error) {
      setState(() {
        _error = 'Error loading report: $error';
        _isLoading = false;
      });
      print('❌ Exception loading report: $error');
    }
  }
  
  List<DivisionReport> _generateReportsFromData(Map<String, dynamic> data) {
    final reports = <DivisionReport>[];
    
    print('🔍 Generating reports from data...');
    print('🔍 Data keys: ${data.keys}');
    
    // Extract role breakdown and daily breakdown per role (changed from department)
    final roleBreakdown = data['role_breakdown'] as Map<String, dynamic>?;
    final roleDailyBreakdown = data['role_daily_breakdown'] as Map<String, dynamic>?;
    
    print('🔍 Role breakdown: ${roleBreakdown?.keys}');
    print('🔍 Role daily breakdown: ${roleDailyBreakdown?.keys}');
    
    if (roleBreakdown != null && roleDailyBreakdown != null) {
      print('✅ Found both role_breakdown and role_daily_breakdown');
      
      roleBreakdown.forEach((roleName, roleData) {
        print('🔍 Processing role: $roleName');
        final Map<String, dynamic> role = roleData as Map<String, dynamic>;
        final roleDaily = roleDailyBreakdown[roleName] as Map<String, dynamic>?;
        
        if (roleDaily == null) {
          print('⚠️ No daily data for $roleName');
          return;
        }
        
        print('✅ Found daily data for $roleName: ${roleDaily.keys.length} days');
        
        if (roleDaily.isNotEmpty) {
          // Get last 7 days of data
          final sortedDates = roleDaily.keys.toList()..sort();
          final last7Days = sortedDates.length > 7 
              ? sortedDates.sublist(sortedDates.length - 7)
              : sortedDates;
          
          // Create points from real data
          final points = <double>[];
          final labels = <String>[];
          
          // Day abbreviations
          const dayAbbr = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          
          for (var date in last7Days) {
            final dayData = roleDaily[date] as Map<String, dynamic>;
            final attendanceRate = double.tryParse(dayData['attendance_rate']?.toString() ?? '0') ?? 0.0;
            points.add(attendanceRate);
            
            // Parse date and get day abbreviation
            try {
              final parsedDate = DateTime.parse(date);
              labels.add(dayAbbr[parsedDate.weekday % 7]);
            } catch (e) {
              labels.add(date.substring(date.length - 2)); // Last 2 chars as fallback
            }
          }
          
          // Fill with 0 if less than 7 days
          while (points.length < 7) {
            points.insert(0, 0.0);
            labels.insert(0, '-');
          }
          
          // Extract role stats
          final totalRecords = role['total_records'] ?? 0;
          final presentCount = role['present'] ?? 0;
          final uniqueEmployees = role['unique_employees'] ?? 0;
          final attendanceRate = role['attendance_rate'] ?? '0';
          
          // Create subtitle with stats
          final subtitle = 'Present: $presentCount/$totalRecords • $uniqueEmployees employees • $attendanceRate% rate';
          
          reports.add(DivisionReport(
            divisionName: 'Total Attendance Report • $roleName',
            points: points,
            labels: labels,
            minY: 0.0,
            maxY: 100.0,
            yInterval: 20.0,
            highlightStart: points.length > 1 ? points.length - 2 : 0,
            highlightEnd: points.length - 1,
            subtitle: subtitle,
            totalRecords: totalRecords,
            presentCount: presentCount,
            uniqueEmployees: uniqueEmployees,
          ));
        } else {
          print('⚠️ Daily data is empty for $roleName');
        }
      });
    } else {
      print('❌ Missing data:');
      print('   - role_breakdown: ${roleBreakdown != null ? 'found' : 'NULL'}');
      print('   - role_daily_breakdown: ${roleDailyBreakdown != null ? 'found' : 'NULL'}');
    }
    
    print('✅ Generated ${reports.length} reports total');
    return reports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: const Text('Report',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // bar export / search / filter
                  const ReportFiltersBar(),
                  const SizedBox(height: 8),

                  // Loading state
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // Error state
                  if (_error != null && !_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadReportData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),

                  // Data loaded successfully
                  if (!_isLoading && _error == null) ...[
                    // Section: Clock In - Out
                    const SectionHeader(
                      title: 'Clock In - Out',
                      trailingText: 'view',
                    ),
                    const SizedBox(height: 8),

                    // Grafik per divisi
                    if (_reports.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No report data available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._reports.map((r) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: DivisionChartCard(report: r),
                          )),

                    const SizedBox(height: 12),
                    const SectionHeader(
                      title: 'Letter Assign',
                      trailingText: 'view',
                    ),
                    const SizedBox(height: 8),

                    // contoh kartu statistik
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          StatCard(
                            title: 'Sick',
                            subtitle: 'IT Divisi',
                            rightStatus: 'Clock In',
                            people: 245,
                          ),
                          SizedBox(height: 12),
                          StatCard(
                            title: 'Annual Leave',
                            subtitle: 'IT Divisi',
                            rightStatus: 'Clock In',
                            people: 245,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
