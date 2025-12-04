import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';
import 'package:frontend/data/services/assignment_service.dart';
import 'package:frontend/data/models/assignment.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/services/realtime_service.dart';
import 'dart:async';
import 'assignment_detail_page.dart';

class UserAssignmentPage extends StatefulWidget {
  const UserAssignmentPage({super.key});

  @override
  State<UserAssignmentPage> createState() => _UserAssignmentPageState();
}

class _UserAssignmentPageState extends State<UserAssignmentPage> with WidgetsBindingObserver {
  String selectedFilter = "Monthly";
  DateTime? _currentMonth;
  DateTime? _selectedDate;
  
  final AssignmentService _assignmentService = AssignmentService();
  final RealtimeService _realtimeService = RealtimeService();
  StreamSubscription? _assignmentsSubscription;
  
  List<Assignment> _assignments = [];
  bool _isLoading = true;
  String? _error;

  DateTime get currentMonth => _currentMonth ?? DateTime.now();
  DateTime get selectedDate => _selectedDate ?? DateTime.now();

  set currentMonth(DateTime value) => _currentMonth = value;
  set selectedDate(DateTime value) => _selectedDate = value;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _initializeRealtime();
  }

  Future<void> _initializeRealtime() async {
    await _realtimeService.initialize();
    _realtimeService.startAssignmentsListener();
    
    _assignmentsSubscription = _realtimeService.assignmentsStream.listen((assignmentsData) {
      if (mounted) {
        setState(() {
          _assignments = assignmentsData.map((data) => Assignment.fromJson(data)).toList();
          _isLoading = false;
        });
        print('🔄 User Assignments: Realtime updated (${assignmentsData.length} assignments)');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _assignmentsSubscription?.cancel();
    _realtimeService.stopAllListeners();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 [Lifecycle] App resumed, reloading assignments...');
      _loadAssignments();
    }
  }

  Future<void> _loadAssignments({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _assignments = []; // Clear old data first
      });

      print('📋 [AssignmentPage] Loading assignments... (forceRefresh: $forceRefresh)');
      final assignments = await _assignmentService.getUpcomingAssignments(forceRefresh: forceRefresh);
      
      if (mounted) {
        setState(() {
          _assignments = List.from(assignments); // Create new list instance
          _isLoading = false;
        });
        
        print('✅ [AssignmentPage] Loaded ${assignments.length} assignments');
        print('📊 [AssignmentPage] Assignment statuses:');
        for (var assignment in assignments) {
          print('  - ${assignment.title}: ${assignment.status}${assignment.completionTime != null ? ' at ${assignment.completionTime}' : ''}');
        }
      }
    } catch (e) {
      print('❌ [AssignmentPage] Error loading assignments: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: selectedFilter == "Daily"
                  ? _buildDailyView()
                  : selectedFilter == "Weekly"
                  ? _buildWeeklyView()
                  : _buildMonthlyView(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNavRouter(
        currentIndex: 2,
        items: UserNavItems.items,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Assignment",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildFilterTab("Daily"),
                _buildFilterTab("Weekly"),
                _buildFilterTab("Monthly"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter) {
    bool isSelected = selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.errorRed : AppColors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            filter,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.pureWhite : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyView() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading daily assignments...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('Error loading assignments', style: TextStyle(color: Colors.red.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAssignments, child: const Text('Retry')),
          ],
        ),
      );
    }

    List<Map<String, dynamic>> dailyData = _generateDailyData();

    if (dailyData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No assignments found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: dailyData.length,
      itemBuilder: (context, index) {
        return _buildDailyCard(dailyData[index]);
      },
    );
  }

  Widget _buildDailyCard(Map<String, dynamic> dayData) {
    bool isActiveDay = dayData['isActive'];
    int assignmentCount = dayData['assignments'].length;

    return Column(
      children: [
        Row(
          children: [
            // Date and Day Column
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayData['date'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isActiveDay
                          ? AppColors.errorRed
                          : Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    dayData['day'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isActiveDay
                          ? AppColors.errorRed
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Vertical Timeline Line
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 4,
                    height: assignmentCount > 1
                        ? (assignmentCount * 180.0) -
                              30 // Dynamic height based on assignments
                        : 150,
                    decoration: BoxDecoration(
                      color: isActiveDay
                          ? AppColors.errorRed
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),

            /// Assignment Cards for this day
            Expanded(
              child: Column(
                children: dayData['assignments'].map<Widget>((assignment) {
                  return _buildAssignmentCard(assignment);
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWeeklyView() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading weekly assignments...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('Error loading assignments', style: TextStyle(color: Colors.red.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAssignments, child: const Text('Retry')),
          ],
        ),
      );
    }

    List<Map<String, dynamic>> weeklyData = _generateWeeklyData();

    if (weeklyData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No assignments for this week', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: weeklyData.length,
      itemBuilder: (context, index) {
        return _buildDailyCard(weeklyData[index]);
      },
    );
  }

  Widget _buildMonthlyView() {
    return Column(
      children: [
        _buildCalendarWidget(),
        Expanded(child: _buildAssignmentsList()),
      ],
    );
  }

  Widget _buildCalendarWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              currentMonth = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left, color: AppColors.primaryBlue),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Expanded(
          child: Text(
            "${_getMonthName(currentMonth.month)} ${currentMonth.year}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              currentMonth = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_right, color: AppColors.primaryBlue),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    // Days of the week header
    List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        // Week day headers
        Row(
          children: weekDays
              .map(
                (day) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              )
              .toList(),
        ),

        // Calendar days grid
        ..._buildCalendarRows(),
      ],
    );
  }

  List<Widget> _buildCalendarRows() {
    List<Widget> rows = [];

    // Get first day of the month and number of days
    DateTime firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    int daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;
    int startingWeekday = firstDay.weekday % 7; // Sunday = 0

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(Expanded(child: Container()));
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDay = DateTime(
        currentMonth.year,
        currentMonth.month,
        day,
      );
      
      // Check if this is today
      DateTime today = DateTime.now();
      bool isToday = currentDay.day == today.day &&
                    currentDay.month == today.month &&
                    currentDay.year == today.year;
      
      // Check if this is selected date
      bool isSelected =
          currentDay.day == selectedDate.day &&
          currentDay.month == selectedDate.month &&
          currentDay.year == selectedDate.year;
          
      // Check if has assignment
      bool hasAssignment = _hasAssignmentOnDate(currentDay);

      // Determine colors based on priority: Today (blue) > Selected (yellow) > HasAssignment > Default
      Color backgroundColor;
      Color textColor;
      FontWeight fontWeight = FontWeight.normal;
      Border? border;

      if (isToday) {
        // Today has highest priority - always blue background
        if (hasAssignment) {
          backgroundColor = AppColors.errorRed;
          textColor = AppColors.pureWhite;
          border = Border.all(color: AppColors.primaryBlue, width: 2);
        } else {
          backgroundColor = AppColors.primaryBlue;
          textColor = AppColors.pureWhite;
        }
        fontWeight = FontWeight.bold;
      } else if (isSelected) {
        // Selected date (not today) - yellow background
        backgroundColor = AppColors.primaryYellow;
        textColor = AppColors.pureWhite;
        fontWeight = FontWeight.bold;
      } else if (hasAssignment) {
        // Has assignment - red background
        backgroundColor = AppColors.errorRed;
        textColor = AppColors.pureWhite;
        fontWeight = FontWeight.bold;
      } else {
        // Default - transparent background
        backgroundColor = AppColors.transparent;
        textColor = AppColors.black87;
      }

      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = currentDay;
              });
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: border,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: fontWeight,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Create new row every 7 days
      if (dayWidgets.length == 7) {
        rows.add(Row(children: dayWidgets));
        dayWidgets = [];
      }
    }

    // Fill remaining cells in the last row
    while (dayWidgets.length < 7 && dayWidgets.isNotEmpty) {
      dayWidgets.add(Expanded(child: Container()));
    }

    if (dayWidgets.isNotEmpty) {
      rows.add(Row(children: dayWidgets));
    }

    return rows;
  }

  Widget _buildAssignmentsList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading assignments...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading assignments',
              style: TextStyle(color: Colors.red.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAssignments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    List<Assignment> assignments = _getAssignmentsForDate(selectedDate);

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No assignments for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildRealAssignmentCard(assignments[index]),
        );
      },
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentDetailPage(assignment: assignment),
          ),
        );
        
        // Reload assignments if completed
        if (result == true && mounted) {
          print('🔄 [AssignmentPage] Assignment completed, reloading data...');
          await _loadAssignments();
          print('✅ [AssignmentPage] Reload complete, UI should update now');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    assignment['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: assignment['priority'] == 'High'
                        ? AppColors.errorRed
                        : assignment['priority'] == 'Medium'
                        ? AppColors.vibrantOrange
                        : AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    assignment['priority'],
                    style: TextStyle(
                      fontSize: 12,
                      color: assignment['priority'] == 'High'
                          ? AppColors.errorRed
                          : assignment['priority'] == 'Medium'
                          ? AppColors.vibrantOrange
                          : AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assignment['category'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              assignment['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  assignment['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      assignment['peopleCount'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "View",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateDailyData() {
    if (_assignments.isEmpty) {
      return [];
    }

    // Group assignments by date
    Map<String, List<Assignment>> assignmentsByDate = {};
    
    for (Assignment assignment in _assignments) {
      String dateKey = DateFormat('yyyy-MM-dd').format(assignment.dueDate);
      if (!assignmentsByDate.containsKey(dateKey)) {
        assignmentsByDate[dateKey] = [];
      }
      assignmentsByDate[dateKey]!.add(assignment);
    }

    // Convert to daily data format
    List<Map<String, dynamic>> dailyData = [];
    List<String> sortedDates = assignmentsByDate.keys.toList()..sort();
    
    DateTime today = DateTime.now();
    
    for (String dateKey in sortedDates) {
      DateTime date = DateTime.parse(dateKey);
      List<Assignment> dayAssignments = assignmentsByDate[dateKey]!;
      
      bool isActiveDay = date.year == today.year && 
                        date.month == today.month && 
                        date.day == today.day;
      
      dailyData.add({
        'date': date.day.toString(),
        'day': DateFormat('EEE').format(date).toUpperCase(),
        'isActive': isActiveDay,
        'assignments': dayAssignments.map((assignment) => _convertAssignmentToMap(assignment)).toList(),
      });
    }
    
    return dailyData;
  }

  List<Map<String, dynamic>> _generateWeeklyData() {
    if (_assignments.isEmpty) {
      return [];
    }

    // Get current week's assignments
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    List<Assignment> weekAssignments = _assignments.where((assignment) {
      return assignment.dueDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             assignment.dueDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();

    // Group by date
    Map<String, List<Assignment>> assignmentsByDate = {};
    
    for (Assignment assignment in weekAssignments) {
      String dateKey = DateFormat('yyyy-MM-dd').format(assignment.dueDate);
      if (!assignmentsByDate.containsKey(dateKey)) {
        assignmentsByDate[dateKey] = [];
      }
      assignmentsByDate[dateKey]!.add(assignment);
    }

    // Convert to weekly data format
    List<Map<String, dynamic>> weeklyData = [];
    List<String> sortedDates = assignmentsByDate.keys.toList()..sort();
    
    DateTime today = DateTime.now();
    
    for (String dateKey in sortedDates) {
      DateTime date = DateTime.parse(dateKey);
      List<Assignment> dayAssignments = assignmentsByDate[dateKey]!;
      
      bool isActiveDay = date.year == today.year && 
                        date.month == today.month && 
                        date.day == today.day;
      
      weeklyData.add({
        'date': date.day.toString(),
        'day': DateFormat('EEE').format(date).toUpperCase(),
        'isActive': isActiveDay,
        'assignments': dayAssignments.map((assignment) => _convertAssignmentToMap(assignment)).toList(),
      });
    }
    
    return weeklyData;
  }

  bool _hasAssignmentOnDate(DateTime date) {
    // Check if any real assignments are due on this date
    return _assignments.any((assignment) {
      return assignment.dueDate.year == date.year &&
             assignment.dueDate.month == date.month &&
             assignment.dueDate.day == date.day;
    });
  }

  List<Assignment> _getAssignmentsForDate(DateTime date) {
    // Get real assignments for the specified date
    final filtered = _assignments.where((assignment) {
      return assignment.dueDate.year == date.year &&
             assignment.dueDate.month == date.month &&
             assignment.dueDate.day == date.day;
    }).toList();
    
    print('📅 [Filter] Found ${filtered.length} assignments for ${date.day}/${date.month}/${date.year}');
    for (var assignment in filtered) {
      print('  - ${assignment.title}: status=${assignment.status}, completionTime=${assignment.completionTime}');
    }
    
    return filtered;
  }

  Widget _buildRealAssignmentCard(Assignment assignment) {
    // Convert Assignment object to display format
    final now = DateTime.now();
    final isToday = assignment.dueDate.year == now.year &&
                   assignment.dueDate.month == now.month &&
                   assignment.dueDate.day == now.day;
    
    // Format time
    final timeFormatter = DateFormat('HH:mm');
    final timeString = '${timeFormatter.format(assignment.dueDate)} - Due';
    
    return GestureDetector(
      onTap: () async {
        print('👆 [Click] Opening assignment: ${assignment.title}');
        print('📊 [Click] Current status: ${assignment.status}');
        print('⏰ [Click] Current completionTime: ${assignment.completionTime}');
        
        // Convert Assignment to Map for detail page
        final assignmentMap = {
          'id': assignment.id,
          'title': assignment.title,
          'description': assignment.description,
          'priority': assignment.priority,
          'status': assignment.status,
          'dueDate': assignment.dueDate.toIso8601String(),
          'startDate': assignment.startDate?.toIso8601String(),
          'createdBy': assignment.createdBy,
          'category': assignment.category,
          'tags': assignment.tags,
          'attachments': assignment.attachments,
          'time': timeString,
          'peopleCount': '1 person',
          // Completion data - IMPORTANT: Pass these fields
          'completionTime': assignment.completionTime,
          'completionDate': assignment.completionDate,
          'completedAt': assignment.completedAt?.toIso8601String(),
          'completedBy': assignment.completedBy,
        };
        
        print('📤 [Click] Passing to detail page with completionTime: ${assignmentMap['completionTime']}');
        
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentDetailPage(
              key: ValueKey('${assignment.id}_${DateTime.now().millisecondsSinceEpoch}'),
              assignment: assignmentMap,
            ),
          ),
        );
        
        // ALWAYS reload assignments after returning from detail page
        if (mounted) {
          print('🔄 [AssignmentPage] Returned from detail, reloading data...');
          await _loadAssignments(forceRefresh: true); // Force refresh to bypass cache
          print('✅ [AssignmentPage] Reload complete');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: AppColors.errorRed, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(assignment.priority),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    assignment.priority.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${assignment.status}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              assignment.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  timeString,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "DUE TODAY",
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "View",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.errorRed;
      case 'medium':
        return AppColors.vibrantOrange;
      case 'low':
        return AppColors.primaryGreen;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> _convertAssignmentToMap(Assignment assignment) {
    final timeFormatter = DateFormat('HH:mm');
    final timeString = '${timeFormatter.format(assignment.dueDate)} - Due';
    
    return {
      'title': assignment.title,
      'category': 'Assignment',
      'description': assignment.description,
      'time': timeString,
      'priority': assignment.priority.toLowerCase() == 'high' ? 'High' : 
                 assignment.priority.toLowerCase() == 'medium' ? 'Medium' : 'Low',
      'peopleCount': '1 person',
      'status': assignment.status,
      'dueDate': assignment.dueDate.toIso8601String(),
      'createdBy': assignment.createdBy,
    };
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
