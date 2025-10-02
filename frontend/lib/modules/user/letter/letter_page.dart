import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';

import 'widgets/letter_type_card.dart';
import 'widgets/my_letter_card.dart';

class UserLetterPage extends StatefulWidget {
  const UserLetterPage({super.key});

  @override
  State<UserLetterPage> createState() => _UserLetterPageState();
}

class _UserLetterPageState extends State<UserLetterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text(
          "Letters",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.black,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Submit Letter"),
            Tab(text: "My Letters"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Submit Letter Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose Letter Type",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                const LetterTypeCard(
                  title: "Leave Request",
                  description: "Request for annual leave, sick leave, or personal leave",
                  icon: Icons.event_available,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 12),

                const LetterTypeCard(
                  title: "Permission Letter",
                  description: "Request permission to leave during work hours",
                  icon: Icons.schedule,
                  color: AppColors.vibrantOrange,
                ),
                const SizedBox(height: 12),

                const LetterTypeCard(
                  title: "Overtime Request",
                  description: "Request for overtime work authorization",
                  icon: Icons.access_time,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 12),

                const LetterTypeCard(
                  title: "Other Request",
                  description: "General request or complaint letter",
                  icon: Icons.mail,
                  color: Colors.purple,
                ),
              ],
            ),
          ),

          // My Letters Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return MyLetterCard(
                      title: _getLetterTitle(index),
                      type: _getLetterType(index),
                      date: _getLetterDate(index),
                      status: _getLetterStatus(index),
                      statusColor: _getLetterStatusColor(index),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: CustomBottomNavRouter(
        currentIndex: 3,
        items: UserNavItems.items,
      ),
    );
  }

  String _getLetterTitle(int index) {
    final titles = [
      "Annual Leave Request",
      "Permission to Leave Early",
      "Sick Leave",
      "Overtime Request",
      "Medical Checkup Permission",
    ];
    return titles[index % titles.length];
  }

  String _getLetterType(int index) {
    final types = ["Leave", "Permission", "Leave", "Overtime", "Permission"];
    return types[index % types.length];
  }

  String _getLetterDate(int index) {
    final dates = [
      "Jan 15, 2025",
      "Jan 12, 2025", 
      "Jan 10, 2025",
      "Jan 8, 2025",
      "Jan 5, 2025",
    ];
    return dates[index % dates.length];
  }

  String _getLetterStatus(int index) {
    final statuses = ["Approved", "Pending", "Approved", "Rejected", "Pending"];
    return statuses[index % statuses.length];
  }

  Color _getLetterStatusColor(int index) {
    final colors = [AppColors.primaryGreen, AppColors.vibrantOrange, AppColors.primaryGreen, AppColors.errorRed, AppColors.vibrantOrange];
    return colors[index % colors.length];
  }
}
