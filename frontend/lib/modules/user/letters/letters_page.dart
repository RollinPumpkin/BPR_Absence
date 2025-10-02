import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';

import 'letter_form_page.dart';

class UserLettersPage extends StatefulWidget {
  const UserLettersPage({super.key});

  @override
  State<UserLettersPage> createState() => _UserLettersPageState();
}

class _UserLettersPageState extends State<UserLettersPage> {
  String selectedFilter = "Waiting approval";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildLettersList(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavRouter(
        currentIndex: 3,
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
              const Text(
                "Letter",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LetterFormPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.vibrantOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: AppColors.pureWhite,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Add Letters",
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Filter",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterTab("Waiting approval"),
              const SizedBox(width: 12),
              _buildFilterTab("Approved"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter) {
    bool isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : AppColors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.grey.shade400 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? AppColors.black87 : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLettersList() {
    List<Map<String, dynamic>> letters = _getFilteredLetters();
    
    if (letters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No letters found for "${selectedFilter}"',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        return _buildLetterCard(letters[index]);
      },
    );
  }

  Widget _buildLetterCard(Map<String, dynamic> letter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Text(
                letter['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black87,
                ),
              ),
              _buildStatusBadge(letter['type']),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            letter['date'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            letter['description'],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusIndicator(letter['status']),
              Row(
                children: [
                  Icon(
                    Icons.more_horiz,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'Waiting approval':
        statusColor = AppColors.primaryBlue;
        break;
      case 'approved':
        statusColor = AppColors.primaryGreen;
        break;
      case 'rejected':
        statusColor = AppColors.errorRed;
        break;
      default:
        statusColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredLetters() {
    List<Map<String, dynamic>> allLetters = _getAllLetters();
    
    return allLetters.where((letter) {
      return letter['status'].toLowerCase() == selectedFilter.toLowerCase();
    }).toList();
  }

  List<Map<String, dynamic>> _getAllLetters() {
    return [
      {
        'title': "DOCTOR'S NOTE",
        'date': '27 Agustus 2024',
        'description': 'Medical certificate for sick leave due to acute respiratory infection. Employee requires 3 days rest as recommended by attending physician.',
        'status': 'Waiting Approval',
        'type': 'Absence',
      },
      {
        'title': "DOCTOR'S NOTE",
        'date': '25 Agustus 2024',
        'description': 'Medical certificate for maternity check-up appointment. Regular prenatal examination scheduled with obstetrician.',
        'status': 'Approved',
        'type': 'Absence',
      },
      {
        'title': "DOCTOR'S NOTE",
        'date': '23 Agustus 2024',
        'description': 'Medical certificate for emergency dental treatment. Urgent dental procedure required due to severe tooth infection.',
        'status': 'Rejected',
        'type': 'Absence',
      },
      {
        'title': "DOCTOR'S NOTE",
        'date': '21 Agustus 2024',
        'description': 'Medical certificate for routine health check-up. Annual medical examination as required by company policy.',
        'status': 'Approved',
        'type': 'Absence',
      },
      {
        'title': "MEDICAL CERTIFICATE",
        'date': '19 Agustus 2024',
        'description': 'Medical certificate for work-related injury treatment. Follow-up treatment for workplace accident rehabilitation.',
        'status': 'Waiting Approval',
        'type': 'Absence',
      },
      {
        'title': "HEALTH CLEARANCE",
        'date': '17 Agustus 2024',
        'description': 'Medical clearance certificate for return to work after recovery from illness. Fit for duty certification.',
        'status': 'Approved',
        'type': 'Absence',
      },
    ];
  }
}