import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../dummy/dummy_data.dart';

class MockAuthService {
  static MockAuthService? _instance;
  static MockAuthService get instance {
    _instance ??= MockAuthService._();
    return _instance!;
  }
  
  MockAuthService._();

  bool get isAuthenticated => _token != null;
  String? _token;

  // Mock login using dummy data
  Future<ApiResponse<MockLoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Mock Login attempt: $email');
      
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 500));
      
      // Find user in dummy data
      final user = DummyData.users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );
      
      if (user.isEmpty) {
        return ApiResponse<MockLoginResponse>(
          success: false,
          message: 'Invalid email or password',
          data: null,
        );
      }
      
      // Generate mock token
      _token = 'mock_token_${user['employee_id']}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('employee_id', user['employee_id']);
      await prefs.setString('user_email', user['email']);
      await prefs.setString('user_name', user['full_name']);
      await prefs.setString('user_role', user['role']);
      
      // Create User object
      final userData = User(
        id: user['id'],
        employeeId: user['employee_id'],
        fullName: user['full_name'],
        email: user['email'],
        department: user['department'],
        position: user['position'],
        role: user['role'],
        status: user['status'],
        isActive: user['status'] == 'active',
        profilePicture: user['profile_picture'],
        phone: user['phone'],
        address: user['address'],
        dateOfBirth: user['date_of_birth'] != null ? DateTime.tryParse(user['date_of_birth']) : null,
        hireDate: user['join_date'] != null ? DateTime.tryParse(user['join_date']) : null,
        createdAt: DateTime.parse(user['created_at']),
        updatedAt: DateTime.parse(user['updated_at']),
      );
      
      print('✅ Mock Login successful: ${user['full_name']} (${user['employee_id']})');
      
      // Return data in format that AuthProvider expects
      return ApiResponse<MockLoginResponse>(
        success: true,
        message: 'Login successful',
        data: MockLoginResponse(user: userData, token: _token!),
      );
      
    } catch (e) {
      print('❌ Mock Login error: $e');
      return ApiResponse<MockLoginResponse>(
        success: false,
        message: 'Login failed: $e',
        data: null,
      );
    }
  }

  // Mock logout
  Future<ApiResponse<String>> logout() async {
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('employee_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    
    return ApiResponse<String>(
      success: true,
      message: 'Logged out successfully',
      data: 'Logged out successfully',
    );
  }

  // Mock get current user
  Future<ApiResponse<User>> getCurrentUser() async {
    if (!isAuthenticated) {
      return ApiResponse<User>(
        success: false,
        message: 'Not authenticated',
        data: null,
      );
    }
    
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getString('employee_id');
    
    if (employeeId == null) {
      return ApiResponse<User>(
        success: false,
        message: 'Employee ID not found',
        data: null,
      );
    }
    
    final user = DummyData.users.firstWhere(
      (u) => u['employee_id'] == employeeId,
      orElse: () => {},
    );
    
    if (user.isEmpty) {
      return ApiResponse<User>(
        success: false,
        message: 'User not found',
        data: null,
      );
    }
    
    final userData = User(
      id: user['id'],
      employeeId: user['employee_id'],
      fullName: user['full_name'],
      email: user['email'],
      department: user['department'],
      position: user['position'],
      role: user['role'],
      status: user['status'],
      isActive: user['status'] == 'active',
      profilePicture: user['profile_picture'],
      phone: user['phone'],
      address: user['address'],
      dateOfBirth: user['date_of_birth'] != null ? DateTime.tryParse(user['date_of_birth']) : null,
      hireDate: user['join_date'] != null ? DateTime.tryParse(user['join_date']) : null,
      createdAt: DateTime.parse(user['created_at']),
      updatedAt: DateTime.parse(user['updated_at']),
    );
    
    return ApiResponse<User>(
      success: true,
      message: 'User retrieved successfully',
      data: userData,
    );
  }

  // Initialize from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    print('🔐 Mock Auth initialized: ${isAuthenticated ? "Authenticated" : "Not authenticated"}');
  }
}

class MockLoginResponse {
  final User user;
  final String token;

  MockLoginResponse({required this.user, required this.token});

  factory MockLoginResponse.fromJson(Map<String, dynamic> json) {
    return MockLoginResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}