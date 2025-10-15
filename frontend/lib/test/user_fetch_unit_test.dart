import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/user_provider.dart';
import '../data/constants/api_constants.dart';
import '../data/services/user_service.dart';
import '../data/models/user.dart';

class UserFetchUnitTest extends StatefulWidget {
  const UserFetchUnitTest({Key? key}) : super(key: key);

  @override
  State<UserFetchUnitTest> createState() => _UserFetchUnitTestState();
}

class _UserFetchUnitTestState extends State<UserFetchUnitTest> {
  final List<String> _testResults = [];
  bool _isRunning = false;

  void _addResult(String result) {
    setState(() {
      _testResults.add('[${DateTime.now().toString().substring(11, 19)}] $result');
    });
    print(result);
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addResult('🚀 Starting Comprehensive User Fetch Tests');
    _addResult('=' * 50);

    await _testAuthentication();
    await _testApiConstants();
    await _testUserModel();
    await _testUserService();
    await _testUserProvider();
    await _testIntegration();

    _addResult('=' * 50);
    _addResult('✅ All tests completed!');

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testAuthentication() async {
    _addResult('🔐 TEST 1: Authentication Check');
    try {
      final authProvider = context.read<AuthProvider>();
      
      _addResult('   - Current user: ${authProvider.currentUser?.fullName ?? "Not logged in"}');
      _addResult('   - User role: ${authProvider.currentUser?.role ?? "No role"}');
      _addResult('   - Is authenticated: ${authProvider.isAuthenticated}');
      _addResult('   - User ID: ${authProvider.currentUser?.id ?? "No ID"}');
      _addResult('   - Employee ID: ${authProvider.currentUser?.employeeId ?? "No employee ID"}');
      
      if (authProvider.currentUser != null && 
          (authProvider.currentUser!.role == 'admin' || 
           authProvider.currentUser!.role == 'super_admin')) {
        _addResult('   ✅ Admin user authenticated successfully');
      } else {
        _addResult('   ❌ No admin user authenticated');
      }
      
    } catch (e) {
      _addResult('   ❌ Authentication test error: $e');
    }
    _addResult('');
  }

  Future<void> _testApiConstants() async {
    _addResult('🌐 TEST 2: API Constants Verification');
    try {
      _addResult('   - Base URL: ${ApiConstants.baseUrl}');
      _addResult('   - Users list endpoint: ${ApiConstants.users.list}');
      _addResult('   - Create employee endpoint: ${ApiConstants.users.create}');
      
      // Verify endpoints are correct
      if (ApiConstants.users.list.contains('/admin/users')) {
        _addResult('   ✅ Users list endpoint is correct');
      } else {
        _addResult('   ❌ Users list endpoint incorrect: ${ApiConstants.users.list}');
      }
      
      if (ApiConstants.users.create.contains('/users/admin/create-employee')) {
        _addResult('   ✅ Create employee endpoint is correct');
      } else {
        _addResult('   ❌ Create employee endpoint incorrect: ${ApiConstants.users.create}');
      }
      
    } catch (e) {
      _addResult('   ❌ API constants test error: $e');
    }
    _addResult('');
  }

  Future<void> _testUserModel() async {
    _addResult('👤 TEST 3: User Model Parsing');
    try {
      // Test various user data formats
      final testUserData = [
        {
          'id': 'test123',
          'email': 'test@example.com',
          'fullName': 'Test User',
          'role': 'employee',
          'employeeId': 'EMP001',
          'isActive': true,
          'department': 'IT',
          'position': 'Developer',
          'phoneNumber': '08123456789',
          'salary': 50000.0,
          'createdAt': {'_seconds': 1640995200, '_nanoseconds': 0}, // Firebase Timestamp
          'updatedAt': {'_seconds': 1640995200, '_nanoseconds': 0}
        },
        {
          'id': 'test456',
          'email': 'admin@example.com',
          'fullName': 'Admin User',
          'role': 'admin',
          'employeeId': 'ADM001',
          'isActive': true,
          'department': null,
          'position': null,
          'phoneNumber': null,
          'salary': null,
          'createdAt': null,
          'updatedAt': null
        }
      ];

      for (int i = 0; i < testUserData.length; i++) {
        try {
          final user = User.fromJson(testUserData[i]);
          _addResult('   ✅ User ${i + 1} parsed successfully:');
          _addResult('      - Name: ${user.fullName}');
          _addResult('      - Role: ${user.role}');
          _addResult('      - Employee ID: ${user.employeeId}');
          _addResult('      - Department: ${user.department}');
          _addResult('      - Created: ${user.createdAt?.toString() ?? "null"}');
        } catch (e) {
          _addResult('   ❌ User ${i + 1} parsing failed: $e');
        }
      }

      // Test malformed data
      try {
        final malformedData = {'id': null, 'email': 123, 'fullName': []};
        final user = User.fromJson(malformedData);
        _addResult('   ⚠️ Malformed data handled: ${user.fullName}');
      } catch (e) {
        _addResult('   ❌ Malformed data handling failed: $e');
      }

    } catch (e) {
      _addResult('   ❌ User model test error: $e');
    }
    _addResult('');
  }

  Future<void> _testUserService() async {
    _addResult('🔧 TEST 4: User Service');
    try {
      final userService = UserService();
      
      _addResult('   🔄 Testing getAllUsers API call...');
      
      final response = await userService.getAllUsers(page: 1, limit: 5);
      
      _addResult('   - Response success: ${response.success}');
      _addResult('   - Response message: ${response.message ?? "No message"}');
      _addResult('   - Response data type: ${response.data.runtimeType}');
      
      if (response.success && response.data != null) {
        try {
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            _addResult('   - Data keys: ${data.keys.toList()}');
            
            if (data.containsKey('items')) {
              final items = data['items'];
              _addResult('   - Items type: ${items.runtimeType}');
              if (items is List) {
                _addResult('   ✅ Found ${items.length} items in response');
                if (items.isNotEmpty) {
                  final firstItem = items.first;
                  _addResult('   - First item type: ${firstItem.runtimeType}');
                  if (firstItem is Map<String, dynamic>) {
                    _addResult('   - First item keys: ${firstItem.keys.toList()}');
                  }
                }
              }
            }
            
            if (data.containsKey('pagination')) {
              _addResult('   - Pagination data found');
            }
          } else {
            _addResult('   ❌ Unexpected response data format');
          }
        } catch (e) {
          _addResult('   ❌ Error parsing response data: $e');
        }
      } else {
        _addResult('   ❌ API call failed');
      }
      
    } catch (e) {
      _addResult('   ❌ User service test error: $e');
    }
    _addResult('');
  }

