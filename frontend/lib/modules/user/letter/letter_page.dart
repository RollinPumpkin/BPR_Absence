import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firestore_letter_service.dart';
import '../../../core/services/user_context_service.dart';
import '../../../data/providers/auth_provider.dart';

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
  final UserContextService _userContext = UserContextService();
  List<LetterModel> letters = [];
  bool isLoading = true;
  String selectedFilter = 'Waiting approval';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize user context first, then load letters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      _userContext.initialize(authProvider);
      _loadLetters();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLetters() async {
    if (!_userContext.isLoggedIn) {
      print('⚠️ User not logged in, cannot load letters');
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      print('[LetterPage] Loading letters for user: ${_userContext.currentUserName} (${_userContext.currentUserId})');
      
      // Load letters for current user only
      final allLetters = await FirestoreLetterService.getLetters(userId: _userContext.currentUserId);
      
      if (mounted) {
        setState(() {
          letters = allLetters;
          isLoading = false;
        });
      }
      
      print('[LetterPage] Loaded ${letters.length} letters for current user from Firestore');
      
      // Debug: Print letter details
      for (var letter in letters) {
        print('[LetterPage] Letter: ${letter.subject} - Status: ${letter.status} - Recipient: ${letter.recipientId}');
      }
      
    } catch (e) {
      print('[LetterPage] Error loading letters: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load letters: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  List<LetterModel> get filteredLetters {
    switch (selectedFilter) {
      case 'Waiting approval':
        return letters.where((letter) => letter.status == 'waiting_approval').toList();
      case 'Approved':
        return letters.where((letter) => letter.status == 'approved').toList();
      case 'Rejected':
        return letters.where((letter) => letter.status == 'rejected').toList();
      default:
        return letters;
    }
  }

  // Add a method to refresh letters when user returns from adding a letter
  Future<void> _refreshLetters() async {
    await _loadLetters();
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
                Text(
                  "Choose Letter Type",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 16),

                LetterTypeCard(
                  title: "Leave Request",
                  description: "Request for annual leave, sick leave, or personal leave",
                  icon: Icons.event_available,
                  color: AppColors.primaryGreen,
                  onFormComplete: _refreshLetters,
                ),
                const SizedBox(height: 12),

                LetterTypeCard(
                  title: "Permission Letter",
                  description: "Request permission to leave during work hours",
                  icon: Icons.schedule,
                  color: AppColors.vibrantOrange,
                  onFormComplete: _refreshLetters,
                ),
                const SizedBox(height: 12),

                LetterTypeCard(
                  title: "Overtime Request",
                  description: "Request for overtime work authorization",
                  icon: Icons.access_time,
                  color: AppColors.primaryBlue,
                  onFormComplete: _refreshLetters,
                ),
                const SizedBox(height: 12),

                LetterTypeCard(
                  title: "Other Request",
                  description: "General request or complaint letter",
                  icon: Icons.mail,
                  color: Colors.purple,
                  onFormComplete: _refreshLetters,
                ),
              ],
            ),
          ),

          // My Letters Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Filter buttons
                Row(
                  children: [
                    _buildFilterButton('Waiting approval'),
                    const SizedBox(width: 8),
                    _buildFilterButton('Approved'),
                    const SizedBox(width: 8),
                    _buildFilterButton('Rejected'),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Letters list
                isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : filteredLetters.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No letters found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredLetters.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final letter = filteredLetters[index];
                              return MyLetterCard(
                                title: letter.subject,
                                type: letter.letterType,
                                date: _formatDate(letter.createdAt),
                                status: _getStatusText(letter.status),
                                statusColor: _getStatusColor(letter.status),
                                onTap: () => _showLetterDetail(letter),
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: const CustomBottomNavRouter(
        currentIndex: 3,
        items: UserNavItems.items,
      ),
    );
  }

  Widget _buildFilterButton(String filter) {
    final isSelected = selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            filter,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'waiting_approval':
        return 'Waiting Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting_approval':
        return AppColors.primaryYellow;
      case 'approved':
        return AppColors.primaryGreen;
      case 'rejected':
        return AppColors.errorRed;
      default:
        return Colors.grey;
    }
  }

  void _showLetterDetail(LetterModel letter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(letter.subject),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Letter Number', letter.letterNumber),
              _buildDetailRow('Type', letter.letterType),
              _buildDetailRow('Status', _getStatusText(letter.status)),
              _buildDetailRow('Date', _formatDate(letter.createdAt)),
              _buildDetailRow('Sender', letter.senderName),
              const SizedBox(height: 12),
              const Text(
                'Content:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(letter.content),
              if (letter.approvalHistory.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'History:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...letter.approvalHistory.map(
                  (history) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${_formatDate(history.timestamp)}: ${history.action} by ${history.userName}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
