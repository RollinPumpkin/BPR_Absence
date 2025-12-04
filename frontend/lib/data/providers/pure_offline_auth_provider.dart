import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../dummy/dummy_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PureOfflineAuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  // Initialize - check if user was logged in
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id');
      
      if (employeeId != null) {
        // Find user in dummy data
        final user = DummyData.users.firstWhere(
          (u) => u['employee_id'] == employeeId,
          orElse: () => {},
        );
        
        if (user.isNotEmpty) {
          _currentUser = _createUserFromMap(user);
          _isAuthenticated = true;
          print('🔐 Pure Offline Auth: Restored user ${_currentUser!.fullName}');
        }
      }
    } catch (e) {
      print('❌ Pure Offline Auth initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Login - pure offline using dummy data
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔐 Pure Offline Login attempt: $email');
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Find user in dummy data
      final user = DummyData.users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );
      
      if (user.isEmpty) {
        _setError('Invalid email or password');
        return false;
      }
      
      // Create user object
      _currentUser = _createUserFromMap(user);
      _isAuthenticated = true;
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('employee_id', user['employee_id']);
      await prefs.setString('user_email', user['email']);
      await prefs.setString('user_name', user['full_name']);
      await prefs.setString('user_role', user['role']);
      
      print('✅ Pure Offline Login successful: ${user['full_name']} (${user['employee_id']})');
      
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;
    _errorMessage = null;
    
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('employee_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    
    print('🔐 Pure Offline Logout successful');
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  User _createUserFromMap(Map<String, dynamic> user) {
    return User(
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
  }
}