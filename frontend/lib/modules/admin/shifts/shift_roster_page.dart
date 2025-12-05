import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/shift_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:intl/intl.dart';

class ShiftRosterPage extends StatefulWidget {
  const ShiftRosterPage({super.key});

  @override
  State<ShiftRosterPage> createState() => _ShiftRosterPageState();
}

class _ShiftRosterPageState extends State<ShiftRosterPage> {
  final ShiftService _shiftService = ShiftService();
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _securityEmployees = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    await Future.wait([
      _loadAssignments(),
      _loadSecurityEmployees(),
    ]);
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadAssignments() async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await _shiftService.getAssignments(
        startDate: dateStr,
        endDate: dateStr,
      );

      if (response.success && response.data != null) {
        setState(() {
          _assignments = List<Map<String, dynamic>>.from(response.data ?? []);
        });
      }
    } catch (e) {
      print('Error loading assignments: $e');
    }
  }

  Future<void> _loadSecurityEmployees() async {
    try {
      // Load actual security employees from API
      final userService = UserService();
      final response = await userService.getUsersByRole('security');

      if (response.success && response.data != null) {
        final users = response.data?.items ?? [];
        setState(() {
          _securityEmployees = users.map((user) {
            return {
              'id': user.employeeId,
              'name': user.fullName,
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading security employees: $e');
      // Fallback to mock data if API fails
      setState(() {
        _securityEmployees = [
          {'id': 'SC001', 'name': 'Security 1'},
          {'id': 'SC002', 'name': 'Security 2'},
          {'id': 'SC003', 'name': 'Security 3'},
        ];
      });
    }
  }

  Future<void> _assignShift(String employeeId, String employeeName, String shiftType) async {
    try {
      setState(() => _isLoading = true);

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      final shiftTimes = shiftType == 'morning'
          ? {'start': '06:00', 'end': '14:00'}
          : {'start': '18:00', 'end': '02:00'};

      final response = await _shiftService.createAssignment(
        date: dateStr,
        employeeId: employeeId,
        employeeName: employeeName,
        role: 'security',
        shiftType: shiftType,
        shiftStartTime: shiftTimes['start']!,
        shiftEndTime: shiftTimes['end']!,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shift assigned successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        await _loadAssignments();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign shift: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? _getAssignment(String employeeId, String shiftType) {
    try {
      return _assignments.firstWhere(
        (a) => a['employee_id'] == employeeId && a['shift_type'] == shiftType,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Shift Roster Management'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.pureWhite,
      ),
      body: Column(
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.pureWhite,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    });
                    _loadAssignments();
                  },
                ),
                Expanded(
                  child: Center(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                          _loadAssignments();
                        }
                      },
                      child: Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                    _loadAssignments();
                  },
                ),
              ],
            ),
          ),

          // Shift Assignment Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Morning Shift Section
                        _buildShiftSection(
                          'Shift Pagi (06:00 - 14:00)',
                          'morning',
                          Colors.orange,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Evening Shift Section
                        _buildShiftSection(
                          'Shift Malam (18:00 - 02:00)',
                          'evening',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftSection(String title, String shiftType, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Employee List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _securityEmployees.map((employee) {
                final assignment = _getAssignment(employee['id'], shiftType);
                final isAssigned = assignment != null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isAssigned ? color : AppColors.dividerGray,
                        width: isAssigned ? 2 : 1,
                      ),
                    ),
                    tileColor: isAssigned ? color.withOpacity(0.05) : null,
                    leading: CircleAvatar(
                      backgroundColor: isAssigned ? color : Colors.grey.shade300,
                      child: Text(
                        employee['id'].substring(2),
                        style: TextStyle(
                          color: isAssigned ? AppColors.pureWhite : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      employee['name'],
                      style: TextStyle(
                        fontWeight: isAssigned ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      employee['id'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: isAssigned
                        ? Chip(
                            label: const Text(
                              'Assigned',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.pureWhite,
                              ),
                            ),
                            backgroundColor: color,
                            deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.pureWhite),
                            onDeleted: () async {
                              final assignmentId = assignment['id'];
                              if (assignmentId != null) {
                                try {
                                  final response = await _shiftService.deleteAssignment(assignmentId);
                                  if (response.success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Shift unassigned successfully'),
                                        backgroundColor: AppColors.primaryGreen,
                                      ),
                                    );
                                    await _loadAssignments();
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to unassign: $e'),
                                      backgroundColor: AppColors.errorRed,
                                    ),
                                  );
                                }
                              }
                            },
                          )
                        : ElevatedButton(
                            onPressed: () => _assignShift(
                              employee['id'],
                              employee['name'],
                              shiftType,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: AppColors.pureWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text('Assign'),
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
