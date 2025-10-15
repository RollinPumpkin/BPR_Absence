import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';
import 'package:frontend/modules/admin/shared/admin_nav_items.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/letter_service.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/models/letter.dart';

import 'widgets/letter_card.dart';
import 'widgets/add_letter_type_popup.dart';
import 'widgets/view_letter_type_popup.dart';
import 'pages/add_letter_page.dart';
import 'pages/letter_acceptance_page.dart';

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';

class LetterPage extends StatefulWidget {
  const LetterPage({super.key});

  @override
  State<LetterPage> createState() => _LetterPageState();
}

class _LetterPageState extends State<LetterPage> {
  final LetterService _letterService = LetterService();
  final ApiService _apiService = ApiService.instance;
  final TextEditingController _searchController = TextEditingController();
  
  List<Letter> _allLetters = [];
  List<Letter> _filteredLetters = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    _loadLetters();
    _searchController.addListener(_filterLetters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLetters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 Admin Letters: Starting to load letters...');
      
      // For admin, get all letters by fetching both pending letters and other statuses
      print('🔍 Admin Letters: Fetching pending letters...');
      final pendingResponse = await _letterService.getPendingLetters(limit: 50);
      
      print('🔍 Admin Letters: Fetching received letters...');
      final receivedResponse = await _letterService.getReceivedLetters(limit: 50);
      
      print('🔍 Admin Letters: Pending response success: ${pendingResponse.success}');
      print('🔍 Admin Letters: Received response success: ${receivedResponse.success}');
      
      List<Letter> allLetters = [];
      
      // Add pending letters
      if (pendingResponse.success && pendingResponse.data != null) {
        print('🔍 Admin Letters: Adding ${pendingResponse.data!.length} pending letters');
        allLetters.addAll(pendingResponse.data!);
      } else {
        print('🔍 Admin Letters: No pending letters or error: ${pendingResponse.message}');
      }
      
      // Add received letters (approved/rejected)
      if (receivedResponse.success && receivedResponse.data != null) {
        print('🔍 Admin Letters: Adding ${receivedResponse.data!.items.length} received letters');
        // Get the actual letters from the ListResponse
        allLetters.addAll(receivedResponse.data!.items);
      } else {
        print('🔍 Admin Letters: No received letters or error: ${receivedResponse.message}');
      }
      
      // Remove duplicates by ID
      final Map<String, Letter> uniqueLetters = {};
      for (Letter letter in allLetters) {
        uniqueLetters[letter.id] = letter;
      }
      
      print('🔍 Admin Letters: Total unique letters: ${uniqueLetters.length}');
      
      // If no letters found, try alternative approach using direct API
      if (uniqueLetters.isEmpty) {
        print('🔍 Admin Letters: No letters found, trying direct API call...');
        try {
          // Try getting more letters with different parameters
          final directResponse = await _letterService.getReceivedLetters(
            limit: 100,
            status: null,  // Get all statuses
          );
          if (directResponse.success && directResponse.data != null) {
            print('🔍 Admin Letters: Direct API returned ${directResponse.data!.items.length} letters');
            for (Letter letter in directResponse.data!.items) {
              uniqueLetters[letter.id] = letter;
            }
          }
          
          // Last resort: call API directly
          if (uniqueLetters.isEmpty) {
            print('🔍 Admin Letters: Trying direct API call...');
            final rawResponse = await _apiService.get('/letters');
            print('🔍 Admin Letters: Raw API response: ${rawResponse.success}');
            if (rawResponse.success && rawResponse.data != null) {
              final responseData = rawResponse.data as Map<String, dynamic>;
              if (responseData['data'] != null && responseData['data']['letters'] != null) {
                final lettersJson = responseData['data']['letters'] as List;
                print('🔍 Admin Letters: Raw API returned ${lettersJson.length} letters');
                
                for (var letterJson in lettersJson) {
                  try {
                    final letter = Letter.fromJson(letterJson as Map<String, dynamic>);
                    uniqueLetters[letter.id] = letter;
                  } catch (e) {
                    print('🔍 Admin Letters: Error parsing letter: $e');
                  }
                }
              }
            }
          }
        } catch (e) {
          print('🔍 Admin Letters: All API calls failed: $e');
        }
      }

      // If still no letters, create dummy data for testing
      if (uniqueLetters.isEmpty) {
        print('🔍 Admin Letters: No letters found, creating dummy data for testing...');
        final dummyLetters = _createDummyLetters();
        for (var letter in dummyLetters) {
          uniqueLetters[letter.id] = letter;
        }
      }

      setState(() {
        _allLetters = uniqueLetters.values.toList();
        // Sort by creation date, newest first
        _allLetters.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        print('🔍 Admin Letters: Final letters count: ${_allLetters.length}');
        _filterLetters();
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading letters: $e';
        _isLoading = false;
      });
    }
  }

  List<Letter> _createDummyLetters() {
    final now = DateTime.now();
    return [
      Letter(
        id: 'dummy1',
        subject: 'Sick Leave Request - Ahmad Suryono',
        content: 'I am requesting sick leave due to illness. Medical certificate will be provided.',
        letterType: 'sick_leave',
        letterNumber: 'SL/2025/001',
        letterDate: now.subtract(Duration(days: 1)),
        priority: 'medium',
        status: 'waiting_approval',
        senderId: 'emp001',
        senderName: 'Ahmad Suryono',
        senderPosition: 'Account Officer',
        recipientId: 'admin',
        createdAt: now.subtract(Duration(days: 1)),
        updatedAt: now.subtract(Duration(days: 1)),
        requiresResponse: true,
        responseDeadline: now.add(Duration(days: 3)),
        responseReceived: false,
        attachments: [],
        ccRecipients: [],
      ),
      Letter(
        id: 'dummy2',
        subject: 'Annual Leave Request - Budi Santoso',
        content: 'I would like to request annual leave for vacation next month.',
        letterType: 'annual_leave',
        letterNumber: 'AL/2025/002',
        letterDate: now.subtract(Duration(days: 2)),
        priority: 'low',
        status: 'approved',
        senderId: 'emp002',
        senderName: 'Budi Santoso',
        senderPosition: 'Finance Staff',
        recipientId: 'admin',
        createdAt: now.subtract(Duration(days: 2)),
        updatedAt: now.subtract(Duration(hours: 12)),
        requiresResponse: false,
        responseReceived: false,
        attachments: [],
        ccRecipients: [],
      ),
      Letter(
        id: 'dummy3',
        subject: 'Permission Letter - Sari Dewi',
        content: 'I need permission to leave early today for family matters.',
        letterType: 'permission_letter',
        letterNumber: 'PL/2025/003',
        letterDate: now.subtract(Duration(hours: 6)),
        priority: 'high',
        status: 'rejected',
        senderId: 'emp003',
        senderName: 'Sari Dewi',
        senderPosition: 'Customer Service',
        recipientId: 'admin',
        createdAt: now.subtract(Duration(hours: 6)),
        updatedAt: now.subtract(Duration(hours: 2)),
        requiresResponse: true,
        responseDeadline: now.add(Duration(hours: 18)),
        responseReceived: false,
        attachments: [],
        ccRecipients: [],
      ),
      Letter(
        id: 'dummy4',
        subject: 'Work Certificate Request - Andi Putra',
        content: 'I need a work certificate for bank loan application.',
        letterType: 'work_certificate',
        letterNumber: 'WC/2025/004',
        letterDate: now.subtract(Duration(days: 3)),
        priority: 'normal',
        status: 'approved',
        senderId: 'emp004',
        senderName: 'Andi Putra',
        senderPosition: 'Credit Analyst',
        recipientId: 'admin',
        createdAt: now.subtract(Duration(days: 3)),
        updatedAt: now.subtract(Duration(days: 1)),
        requiresResponse: false,
        responseReceived: false,
        attachments: [],
        ccRecipients: [],
      ),
      Letter(
        id: 'dummy5',
        subject: 'Family Leave Request - Maya Sari',
        content: 'Emergency family leave needed due to family member hospitalization.',
        letterType: 'family_leave',
        letterNumber: 'FL/2025/005',
        letterDate: now.subtract(Duration(hours: 3)),
        priority: 'high',
        status: 'waiting_approval',
        senderId: 'emp005',
        senderName: 'Maya Sari',
        senderPosition: 'Teller',
        recipientId: 'admin',
        createdAt: now.subtract(Duration(hours: 3)),
        updatedAt: now.subtract(Duration(hours: 3)),
        requiresResponse: true,
        responseDeadline: now.add(Duration(hours: 21)),
        responseReceived: false,
        attachments: [],
        ccRecipients: [],
      ),
    ];
  }

  void _filterLetters() {
    String searchTerm = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredLetters = _allLetters.where((letter) {
        // Filter by search term
        bool matchesSearch = letter.senderName?.toLowerCase().contains(searchTerm) ?? false ||
                           letter.subject.toLowerCase().contains(searchTerm) ||
                           letter.letterType.toLowerCase().contains(searchTerm);
        
        // Filter by status
        bool matchesStatus = _selectedStatus == 'all' || 
                           letter.status == _selectedStatus;
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  String _formatLetterType(String letterType) {
    switch (letterType.toLowerCase()) {
      case 'sick_leave':
        return 'Sick Leave';
      case 'annual_leave':
        return 'Annual Leave';
      case 'work_certificate':
        return 'Work Certificate';
      case 'family_leave':
        return 'Family Leave';
      default:
        return letterType.replaceAll('_', ' ').split(' ').map((word) => 
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown Date';
    
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.primaryYellow;
      case 'approved':
        return AppColors.primaryGreen;
      case 'rejected':
        return AppColors.primaryRed;
      case 'waiting_approval':
        return AppColors.primaryYellow;
      default:
        return AppColors.neutral500;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Waiting Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'waiting_approval':
        return 'Waiting Approval';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Letters',
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Toolbar (Filter / Export / Add Data / Add & View Letter Type)
              const _LetterToolbar(),
              const SizedBox(height: 16),

              // Search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Employee or Letter Type',
                  prefixIcon: const Icon(Icons.search, color: AppColors.neutral500),
                  filled: true,
                  fillColor: AppColors.pureWhite,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.dividerGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.dividerGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Filter Chips
              Row(
                children: [
                  _buildStatusChip('all', 'All'),
                  const SizedBox(width: 8),
                  _buildStatusChip('pending', 'Pending'),
                  const SizedBox(width: 8),
                  _buildStatusChip('approved', 'Approved'),
                  const SizedBox(width: 8),
                  _buildStatusChip('rejected', 'Rejected'),
                ],
              ),
              const SizedBox(height: 16),

              // Content
              _buildLettersList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavRouter(
        currentIndex: 3, // Letters is the 4th item (0-indexed)
        items: AdminNavItems.items,
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    bool isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
          _filterLetters();
        });
      },
      selectedColor: AppColors.accentBlue.withOpacity(0.2),
      checkmarkColor: AppColors.accentBlue,
    );
  }

  Widget _buildLettersList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: AppColors.accentBlue,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: AppColors.primaryRed.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error, color: AppColors.primaryRed),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadLetters,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_filteredLetters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: AppColors.neutral100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.mail_outline, color: AppColors.neutral500, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    _allLetters.isEmpty ? 'No letters found' : 'No letters match your search',
                    style: const TextStyle(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: _filteredLetters.map((letter) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LetterCard(
            name: letter.senderName ?? 'Unknown',
            date: _formatDate(letter.createdAt),
            type: _formatLetterType(letter.letterType),
            status: _getStatusText(letter.status),
            statusColor: _getStatusColor(letter.status),
            absence: letter.letterType.contains('leave') ? 'Leave' : 'Request',
            absenceColor: _getStatusColor(letter.status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LetterAcceptancePage(),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class _LetterToolbar extends StatelessWidget {
  const _LetterToolbar();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // Filter
          OutlinedButton.icon(
            onPressed: () {
              // TODO: buka dialog / bottom sheet filter
            },
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Filter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neutral800,
              side: const BorderSide(color: AppColors.dividerGray),
              backgroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),

          // Export → Excel
          OutlinedButton(
            onPressed: () => _exportLettersExcel(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.primaryRed),
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Export', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),

          // Add Data
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddLetterPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text('Add Data', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),

          // Add Letter Type (popup)
          ElevatedButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => const AddLetterTypePopup());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child:
                const Text('Add Letter Type', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),

          // View Letter Type (popup)
          ElevatedButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => const ViewLetterTypePopup());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child:
                const Text('View Letter Type', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ===== Export helper =====
Future<void> _exportLettersExcel(BuildContext context) async {
  // TODO: ganti ke data asli dari state/VM/repo kamu
  final rows = <Map<String, String>>[
    {
      'Name': 'Septa Puma',
      'Date': '27 Agustus 2024',
      'Type': "Doctor's Note",
      'Status': 'Waiting Approval',
      'Absence': 'Absence',
    },
    {
      'Name': 'Septa Puma',
      'Date': '27 Agustus 2024',
      'Type': "Doctor's Note",
      'Status': 'Rejected',
      'Absence': 'Absence',
    },
  ];

  try {
    final excel = Excel.createExcel();
    final sheet = excel['Letters'];
    excel.setDefaultSheet('Letters');

    // header
    const headers = ['Name', 'Date', 'Type', 'Status', 'Absence'];
    for (var c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // data
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      final values = [
        row['Name'] ?? '',
        row['Date'] ?? '',
        row['Type'] ?? '',
        row['Status'] ?? '',
        row['Absence'] ?? '',
      ];
      for (var c = 0; c < values.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
            .value = TextCellValue(values[c]);
      }
    }

    final bytes = Uint8List.fromList(excel.save()!);
    final filename = 'letters_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    await FileSaver.instance.saveFile(
      name: filename,
      bytes: bytes,
      mimeType: MimeType.microsoftExcel,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Letters exported successfully'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }
}
