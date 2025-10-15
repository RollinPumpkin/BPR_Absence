import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/providers/auth_provider.dart';
import 'package:frontend/data/providers/user_provider.dart';
import 'package:frontend/data/services/api_service.dart';

class TestEmployeeFetchPage extends StatefulWidget {
  const TestEmployeeFetchPage({super.key});

  @override
  State<TestEmployeeFetchPage> createState() => _TestEmployeeFetchPageState();
}

class _TestEmployeeFetchPageState extends State<TestEmployeeFetchPage> {
  String _testResults = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  void _addResult(String result) {
    setState(() {
      _testResults += '$result\n';
    });
    print(result);
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _testResults = '';
    });

    _addResult('🚀 Starting Employee Database Fetch Tests...\n');

    // Test 1: Check Authentication
    await _testAuthentication();
    
    // Test 2: Check API Service
    await _testApiService();
    
    // Test 3: Test UserProvider
    await _testUserProvider();
    
    // Test 4: Test Direct API Call
    await _testDirectApiCall();

    setState(() {
      _isLoading = false;
    });
    _addResult('\n✅ All tests completed!');
  }

  Future<void> _testAuthentication() async {
    _addResult('📋 TEST 1: Authentication Check');
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      _addResult('   - Is Authenticated: ${authProvider.isAuthenticated}');
      _addResult('   - Current User: ${currentUser?.fullName ?? "None"}');
      _addResult('   - User Email: ${currentUser?.email ?? "None"}');
      _addResult('   - User Role: ${currentUser?.role ?? "None"}');
      _addResult('   - Employee ID: ${currentUser?.employeeId ?? "None"}');
      
      if (currentUser?.role == 'admin' || currentUser?.role == 'super_admin') {
        _addResult('   ✅ User has admin privileges');
      } else {
        _addResult('   ❌ User does NOT have admin privileges');
      }
    } catch (e) {
      _addResult('   ❌ Authentication test error: $e');
    }
    _addResult('');
  }

  Future<void> _testApiService() async {
    _addResult('📋 TEST 2: API Service Check');
    try {
      final apiService = ApiService.instance;
      _addResult('   - API Service accessed successfully');
      _addResult('   - Is Authenticated: ${apiService.isAuthenticated}');
      
      // Test token refresh
      await ApiService.initialize();
      _addResult('   - API Service re-initialized');
      
    } catch (e) {
      _addResult('   ❌ API Service test error: $e');
    }
    _addResult('');
  }

  Future<void> _testUserProvider() async {
    _addResult('📋 TEST 3: UserProvider Test');
    try {
      final userProvider = context.read<UserProvider>();
      
      _addResult('   - Current users count: ${userProvider.users.length}');
      _addResult('   - Is loading: ${userProvider.isLoading}');
      _addResult('   - Error message: ${userProvider.errorMessage ?? "None"}');
      _addResult('   - Total users: ${userProvider.totalUsers}');
      _addResult('   - Current page: ${userProvider.currentPage}');
      _addResult('   - Has more: ${userProvider.hasMore}');
      
      _addResult('   🔄 Attempting to fetch users...');
      
      // Clear any existing data first
      userProvider.clearError();
      
      await userProvider.initialize();
      
      // Wait a bit for the operation to complete
      await Future.delayed(const Duration(seconds: 3));
      
      _addResult('   - After fetch - users count: ${userProvider.users.length}');
      _addResult('   - After fetch - loading: ${userProvider.isLoading}');
      _addResult('   - After fetch - error: ${userProvider.errorMessage ?? "None"}');
      _addResult('   - After fetch - total users: ${userProvider.totalUsers}');
      
      if (userProvider.users.isNotEmpty) {
        _addResult('   ✅ Successfully fetched ${userProvider.users.length} users');
        final firstUser = userProvider.users.first;
        _addResult('   - Sample user: ${firstUser.fullName} (${firstUser.role})');
        _addResult('   - Sample email: ${firstUser.email}');
        _addResult('   - Sample employee ID: ${firstUser.employeeId}');
        
        // Test parsing of different user types
        var adminCount = userProvider.users.where((u) => u.role == 'admin' || u.role == 'super_admin').length;
        var employeeCount = userProvider.users.where((u) => u.role == 'employee').length;
        _addResult('   - Admin users: $adminCount');
        _addResult('   - Employee users: $employeeCount');
        
      } else if (userProvider.errorMessage != null) {
        _addResult('   ❌ Error occurred: ${userProvider.errorMessage}');
      } else {
        _addResult('   ❌ No users fetched but no error reported');
      }
      
    } catch (e) {
      _addResult('   ❌ UserProvider test error: $e');
    }
    _addResult('');
  }

  Future<void> _testDirectApiCall() async {
    _addResult('📋 TEST 4: Direct API Call Test');
    try {
      // This will use the same API service that UserProvider uses
      final apiService = ApiService.instance;
      
      final response = await apiService.get<Map<String, dynamic>>(
        '/admin/users?page=1&limit=5',
        fromJson: (json) => json,
      );
      
      _addResult('   - Response success: ${response.success}');
      _addResult('   - Response message: ${response.message ?? "None"}');
      
      if (response.success && response.data != null) {
        final data = response.data!;
        _addResult('   - Response data keys: ${data.keys.toList()}');
        
        if (data['data'] != null) {
          final userData = data['data'] as Map<String, dynamic>;
          _addResult('   - User data keys: ${userData.keys.toList()}');
          
          if (userData['users'] != null) {
            final users = userData['users'] as List;
            _addResult('   ✅ Direct API call successful - ${users.length} users returned');
          } else {
            _addResult('   ❌ No users array in response');
          }
        } else {
          _addResult('   ❌ No data in response');
        }
      } else {
        _addResult('   ❌ API call failed: ${response.message}');
      }
      
    } catch (e) {
      _addResult('   ❌ Direct API call error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Database Fetch Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _runTests,
                  child: const Text('Run Tests Again'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}