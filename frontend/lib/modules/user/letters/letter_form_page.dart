import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../core/services/firestore_letter_service.dart';
import '../../../core/services/user_context_service.dart';
import '../../../data/providers/auth_provider.dart';

class LetterFormPage extends StatefulWidget {
  const LetterFormPage({super.key});

  @override
  State<LetterFormPage> createState() => _LetterFormPageState();
}

class _LetterFormPageState extends State<LetterFormPage> {
  final TextEditingController _letterNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _validUntilController = TextEditingController();
  final UserContextService _userContext = UserContextService();
  final ImagePicker _imagePicker = ImagePicker();
  
  String? selectedEmployee;
  String? selectedLetterType;
  String selectedPriority = 'medium';
  DateTime? validUntilDate;
  bool _isLoading = false;
  bool _userLoaded = false;
  List<File> _selectedFiles = [];
  List<XFile> _selectedImages = [];
  
  final List<String> letterTypes = [
    'medical_certificate',
    'sick_leave',
    'annual_leave',
    'maternity_leave',
    'emergency_leave',
    'training_certificate',
  ];

  final List<String> priorities = [
    'low',
    'medium',
    'high',
    'urgent',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      setState(() {
        selectedEmployee = 'Loading...';
        _userLoaded = false;
      });

      print('🔍 Starting to fetch user name...');
      
      // Initialize Firestore
      await FirestoreLetterService.initialize();
      
      // Get current user email from auth provider
      final authProvider = context.read<AuthProvider>();
      String? userEmail;
      
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        userEmail = authProvider.currentUser!.email;
        print('� User email from AuthProvider: $userEmail');
      }
      
