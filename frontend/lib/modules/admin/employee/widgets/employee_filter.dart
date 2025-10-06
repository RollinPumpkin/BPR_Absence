import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

// Employee sorting filter component
class EmployeeFilter extends StatefulWidget {
  final String currentSortBy;
  final Function(String) onSortChanged;

  const EmployeeFilter({
    super.key,
    required this.currentSortBy,
    required this.onSortChanged,
  });

  @override
  State<EmployeeFilter> createState() => _EmployeeFilterState();
}

class _EmployeeFilterState extends State<EmployeeFilter> {
  String _selectedSort = '';
  
  final List<Map<String, String>> _sortOptions = [
    {'value': 'full_name', 'label': 'Full Name'},
    {'value': 'email', 'label': 'Email'},
    {'value': 'role', 'label': 'Role'},
    {'value': 'department', 'label': 'Department'},
    {'value': 'position', 'label': 'Position'},
    {'value': 'phone', 'label': 'Phone'},
    {'value': 'place_of_birth', 'label': 'Place of Birth'},
    {'value': 'nik', 'label': 'NIK'},
    {'value': 'division_detail', 'label': 'Division Detail'},
    {'value': 'account_number', 'label': 'Account Number'},
    {'value': 'account_holder_name', 'label': 'Account Holder Name'},
    {'value': 'gender', 'label': 'Gender'},
    {'value': 'contract_type', 'label': 'Contract Type'},
    {'value': 'bank', 'label': 'Bank'},
    {'value': 'education', 'label': 'Education'},
    {'value': 'date_of_birth', 'label': 'Date of Birth'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSortBy;
  }

  void _applySorting() {
    widget.onSortChanged(_selectedSort);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort Employees By',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sort Options
            const Text(
              'Choose field to sort by:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral800,
              ),
            ),
            const SizedBox(height: 12),

            // Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSort.isEmpty ? null : _selectedSort,
                  hint: const Text('Select sorting field'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Default (Created Date)'),
                    ),
                    ..._sortOptions.map((option) => DropdownMenuItem<String>(
                      value: option['value'],
                      child: Text(option['label']!),
                    )),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedSort = value ?? '';
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.neutral300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.neutral500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applySorting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Apply Sort',
                      style: TextStyle(color: AppColors.pureWhite),
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
}