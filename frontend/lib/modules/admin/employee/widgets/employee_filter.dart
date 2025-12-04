import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/providers/user_provider.dart';

class EmployeeFilter extends StatefulWidget {
  const EmployeeFilter({super.key});

  @override
  State<EmployeeFilter> createState() => _EmployeeFilterState();
}

class _EmployeeFilterState extends State<EmployeeFilter> {
  String? _selectedRole;
  bool _showNewDataOnly = false;
  
  final List<String> _roleOptions = [
    'admin',
    'super_admin',
    'hr',
    'manager',
    'employee',
    'account_officer',
    'security',
    'office_boy',
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _selectedRole = userProvider.roleFilter;
    _showNewDataOnly = userProvider.showNewDataOnly;
  }

  void _applyFilters() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.filterByRole(_selectedRole);
    await userProvider.filterByNewData(_showNewDataOnly);
    if (mounted) Navigator.of(context).pop();
  }

  void _clearFilters() async {
    setState(() {
      _selectedRole = null;
      _showNewDataOnly = false;
    });
    final userProvider = context.read<UserProvider>();
    await userProvider.clearFilters();
    if (mounted) Navigator.of(context).pop();
  }

  String _formatRoleName(String role) {
    return role.split('_').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Employees', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.neutral800)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Filter by Role:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.neutral800)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: AppColors.neutral300), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    hint: const Text('All Roles'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('All Roles')),
                      ..._roleOptions.map((role) => DropdownMenuItem<String>(value: role, child: Text(_formatRoleName(role)))),
                    ],
                    onChanged: (String? value) => setState(() => _selectedRole = value),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(border: Border.all(color: AppColors.neutral300), borderRadius: BorderRadius.circular(8)),
                child: CheckboxListTile(
                  title: const Text('Show New Data Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Data created in the last 7 days', style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                  value: _showNewDataOnly,
                  onChanged: (bool? value) => setState(() => _showNewDataOnly = value ?? false),
                  activeColor: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.neutral300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Clear Filters', style: TextStyle(color: AppColors.neutral500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
