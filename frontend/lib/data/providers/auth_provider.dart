import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  // Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await _authService.initialize();
      
      if (_authService.isAuthenticated) {
        final isValid = await _authService.validateAndRefreshToken();
        
        if (isValid) {
          await _loadCurrentUser();
        } else {
          await logout();
        }
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        // Parse user data and token from response
        User? user;
        String? token;
        
        if (response.data is Map<String, dynamic>) {
          // Backend API response format: {user: {...}, token: "..."}
          final responseData = response.data as Map<String, dynamic>;
          print('🔍 AUTH_PROVIDER RAW RESPONSE: $responseData');
          
          if (responseData.containsKey('user')) {
            final userData = responseData['user'];
            print('🔍 AUTH_PROVIDER USER DATA: $userData');
            if (userData is Map<String, dynamic>) {
              print('🔍 AUTH_PROVIDER PARSING userData role: ${userData['role']}');
              print('🔍 AUTH_PROVIDER PARSING userData employee_id: ${userData['employee_id']}');
              user = User.fromJson(userData);
            }
          } else {
            // Try to parse as User directly
            try {
              user = User.fromJson(responseData);
            } catch (e) {
              print('Failed to parse user data as User: $e');
            }
          }
          
          // Extract token
          if (responseData.containsKey('token')) {
            token = responseData['token'] as String?;
          }
        } else {
          // Check if response.data has a 'user' property (for mock responses)
          try {
            final userData = response.data.user;
            if (userData is Map<String, dynamic>) {
              user = User.fromJson(userData);
            } else if (userData is User) {
              user = userData;
            }
            
            // Try to get token
            try {
              token = response.data.token as String?;
            } catch (e) {
              print('Failed to extract token: $e');
            }
          } catch (e) {
            print('Failed to access user property: $e');
          }
        }
        
        if (user != null) {
          print('🎯 AUTH_PROVIDER DEBUG: User object created');
          print('🎯 AUTH_PROVIDER DEBUG: User name: ${user.fullName}');
          print('🎯 AUTH_PROVIDER DEBUG: User email: ${user.email}');
          print('🎯 AUTH_PROVIDER DEBUG: User employee_id: "${user.employeeId}"');
          print('🎯 AUTH_PROVIDER DEBUG: User role: "${user.role}"');
          print('🎯 AUTH_PROVIDER DEBUG: User role type: ${user.role.runtimeType}');
          print('🎯 AUTH_PROVIDER DEBUG: Employee ID type: ${user.employeeId.runtimeType}');
          
          _currentUser = user;
          _isAuthenticated = true;
          
          // Save token to ApiService if available
          if (token != null && token.isNotEmpty) {
            await _authService.saveToken(token);
            print('✅ Token saved after login: ${token.substring(0, 20)}...');
          } else {
            print('⚠️ No token received from login response');
          }
          
          notifyListeners();
          return true;
        } else {
          _setError('Invalid user data received');
          return false;
        }
      } else {
        _setError(response.message ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String employeeId,
    required String department,
    required String position,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        employeeId: employeeId,
        department: department,
        position: position,
        phoneNumber: phoneNumber,
      );

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      debugPrint('Logout API call failed: ${e.toString()}');
    }

    _currentUser = null;
    _isAuthenticated = false;
    _clearError();
    _setLoading(false);
  }

  // Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? department,
    String? position,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        department: department,
        position: position,
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Profile update failed');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      _setError('Password change failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<bool> forgotPassword({
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.forgotPassword(email: email);

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      _setError('Forgot password failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify email
  Future<bool> verifyEmail({
    required String token,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.verifyEmail(token: token);

      if (response.success) {
        // Reload user data to get updated verification status
        await _loadCurrentUser();
        return true;
      } else {
        _setError(response.message ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      _setError('Email verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend verification email
  Future<bool> resendVerification({
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.resendVerification(email: email);

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      _setError('Resend verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!_isAuthenticated) return;

    try {
      await _loadCurrentUser();
    } catch (e) {
      debugPrint('Failed to refresh user data: ${e.toString()}');
    }
  }

  // Load current user data
  Future<void> _loadCurrentUser() async {
    try {
      final response = await _authService.getCurrentUser();

      if (response.success && response.data != null) {
        _currentUser = response.data;
        _isAuthenticated = true;
      } else {
        // Token might be invalid
        await logout();
      }
    } catch (e) {
      await logout();
      throw e;
    }
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
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  // Check if user is admin
  bool get isAdmin => hasRole('admin');

  // Check if user is HR
  bool get isHR => hasRole('hr');

  // Check if user is manager
  bool get isManager => hasRole('manager');

  // Check if user is employee
  bool get isEmployee => hasRole('employee');

  // Change password with new signature
  Future<bool> changeUserPassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Failed to change password');
        return false;
      }
    } catch (e) {
      _setError('Error changing password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user's full name
  String get userFullName => _currentUser?.fullName ?? 'User';

  // Get user's department
  String get userDepartment => _currentUser?.department ?? 'Unknown';

  // Get user's position
  String get userPosition => _currentUser?.position ?? 'Unknown';

  // Get user's employee ID
  String get userEmployeeId => _currentUser?.employeeId ?? 'Unknown';
}