      if (userEmail == null || userEmail.isEmpty) {
        print('⚠️ No user email found, trying alternative method...');
        
        // Use the known user document ID as fallback
        const knownUserId = 'E8yHtkBnSFc6n9VZa9gE';
        
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(knownUserId)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final fullName = userData['full_name'] as String?;
          print('👤 Found user data via ID: $userData');
          print('✅ Full name: $fullName');
          
          if (mounted) {
            setState(() {
              selectedEmployee = fullName ?? 'Name not available';
              _userLoaded = true;
            });
          }
          return;
        } else {
          print('❌ User document not found with ID: $knownUserId');
          throw Exception('User not found in database');
        }
      }
      
      // Query Firestore directly for user with this email
      print('🔍 Querying Firestore for user with email: $userEmail');
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();
      
      print('📊 Query result: ${querySnapshot.docs.length} documents found');
      
      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final fullName = userData['full_name'] as String?;
        
        print('👤 Found user data: $userData');
        print('✅ Full name: $fullName');
        
        if (mounted) {
          setState(() {
            selectedEmployee = fullName ?? 'Name not found';
            _userLoaded = true;
          });
        }
      } else {
        print('❌ No user found with email: $userEmail');
        if (mounted) {
          setState(() {
            selectedEmployee = 'User not found in database';
            _userLoaded = true;
          });
        }
      }
      
    } catch (e) {
      print('❌ Error fetching user name: $e');
      if (mounted) {
        setState(() {
          selectedEmployee = 'Error: ${e.toString()}';
          _userLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Letter Form",
          style: TextStyle(
            color: AppColors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeField(), // Now shows "Name" with user's full name from Firestore
            const SizedBox(height: 20),
            _buildLetterNameField(),
            const SizedBox(height: 20),
            _buildLetterTypeDropdown(),
            const SizedBox(height: 20),
            _buildPriorityDropdown(),
            const SizedBox(height: 20),
            _buildValidUntilField(),
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 20),
            _buildFileUploadSection(),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Name",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              if (!_userLoaded)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (!_userLoaded)
                const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _userLoaded && selectedEmployee?.isNotEmpty == true 
                      ? selectedEmployee! 
                      : 'Loading name...',
                  style: TextStyle(
                    fontSize: 16,
                    color: _userLoaded && selectedEmployee?.isNotEmpty == true 
                        ? AppColors.black87 
                        : Colors.grey.shade600,
                    fontWeight: _userLoaded && selectedEmployee?.isNotEmpty == true 
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLetterNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Letter Name",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: _letterNameController,
            decoration: const InputDecoration(
              hintText: "Enter Letter Name",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLetterTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Letter Type",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedLetterType,
            decoration: const InputDecoration(
              hintText: "-Choose Letter Type-",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            items: letterTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(_getLetterTypeDisplayName(type)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedLetterType = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Priority",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedPriority,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            items: priorities.map((String priority) {
              return DropdownMenuItem<String>(
                value: priority,
                child: Row(
                  children: [
                    Icon(
                      _getPriorityIcon(priority),
                      size: 16,
                      color: _getPriorityColor(priority),
                    ),
                    const SizedBox(width: 8),
                    Text(_formatPriorityText(priority)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedPriority = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  String _formatStatusText(String status) {
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

  String _formatPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'low':
        return Icons.keyboard_arrow_down;
      case 'medium':
        return Icons.remove;
      case 'high':
        return Icons.keyboard_arrow_up;
      case 'urgent':
        return Icons.priority_high;
      default:
        return Icons.remove;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  Widget _buildValidUntilField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Valid Until",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: _validUntilController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "dd/mm/yy",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: validUntilDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  validUntilDate = picked;
                  _validUntilController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}";
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Letter Description",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Enter Letter Description (optional)",
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Supporting Evidence",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black87,
          ),
        ),
        const SizedBox(height: 8),
        
        // Upload buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickFromCamera(),
                icon: const Icon(Icons.camera_alt, size: 20),
                label: const Text("Camera"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickFromGallery(),
                icon: const Icon(Icons.photo_library, size: 20),
                label: const Text("Gallery"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickFiles(),
                icon: const Icon(Icons.attach_file, size: 20),
                label: const Text("Files"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Display selected files
        if (_selectedImages.isNotEmpty || _selectedFiles.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selected Files:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Display images
                if (_selectedImages.isNotEmpty)
                  ...(_selectedImages.asMap().entries.map((entry) {
                    int index = entry.key;
                    XFile image = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.image, color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              image.name,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeImage(index),
                            icon: const Icon(Icons.close, size: 16, color: AppColors.errorRed),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  })),
                
                // Display files
                if (_selectedFiles.isNotEmpty)
                  ...(_selectedFiles.asMap().entries.map((entry) {
                    int index = entry.key;
                    File file = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, color: AppColors.primaryGreen, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              file.path.split('/').last,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeFile(index),
                            icon: const Icon(Icons.close, size: 16, color: AppColors.errorRed),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  })),
              ],
            ),
          ),
        
        // Upload area when no files selected
        if (_selectedImages.isEmpty && _selectedFiles.isEmpty)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                Text(
                  "No files selected",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Use buttons above to select files",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : () {
              _submitLetter();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
                    ),
                  )
                : const Text(
                    "Submit Letter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pureWhite,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitLetter() async {
    // Validate form
    if (_letterNameController.text.isEmpty) {
      _showErrorMessage('Please enter a letter name');
      return;
    }
    
    if (selectedLetterType == null) {
      _showErrorMessage('Please select a letter type');
      return;
    }

    // Get user info from SharedPreferences (same as letters page)
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    final userId = prefs.getString('user_id');
    final employeeId = prefs.getString('employee_id');
    
    if (userId == null && employeeId == null && userEmail == null) {
      _showErrorMessage('You must be logged in to submit a letter');
      return;
    }

    // Use the selected employee name (which is the user's name)
    String userName = selectedEmployee ?? 'User Test';
    String actualUserId = userId ?? employeeId ?? '';
    
    if (actualUserId.isEmpty) {
      _showErrorMessage('Unable to identify user. Please login again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create letter model with the actual user name from the form
      final letter = LetterModel(
        id: '', // Will be set by Firestore
        letterNumber: 'LTR-${DateTime.now().millisecondsSinceEpoch}',
        letterType: selectedLetterType!,
        subject: _letterNameController.text.trim(),
        content: _descriptionController.text.trim(),
        recipientId: actualUserId,
        recipientName: userName, // Use the name we loaded
        recipientEmployeeId: employeeId ?? 'EMP001',
        recipientDepartment: 'IT Department',
        senderId: actualUserId,
        senderName: userName, // Use the same name
        senderPosition: 'Employee',
        status: 'waiting_approval', // Auto set to waiting approval
        priority: selectedPriority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: validUntilDate,
        approvalHistory: [
          ApprovalHistoryModel(
            action: 'created',
            timestamp: DateTime.now(),
            userId: actualUserId,
            userName: userName, // Use the loaded name
            notes: 'Letter submitted for approval',
          ),
        ],
        additionalInfo: null,
      );

      // Submit directly to Firestore
      print('🔍 Debug: About to submit letter: ${letter.subject}');
      print('🔍 Debug: Recipient ID: ${letter.recipientId}');
      print('🔍 Debug: User Email: $userEmail');
      
      // Convert letter to Firestore format and add directly
      final firestore = FirebaseFirestore.instance;
      
      // Use employee_id as primary identifier for data separation
      final primaryUserId = employeeId ?? userId ?? actualUserId;
      
      print('🔍 Debug: Form - employeeId: $employeeId');
      print('🔍 Debug: Form - userId: $userId'); 
      print('🔍 Debug: Form - actualUserId: $actualUserId');
      print('🔍 Debug: Form - primaryUserId (final): $primaryUserId');
      
      final letterData = {
        'letterNumber': letter.letterNumber,
        'letterType': letter.letterType,
        'subject': letter.subject,
        'content': letter.content,
        'user_id': primaryUserId, // Primary field for querying user's letters
        'recipientId': letter.recipientId,
        'recipientName': letter.recipientName,
        'recipientEmployeeId': primaryUserId, // Keep consistent with user_id
        'recipientDepartment': letter.recipientDepartment,
        'recipientEmail': userEmail ?? '',
        'senderId': letter.senderId,
        'senderName': letter.senderName,
        'senderPosition': letter.senderPosition,
        'status': letter.status,
        'priority': letter.priority,
        'createdAt': Timestamp.fromDate(letter.createdAt),
        'updatedAt': Timestamp.fromDate(letter.updatedAt),
        'validUntil': validUntilDate != null ? Timestamp.fromDate(validUntilDate!) : null,
      };
      
      print('🔍 Debug: Saving letter with user_id: $primaryUserId');
      print('🔍 Debug: Letter data: ${letterData['subject']} - ${letterData['status']}');
      
      final docRef = await firestore.collection('letters').add(letterData);
      print('🔍 Debug: Letter added successfully to Firestore with ID: ${docRef.id}');
      print('🔍 Debug: Letter subject: ${letterData['subject']}');
      print('🔍 Debug: Letter user_id: ${letterData['user_id']}');
      print('🔍 Debug: Letter status: ${letterData['status']}');
      
      _showSuccessMessage('Letter submitted successfully!');
      Navigator.pop(context, true); // Pass true to indicate success
    } catch (e) {
      print('🔍 Debug: Error submitting letter: $e');
      print('🔍 Debug: Error type: ${e.runtimeType}');
      _showErrorMessage('An error occurred while submitting the letter: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  String _getLetterTypeDisplayName(String type) {
    switch (type) {
      case 'medical_certificate':
        return 'Medical Certificate';
      case 'sick_leave':
        return 'Sick Leave';
      case 'annual_leave':
        return 'Annual Leave';
      case 'maternity_leave':
        return 'Maternity Leave';
      case 'emergency_leave':
        return 'Emergency Leave';
      case 'training_certificate':
        return 'Training Certificate';
      default:
        return type;
    }
  }

  // File picker methods
  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
        _showSuccessMessage('Photo captured successfully!');
      }
    } catch (e) {
      _showErrorMessage('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
        _showSuccessMessage('${images.length} image(s) selected!');
      }
    } catch (e) {
      _showErrorMessage('Failed to select images: $e');
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        setState(() {
          _selectedFiles.addAll(files);
        });
        _showSuccessMessage('${files.length} file(s) selected!');
      }
    } catch (e) {
      _showErrorMessage('Failed to select files: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  void dispose() {
    _letterNameController.dispose();
    _descriptionController.dispose();
    _validUntilController.dispose();
    super.dispose();
  }
}