import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/user/shared/user_nav_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'letter_form_page.dart';

class UserLettersPage extends StatefulWidget {
  const UserLettersPage({super.key});

  @override
  State<UserLettersPage> createState() => _UserLettersPageState();
}

class _UserLettersPageState extends State<UserLettersPage> {
  String selectedFilter = "Waiting approval";
  List<Map<String, dynamic>> _letters = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadLetters();
  }
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
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LetterFormPage(),
                    ),
                  );
                  
                  // Refresh data if letter was submitted successfully
                  if (result == true) {
                    print('🔍 Debug: Letter submitted successfully, refreshing data...');
                    print('🔍 Debug: Current selected filter: $selectedFilter');
                    
                    // Show loading state and refresh data
                    setState(() {
                      _isLoading = true;
                    });
                    
                    // Small delay to ensure Firestore has processed the new data
                    await Future.delayed(Duration(milliseconds: 500));
                    await _loadLetters();
                    
                    print('🔍 Debug: Refresh completed, total letters loaded: ${_letters.length}');
                  } else {
                    print('🔍 Debug: Navigation result was not true: $result');
                  }
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
              const SizedBox(width: 12),
              _buildFilterTab("Rejected"),
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
        _loadLetters(); // Reload letters when filter changes
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLetters,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLetters,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadLetters,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: letters.length,
        itemBuilder: (context, index) {
          return _buildLetterCard(letters[index]);
        },
      ),
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
      case 'waiting approval':
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

  Future<void> _loadLetters() async {
    print('🔍 Debug: === Starting _loadLetters() ===');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get current user info from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      final userId = prefs.getString('user_id');
      final employeeId = prefs.getString('employee_id');
      
      print('🔍 Debug: Loading letters for user...');
      print('🔍 Debug: User Email: $userEmail');
      print('🔍 Debug: User ID: $userId');
      print('🔍 Debug: Employee ID: $employeeId');
      print('🔍 Debug: Selected Filter: $selectedFilter');
      
      if (userId == null && employeeId == null && userEmail == null) {
        throw Exception('User info not found. Please log in again.');
      }
      
      // Try multiple approaches to get letters
      List<Map<String, dynamic>> letters = [];
      
      // First, let's check what's actually in Firestore
      print('🔍 Debug: === Checking all letters in Firestore ===');
      final allLettersSnapshot = await FirebaseFirestore.instance
          .collection('letters')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      
      print('🔍 Debug: Found ${allLettersSnapshot.docs.length} total letters in Firestore:');
      for (var doc in allLettersSnapshot.docs) {
        final data = doc.data();
        print('  - ID: ${doc.id}');
        print('    Subject: ${data['subject']}');
        print('    user_id: ${data['user_id']}');
        print('    recipientId: ${data['recipientId']}');
        print('    recipientEmployeeId: ${data['recipientEmployeeId']}');
        print('    recipientEmail: ${data['recipientEmail']}');
        print('    status: ${data['status']}');
        print('    createdAt: ${data['createdAt']}');
        print('---');
      }
      
      // Approach 1: Try by employeeId first (most specific)
      if (employeeId != null) {
        print('🔍 Debug: Trying to fetch by employeeId...');
        letters = await _getLettersByEmployeeId(employeeId);
        print('🔍 Debug: Found ${letters.length} letters by employee ID');
      }
      
      // Approach 2: Try by userId if no results
      if (letters.isEmpty && userId != null) {
        print('🔍 Debug: Trying to fetch by userId...');
        letters = await _getLettersByUserId(userId);
        print('🔍 Debug: Found ${letters.length} letters by user ID');
      }
      
      // Approach 3: Try by email if still no results
      if (letters.isEmpty && userEmail != null) {
        print('🔍 Debug: Trying to fetch by email...');
        letters = await _getLettersByEmail(userEmail);
        print('🔍 Debug: Found ${letters.length} letters by email');
      }
      
      // Approach 3.5: Try by user_id field (new submission format)
      if (letters.isEmpty && (employeeId != null || userId != null)) {
        final searchId = employeeId ?? userId;
        print('🔍 Debug: Trying to fetch by user_id field: $searchId');
        letters = await _getLettersByUserIdField(searchId!);
        print('🔍 Debug: Found ${letters.length} letters by user_id field');
      }
      
      // Approach 4: If still no results, try to get all letters and filter
      if (letters.isEmpty) {
        print('🔍 Debug: Trying to fetch all letters and filter...');
        letters = await _getAllLettersAndFilter(userEmail, userId, employeeId);
        print('🔍 Debug: Found ${letters.length} letters after filtering all');
      }
      
      print('🔍 Debug: Final result - Found ${letters.length} letters');
      
      setState(() {
        _letters = letters;
        _isLoading = false;
      });
      
      print('🔍 Debug: Successfully loaded ${letters.length} letters');
      for (var letter in letters) {
        print('  - ${letter['title']} (${letter['status']})');
      }
      
      // Debug: Check what's in the current filter
      print('🔍 Debug: Current filter: $selectedFilter');
      final filteredCount = _getFilteredLetters().length;
      print('🔍 Debug: Filtered letters count: $filteredCount');
    } catch (e) {
      print('🔍 Debug: Error loading letters: $e');
      setState(() {
        _error = 'Error loading letters: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getLettersByEmployeeId(String employeeId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('letters')
          .where('recipientEmployeeId', isEqualTo: employeeId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return _convertFirestoreDataToLetter(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error fetching letters by employee ID: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getLettersByUserId(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('letters')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return _convertFirestoreDataToLetter(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error fetching letters by user ID: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getLettersByEmail(String email) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('letters')
          .where('recipientEmail', isEqualTo: email)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return _convertFirestoreDataToLetter(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error fetching letters by email: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getLettersByUserIdField(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('letters')
          .where('user_id', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('🔍 Debug: Query by user_id="$userId" returned ${querySnapshot.docs.length} documents');
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('🔍 Debug: Found letter: ${data['subject']} with user_id: ${data['user_id']}');
        return _convertFirestoreDataToLetter(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error fetching letters by user_id field: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getAllLettersAndFilter(String? email, String? userId, String? employeeId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('letters')
          .orderBy('createdAt', descending: true)
          .limit(100) // Limit to avoid too much data
          .get();

      print('🔍 Debug: Fetched ${querySnapshot.docs.length} total letters');
      
      final allLetters = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('🔍 Debug: Letter ${doc.id} - recipientEmail: ${data['recipientEmail']}, recipientId: ${data['recipientId']}, employeeId: ${data['recipientEmployeeId']}');
        return _convertFirestoreDataToLetter(doc.id, data);
      }).toList();

      // Filter manually
      final filteredLetters = allLetters.where((letter) {
        return (employeeId != null && letter['employeeId'] == employeeId) ||
               (userId != null && letter['userId'] == userId) ||
               (email != null && letter['email'] == email);
      }).toList();

      print('🔍 Debug: After manual filtering: ${filteredLetters.length} letters');
      return filteredLetters;
    } catch (e) {
      print('Error fetching and filtering all letters: $e');
      return [];
    }
  }

  Map<String, dynamic> _convertFirestoreDataToLetter(String docId, Map<String, dynamic> data) {
    // Convert Firestore timestamp to formatted date
    String formattedDate = 'No date';
    if (data['createdAt'] != null) {
      try {
        Timestamp timestamp = data['createdAt'] as Timestamp;
        DateTime dateTime = timestamp.toDate();
        formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    // Map status values
    String status = data['status'] ?? 'waiting_approval';
    print('🔍 Debug: Converting letter ${data['subject']} - Original status: ${data['status']}, Mapped status: $status');
    
    if (status == 'waiting_approval') {
      status = 'Waiting Approval';
    } else if (status == 'approved') {
      status = 'Approved';
    } else if (status == 'rejected') {
      status = 'Rejected';
    }

    final convertedLetter = {
      'id': docId,
      'title': data['subject'] ?? 'No Subject',
      'date': formattedDate,
      'description': data['content'] ?? 'No Content',
      'status': status,
      'type': data['letterType'] ?? 'Letter',
      'userId': data['recipientId'],
      'email': data['recipientEmail'],
      'employeeId': data['recipientEmployeeId'],
    };
    
    print('🔍 Debug: Converted letter: ${convertedLetter['title']} - Final status: ${convertedLetter['status']}');
    return convertedLetter;
  }

  List<Map<String, dynamic>> _getFilteredLetters() {
    print('🔍 Debug: Filtering ${_letters.length} letters with filter: "$selectedFilter"');
    
    final filtered = _letters.where((letter) {
      final letterStatus = letter['status'].toLowerCase();
      final filterStatus = selectedFilter.toLowerCase();
      final matches = letterStatus == filterStatus;
      
      print('🔍 Debug: Letter "${letter['title']}" status "$letterStatus" matches filter "$filterStatus": $matches');
      return matches;
    }).toList();
    
    print('🔍 Debug: Filter result: ${filtered.length} letters match');
    return filtered;
  }

  List<Map<String, dynamic>> _getAllLetters() {
    return _letters; // Return the loaded letters from Firestore
  }
}