  Future<void> _testUserProvider() async {
    _addResult('📦 TEST 5: User Provider');
    try {
      final userProvider = context.read<UserProvider>();
      
      _addResult('   - Initial users count: ${userProvider.users.length}');
      _addResult('   - Initial loading state: ${userProvider.isLoading}');
      _addResult('   - Initial error: ${userProvider.errorMessage ?? "None"}');
      
      // Clear any previous errors
      userProvider.clearError();
      
      _addResult('   🔄 Testing initialize()...');
      await userProvider.initialize();
      
      // Wait for completion
      await Future.delayed(const Duration(seconds: 3));
      
      _addResult('   - After init users count: ${userProvider.users.length}');
      _addResult('   - After init loading state: ${userProvider.isLoading}');
      _addResult('   - After init error: ${userProvider.errorMessage ?? "None"}');
      _addResult('   - Total users: ${userProvider.totalUsers}');
      _addResult('   - Current page: ${userProvider.currentPage}');
      _addResult('   - Has more: ${userProvider.hasMore}');
      
      if (userProvider.users.isNotEmpty) {
        _addResult('   ✅ UserProvider successfully loaded users');
        
        // Test different user types
        final admins = userProvider.users.where((u) => 
          u.role == 'admin' || u.role == 'super_admin').length;
        final employees = userProvider.users.where((u) => u.role == 'employee').length;
        
        _addResult('   - Admin users: $admins');
        _addResult('   - Employee users: $employees');
        
        // Test first user details
        final firstUser = userProvider.users.first;
        _addResult('   - Sample user: ${firstUser.fullName}');
        _addResult('   - Sample role: ${firstUser.role}');
        _addResult('   - Sample department: ${firstUser.department ?? "N/A"}');
        
      } else {
        _addResult('   ❌ UserProvider failed to load users');
      }
      
    } catch (e) {
      _addResult('   ❌ User provider test error: $e');
    }
    _addResult('');
  }

  Future<void> _testIntegration() async {
    _addResult('🔗 TEST 6: Integration Test');
    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      
      _addResult('   🔄 Testing full integration flow...');
      
      // 1. Check authentication
      if (!authProvider.isAuthenticated) {
        _addResult('   ❌ User not authenticated for integration test');
        return;
      }
      
      // 2. Clear and reload data
      userProvider.clearData();
      await userProvider.initialize();
      
      await Future.delayed(const Duration(seconds: 3));
      
      // 3. Verify data consistency
      final totalUsers = userProvider.totalUsers;
      final loadedUsers = userProvider.users.length;
      
      _addResult('   - Total users reported: $totalUsers');
      _addResult('   - Users actually loaded: $loadedUsers');
      
      if (loadedUsers > 0) {
        _addResult('   ✅ Integration test successful');
        
        // 4. Test search functionality
        if (userProvider.users.isNotEmpty) {
          final firstUserName = userProvider.users.first.fullName;
          _addResult('   🔍 Testing search for: $firstUserName');
          await userProvider.searchUsers(firstUserName.split(' ').first);
          
          await Future.delayed(const Duration(seconds: 2));
          
          _addResult('   - Search results: ${userProvider.users.length}');
        }
        
        // 5. Clear search
        await userProvider.clearFilters();
        await Future.delayed(const Duration(seconds: 2));
        _addResult('   - After clear filters: ${userProvider.users.length}');
        
      } else {
        _addResult('   ❌ Integration test failed - no users loaded');
      }
      
    } catch (e) {
      _addResult('   ❌ Integration test error: $e');
    }
    _addResult('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Fetch Unit Tests'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runAllTests,
                  icon: _isRunning 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                  label: Text(_isRunning ? 'Running Tests...' : 'Run All Tests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _testResults.clear();
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: ListView.builder(
                itemCount: _testResults.length,
                itemBuilder: (context, index) {
                  final result = _testResults[index];
                  Color textColor = Colors.white;
                  
                  if (result.contains('✅')) {
                    textColor = Colors.green[300]!;
                  } else if (result.contains('❌')) {
                    textColor = Colors.red[300]!;
                  } else if (result.contains('⚠️')) {
                    textColor = Colors.orange[300]!;
                  } else if (result.contains('🔄')) {
                    textColor = Colors.blue[300]!;
                  } else if (result.startsWith('[') && result.contains(']')) {
                    textColor = Colors.grey[400]!;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      result,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}