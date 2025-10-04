import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:frontend/core/constants/colors.dart';import 'package:frontend/core/constants/colors.dart';



// Employee sorting filter componentclass EmployeeFilter extends StatefulWidget {

class EmployeeFilter extends StatefulWidget {  final String currentSortBy;

  final String currentSortBy;  final Function(String) onSortChanged;

  final Function(String) onSortChanged;

  const EmployeeFilter({

  const EmployeeFilter({    super.key,

    super.key,    required this.currentSortBy,

    required this.currentSortBy,    required this.onSortChanged,

    required this.onSortChanged,  });

  });

  @override

  @override  State<EmployeeFilter> createState() => _EmployeeFilterState();

  State<EmployeeFilter> createState() => _EmployeeFilterState();}

}

class _EmployeeFilterState extends State<EmployeeFilter> {

class _EmployeeFilterState extends State<EmployeeFilter> {  String _selectedSort = '';

  String _selectedSort = '';  

    final List<Map<String, String>> _sortOptions = [

  final List<Map<String, String>> _sortOptions = [    {'value': 'full_name', 'label': 'Full Name'},

    {'value': 'full_name', 'label': 'Full Name'},    {'value': 'email', 'label': 'Email'},

    {'value': 'email', 'label': 'Email'},    {'value': 'role', 'label': 'Role'},

    {'value': 'role', 'label': 'Role'},    {'value': 'department', 'label': 'Department'},

    {'value': 'department', 'label': 'Department'},    {'value': 'position', 'label': 'Position'},

    {'value': 'position', 'label': 'Position'},    {'value': 'phone', 'label': 'Phone'},

    {'value': 'phone', 'label': 'Phone'},    {'value': 'place_of_birth', 'label': 'Place of Birth'},

    {'value': 'place_of_birth', 'label': 'Place of Birth'},    {'value': 'nik', 'label': 'NIK'},

    {'value': 'nik', 'label': 'NIK'},    {'value': 'division_detail', 'label': 'Division Detail'},

    {'value': 'division_detail', 'label': 'Division Detail'},    {'value': 'account_number', 'label': 'Account Number'},

    {'value': 'account_number', 'label': 'Account Number'},    {'value': 'account_holder_name', 'label': 'Account Holder Name'},

    {'value': 'account_holder_name', 'label': 'Account Holder Name'},    {'value': 'gender', 'label': 'Gender'},

    {'value': 'gender', 'label': 'Gender'},    {'value': 'contract_type', 'label': 'Contract Type'},

    {'value': 'contract_type', 'label': 'Contract Type'},    {'value': 'bank', 'label': 'Bank'},

    {'value': 'bank', 'label': 'Bank'},    {'value': 'education', 'label': 'Education'},

    {'value': 'education', 'label': 'Education'},    {'value': 'date_of_birth', 'label': 'Date of Birth'},

    {'value': 'date_of_birth', 'label': 'Date of Birth'},  ];

  ];

  @override

  @override  void initState() {

  void initState() {    super.initState();

    super.initState();    _selectedSort = widget.currentSortBy;

    _selectedSort = widget.currentSortBy;  }

  }

  void _applySorting() {

  void _applySorting() {    widget.onSortChanged(_selectedSort);

    widget.onSortChanged(_selectedSort);    Navigator.of(context).pop();

    Navigator.of(context).pop();  }

  }

  @override

