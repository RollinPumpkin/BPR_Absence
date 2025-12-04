import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/data/models/user.dart';
import 'add_assignment_step3_page.dart';
import 'stepper_widgets.dart';
import '../models/assignment_draft.dart';

// Simple class to hold employee info for assignment
class SelectedEmployee {
  final String id;
  final String name;
  final String? position;
  final String? department;

  SelectedEmployee({
    required this.id,
    required this.name,
    this.position,
    this.department,
  });
}

class AddAssignmentStep2Page extends StatefulWidget {
  final AssignmentDraft draft;
  
  const AddAssignmentStep2Page({super.key, required this.draft});

  @override
  State<AddAssignmentStep2Page> createState() => _AddAssignmentStep2PageState();
}

class _AddAssignmentStep2PageState extends State<AddAssignmentStep2Page> {
  final UserService _userService = UserService();
  
  List<User> _allEmployees = [];
  List<User> _filteredEmployees = [];
  final Map<String, SelectedEmployee> _selectedEmployees = {}; // Changed to Map
  
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('📋 Loading employees for assignment...');
      
      // Fetch all active users (exclude super_admin for assignment)
      final response = await _userService.getAllUsers(
        limit: 100, // Get more users at once
        isActive: true,
      );

      if (response.success && response.data != null) {
        final users = response.data!.items;
        
        // Filter out super_admin and only show employees
        final employees = users.where((user) => 
          user.role != 'super_admin' && 
          user.isActive
        ).toList();
        
        // Sort by name
        employees.sort((a, b) => a.fullName.compareTo(b.fullName));
        
        print('✅ Loaded ${employees.length} active employees');
        
        setState(() {
          _allEmployees = employees;
          _filteredEmployees = employees;
          _isLoading = false;
        });
      } else {
        throw Exception(response.message ?? 'Failed to load employees');
      }
      
    } catch (e) {
      print('❌ Error loading employees: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = _allEmployees;
      } else {
        _filteredEmployees = _allEmployees.where((employee) {
          return employee.fullName.toLowerCase().contains(query) ||
                 employee.employeeId.toLowerCase().contains(query) ||
                 (employee.department?.toLowerCase().contains(query) ?? false) ||
                 (employee.position?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _toggleEmployee(User employee) {
    setState(() {
      if (_selectedEmployees.containsKey(employee.id)) {
        _selectedEmployees.remove(employee.id);
      } else {
        _selectedEmployees[employee.id] = SelectedEmployee(
          id: employee.id,
          name: employee.fullName,
          position: employee.position,
          department: employee.department,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assignment - Select Employees"),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.black,
      ),
      body: Column(
        children: [
          // 🔹 Stepper Indicator
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StepCircle(number: "1", isActive: false),
                StepLine(),
                StepCircle(number: "2", isActive: true),
                StepLine(),
                StepCircle(number: "3", isActive: false),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                        ),
                        SizedBox(height: 16),
                        Text('Loading employees...'),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.errorRed,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load employees',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.neutral500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadEmployees,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: AppColors.pureWhite,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selected count indicator
                            if (_selectedEmployees.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryGreen.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primaryGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedEmployees.length} employee(s) selected',
                                      style: const TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),

                            // Search Bar
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: "Search by name, ID, department, position...",
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Employee count
                            Text(
                              '${_filteredEmployees.length} employee(s) available',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.neutral500,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Employee List
                            Expanded(
                              child: _filteredEmployees.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No employees found',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try a different search term',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _filteredEmployees.length,
                                      itemBuilder: (context, index) {
                                        final employee = _filteredEmployees[index];
                                        final isSelected = _selectedEmployees.containsKey(employee.id);

                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: isSelected
                                                ? const BorderSide(
                                                    color: AppColors.primaryGreen,
                                                    width: 2,
                                                  )
                                                : BorderSide.none,
                                          ),
                                          elevation: isSelected ? 3 : 1,
                                          margin: const EdgeInsets.symmetric(vertical: 6),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isSelected 
                                                  ? AppColors.primaryGreen 
                                                  : Colors.grey[400],
                                              child: Text(
                                                employee.fullName.isNotEmpty 
                                                    ? employee.fullName[0].toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: AppColors.pureWhite,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              employee.fullName,
                                              style: TextStyle(
                                                fontWeight: isSelected 
                                                    ? FontWeight.w600 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  employee.position ?? 'No Position',
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                                Text(
                                                  employee.department ?? 'No Department',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: Checkbox(
                                              value: isSelected,
                                              activeColor: AppColors.primaryGreen,
                                              onChanged: (val) {
                                                _toggleEmployee(employee);
                                              },
                                            ),
                                            onTap: () {
                                              _toggleEmployee(employee);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
          ),

          // 🔹 Tombol
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      side: const BorderSide(color: AppColors.black),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.pureWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (_selectedEmployees.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select at least one employee")),
                        );
                        return;
                      }
                      
                      // Convert employee data to lists for Step 3
                      // Pass only user IDs to Step 3 for backend
                      final selectedUserIds = _selectedEmployees.keys.toList();
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddAssignmentStep3Page(
                            draft: widget.draft,
                            employees: selectedUserIds,
                            employeeNames: _selectedEmployees.values.map((e) => e.name).toList(),
                          ),
                        ),
                      );
                    },
                    child: Text("Next (${_selectedEmployees.length})"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
