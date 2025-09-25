import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';
import 'assignment_detail_page.dart';

class UserAssignmentPage extends StatefulWidget {
  const UserAssignmentPage({super.key});

  @override
  State<UserAssignmentPage> createState() => _UserAssignmentPageState();
}

class _UserAssignmentPageState extends State<UserAssignmentPage> {
  String selectedFilter = "Monthly";
  DateTime? _currentMonth;
  DateTime? _selectedDate;

  DateTime get currentMonth => _currentMonth ?? DateTime.now();
  DateTime get selectedDate => _selectedDate ?? DateTime.now();

  set currentMonth(DateTime value) => _currentMonth = value;
  set selectedDate(DateTime value) => _selectedDate = value;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
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

      bottomNavigationBar: CustomBottomNavRouter(
        currentIndex: 2,
        items: UserNavItems.items,
        style: SimpleNavStyle.preset().copyWith(
          indicatorColor: AppColors.primaryRed,
        ),
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
          const Text(
            "Assignment",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.black87,
            ),
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
    List<Map<String, dynamic>> dailyData = _generateDailyData();

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
            Container(
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
    List<Map<String, dynamic>> weeklyData = _generateWeeklyData();

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          icon: Icon(Icons.chevron_left, color: AppColors.primaryBlue),
        ),
        Text(
          "${_getMonthName(currentMonth.month)} ${currentMonth.year}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
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
          icon: Icon(Icons.chevron_right, color: AppColors.primaryBlue),
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                      ),
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
      bool isSelected =
          currentDay.day == selectedDate.day &&
          currentDay.month == selectedDate.month &&
          currentDay.year == selectedDate.year;
      bool hasAssignment = _hasAssignmentOnDate(currentDay);

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
                color: isSelected
                    ? AppColors.primaryBlue
                    : hasAssignment
                    ? AppColors.errorRed
                    : AppColors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: hasAssignment && !isSelected
                    ? Border.all(color: AppColors.errorRed, width: 1)
                    : null,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.pureWhite
                        : hasAssignment
                        ? AppColors.errorRed
                        : AppColors.black87,
                    fontWeight: isSelected || hasAssignment
                        ? FontWeight.bold
                        : FontWeight.normal,
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
    List<Map<String, dynamic>> assignments = _getAssignmentsForDate(
      selectedDate,
    );

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
          child: _buildAssignmentCard(assignments[index]),
        );
      },
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentDetailPage(assignment: assignment),
          ),
        );
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
                      child: Icon(
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
    return [
      {
        'date': '15',
        'day': 'MON',
        'isActive': true,
        'assignments': [
          {
            'title': 'Loan Application Review Meeting',
            'category': 'Credit Analysis',
            'description':
                'Review and evaluate new micro-loan applications from local businesses and individuals.',
            'time': '09:00 AM - 11:00 AM',
            'priority': 'High',
            'peopleCount': '6 people',
          },
          {
            'title': 'Customer Onboarding Session',
            'category': 'Customer Service',
            'description':
                'Assist new customers with account opening and banking product orientation.',
            'time': '02:00 PM - 04:00 PM',
            'priority': 'Medium',
            'peopleCount': '3 people',
          },
        ],
      },
      {
        'date': '16',
        'day': 'TUE',
        'isActive': false,
        'assignments': [
          {
            'title': 'Monthly Risk Assessment',
            'category': 'Risk Management',
            'description':
                'Conduct monthly portfolio risk evaluation and prepare compliance reports.',
            'time': '10:00 AM - 12:00 PM',
            'priority': 'High',
            'peopleCount': '8 people',
          },
        ],
      },
      {
        'date': '17',
        'day': 'WED',
        'isActive': false,
        'assignments': [
          {
            'title': 'Financial Literacy Workshop',
            'category': 'Community Outreach',
            'description':
                'Conduct financial education workshop for local small business owners.',
            'time': '09:00 AM - 05:00 PM',
            'priority': 'Medium',
            'peopleCount': '4 people',
          },
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _generateWeeklyData() {
    return [
      {
        'date': '15',
        'day': 'MON',
        'isActive': true,
        'assignments': [
          {
            'title': 'Weekly Credit Committee Meeting',
            'category': 'Credit Management',
            'description':
                'Review loan approvals, rejections, and discuss credit policy updates.',
            'time': '09:00 AM - 11:00 AM',
            'priority': 'High',
            'peopleCount': '7 people',
          },
        ],
      },
      {
        'date': '16',
        'day': 'TUE',
        'isActive': false,
        'assignments': [
          {
            'title': 'Branch Audit Preparation',
            'category': 'Compliance',
            'description':
                'Prepare documentation and records for upcoming OJK compliance audit.',
            'time': '02:00 PM - 04:00 PM',
            'priority': 'High',
            'peopleCount': '5 people',
          },
        ],
      },
      {
        'date': '17',
        'day': 'WED',
        'isActive': false,
        'assignments': [
          {
            'title': 'Customer Relationship Management',
            'category': 'Customer Service',
            'description':
                'Visit key corporate clients to maintain business relationships and discuss new opportunities.',
            'time': '01:00 PM - 05:00 PM',
            'priority': 'Medium',
            'peopleCount': '3 people',
          },
        ],
      },
    ];
  }

  bool _hasAssignmentOnDate(DateTime date) {
    // Sample logic to check if there are assignments on a specific date
    List<int> assignmentDays = [
      5,
      12,
      15,
      18,
      22,
      28,
    ]; // Sample days with banking assignments
    return assignmentDays.contains(date.day);
  }

  List<Map<String, dynamic>> _getAssignmentsForDate(DateTime date) {
    // Sample assignments for specific dates
    if (date.day == 15) {
      return [
        {
          'title': 'Loan Portfolio Analysis',
          'category': 'Credit Analysis',
          'description':
              'Analyze current loan portfolio performance and identify potential risks.',
          'time': '10:00 AM - 12:00 PM',
          'priority': 'High',
          'peopleCount': '5 people',
        },
        {
          'title': 'New Product Training Session',
          'category': 'Training',
          'description':
              'Training on new savings product features and customer presentation techniques.',
          'time': '02:00 PM - 04:00 PM',
          'priority': 'Medium',
          'peopleCount': '8 people',
        },
      ];
    } else if (date.day == 22) {
      return [
        {
          'title': 'Monthly Financial Reporting',
          'category': 'Finance',
          'description':
              'Prepare and review monthly financial statements and regulatory reports.',
          'time': '09:00 AM - 11:00 AM',
          'priority': 'High',
          'peopleCount': '4 people',
        },
      ];
    } else if (date.day == 5) {
      return [
        {
          'title': 'Customer Service Review',
          'category': 'Customer Service',
          'description':
              'Review customer feedback and implement service improvement strategies.',
          'time': '01:00 PM - 03:00 PM',
          'priority': 'Medium',
          'peopleCount': '6 people',
        },
      ];
    } else if (date.day == 12) {
      return [
        {
          'title': 'Branch Security Assessment',
          'category': 'Security',
          'description':
              'Conduct security audit and update emergency response procedures.',
          'time': '09:00 AM - 12:00 PM',
          'priority': 'High',
          'peopleCount': '3 people',
        },
      ];
    } else if (date.day == 18) {
      return [
        {
          'title': 'Community Banking Outreach',
          'category': 'Community Relations',
          'description':
              'Visit local businesses to promote BPR services and gather market insights.',
          'time': '08:00 AM - 05:00 PM',
          'priority': 'Medium',
          'peopleCount': '4 people',
        },
      ];
    } else if (date.day == 28) {
      return [
        {
          'title': 'Regulatory Compliance Review',
          'category': 'Compliance',
          'description':
              'Review compliance with OJK regulations and prepare monthly compliance report.',
          'time': '10:00 AM - 02:00 PM',
          'priority': 'High',
          'peopleCount': '6 people',
        },
      ];
    }
    return [];
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