  @override  Widget build(BuildContext context) {

  Widget build(BuildContext context) {    return Dialog(

    return Dialog(      shape: RoundedRectangleBorder(

      shape: RoundedRectangleBorder(        borderRadius: BorderRadius.circular(16),

        borderRadius: BorderRadius.circular(16),      ),

      ),      child: Container(

      child: Container(        width: MediaQuery.of(context).size.width * 0.8,

        width: MediaQuery.of(context).size.width * 0.8,        padding: const EdgeInsets.all(20),

        padding: const EdgeInsets.all(20),        child: Column(

        child: Column(          mainAxisSize: MainAxisSize.min,

          mainAxisSize: MainAxisSize.min,          crossAxisAlignment: CrossAxisAlignment.start,

          crossAxisAlignment: CrossAxisAlignment.start,          children: [

          children: [            // Header

            // Header            Row(

            Row(              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              mainAxisAlignment: MainAxisAlignment.spaceBetween,              children: [

              children: [                const Text(

                const Text(                  'Sort Employees By',

                  'Sort Employees By',                  style: TextStyle(

                  style: TextStyle(                    fontSize: 20,

                    fontSize: 20,                    fontWeight: FontWeight.bold,

                    fontWeight: FontWeight.bold,                    color: AppColors.neutral800,

                    color: AppColors.neutral800,                  ),

                  ),                ),

                ),                IconButton(

                IconButton(                  icon: const Icon(Icons.close),

                  icon: const Icon(Icons.close),                  onPressed: () => Navigator.of(context).pop(),

                  onPressed: () => Navigator.of(context).pop(),                ),

                ),              ],

              ],            ),

            ),            const SizedBox(height: 20),

            const SizedBox(height: 20),

            // Sort Options

            // Sort Options            const Text(

            const Text(              'Choose field to sort by:',

              'Choose field to sort by:',              style: TextStyle(

              style: TextStyle(                fontSize: 16,

                fontSize: 16,                fontWeight: FontWeight.w500,

                fontWeight: FontWeight.w500,                color: AppColors.neutral800,

                color: AppColors.neutral800,              ),

              ),            ),

            ),            const SizedBox(height: 12),

            const SizedBox(height: 12),

            // Dropdown

            // Dropdown            Container(

            Container(              width: double.infinity,

              width: double.infinity,              padding: const EdgeInsets.symmetric(horizontal: 12),

              padding: const EdgeInsets.symmetric(horizontal: 12),              decoration: BoxDecoration(

              decoration: BoxDecoration(                border: Border.all(color: AppColors.neutral300),

                border: Border.all(color: AppColors.neutral300),                borderRadius: BorderRadius.circular(8),

                borderRadius: BorderRadius.circular(8),              ),

              ),              child: DropdownButtonHideUnderline(

              child: DropdownButtonHideUnderline(                child: DropdownButton<String>(

                child: DropdownButton<String>(                  value: _selectedSort.isEmpty ? null : _selectedSort,

                  value: _selectedSort.isEmpty ? null : _selectedSort,                  hint: const Text('Select sorting field'),

                  hint: const Text('Select sorting field'),                  isExpanded: true,

                  isExpanded: true,                  items: [

                  items: [                    const DropdownMenuItem<String>(

                    const DropdownMenuItem<String>(                      value: '',

                      value: '',                      child: Text('Default (Created Date)'),

                      child: Text('Default (Created Date)'),                    ),

                    ),                    ..._sortOptions.map((option) => DropdownMenuItem<String>(

                    ..._sortOptions.map((option) => DropdownMenuItem<String>(                      value: option['value'],

                      value: option['value'],                      child: Text(option['label']!),

                      child: Text(option['label']!),                    )),

                    )),                  ],

                  ],                  onChanged: (String? value) {

                  onChanged: (String? value) {                    setState(() {

                    setState(() {                      _selectedSort = value ?? '';

                      _selectedSort = value ?? '';                    });

                    });                  },

                  },                ),

                ),              ),

              ),            ),

            ),

            const SizedBox(height: 24),

            const SizedBox(height: 24),

            // Action Buttons

            // Action Buttons            Row(

            Row(              children: [

              children: [                Expanded(

                Expanded(                  child: OutlinedButton(

                  child: OutlinedButton(                    onPressed: () => Navigator.of(context).pop(),

                    onPressed: () => Navigator.of(context).pop(),                    style: OutlinedButton.styleFrom(

                    style: OutlinedButton.styleFrom(                      side: const BorderSide(color: AppColors.neutral300),

                      side: const BorderSide(color: AppColors.neutral300),                      padding: const EdgeInsets.symmetric(vertical: 12),

                      padding: const EdgeInsets.symmetric(vertical: 12),                      shape: RoundedRectangleBorder(

                      shape: RoundedRectangleBorder(                        borderRadius: BorderRadius.circular(8),

                        borderRadius: BorderRadius.circular(8),                      ),

                      ),                    ),

                    ),                    child: const Text(

                    child: const Text(                      'Cancel',

                      'Cancel',                      style: TextStyle(color: AppColors.neutral500),

                      style: TextStyle(color: AppColors.neutral500),                    ),

                    ),                  ),

                  ),                ),

                ),                const SizedBox(width: 12),

                const SizedBox(width: 12),                Expanded(

                Expanded(                  child: ElevatedButton(

                  child: ElevatedButton(                    onPressed: _applySorting,

                    onPressed: _applySorting,                    style: ElevatedButton.styleFrom(

                    style: ElevatedButton.styleFrom(                      backgroundColor: AppColors.primaryBlue,

                      backgroundColor: AppColors.primaryBlue,                      padding: const EdgeInsets.symmetric(vertical: 12),

                      padding: const EdgeInsets.symmetric(vertical: 12),                      shape: RoundedRectangleBorder(

                      shape: RoundedRectangleBorder(                        borderRadius: BorderRadius.circular(8),

                        borderRadius: BorderRadius.circular(8),                      ),

                      ),                    ),

                    ),                    child: const Text(

                    child: const Text(                      'Apply Sort',

                      'Apply Sort',                      style: TextStyle(color: AppColors.pureWhite),

                      style: TextStyle(color: AppColors.pureWhite),                    ),

                    ),                  ),

                  ),                ),

                ),              ],

              ],            ),

            ),          ],

          ],        ),

        ),      ),

      ),    );

    );  }

  }}
}