import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/user.dart' hide LoginResponse;
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'mock_auth_service.dart';

class AuthService {
  final ApiService _apiService = ApiService.instance;
  final MockAuthService _mockService = MockAuthService.instance;
  
  // Development flag - set to true to use mock service
  static const bool useMockService = false;

  // Initialize the auth service
  Future<void> initialize() async {
    if (useMockService) {
      await _mockService.initialize();
    } else {
      await _apiService.initializeToken();
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => useMockService ? _mockService.isAuthenticated : _apiService.isAuthenticated;

  // Save token to storage and ApiService
  Future<void> saveToken(String token) async {
    await _apiService.setToken(token);
  }

  // Validate and refresh token
  Future<bool> validateAndRefreshToken() async {
    if (!isAuthenticated) return false;
    
    try {
      // Try to get current user to validate token
      final response = await getCurrentUser();
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // Login
  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    if (useMockService) {
      return await _mockService.login(email: email, password: password);
    }
    
    final response = await _apiService.post(
      ApiConstants.auth.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    return response;
  }

  // Register
  Future<ApiResponse<User>> register({
    required String fullName,
    required String email,
    required String password,
    required String employeeId,
    required String department,
    required String position,
    String? phoneNumber,
  }) async {
    return await _apiService.post<User>(
      ApiConstants.auth.register,
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'employee_id': employeeId,
        'department': department,
        'position': position,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      },
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Logout
  Future<ApiResponse<String>> logout() async {
    if (useMockService) {
      return await _mockService.logout();
    }
    
    final response = await _apiService.post<String>(
      ApiConstants.auth.logout,
      fromJson: (json) => json?.toString() ?? 'Logged out successfully',
    );

    // Clear token regardless of response
    await _apiService.clearToken();

    // Clear saved credentials if remember me is not enabled
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    if (!rememberMe) {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }

    return response;
  }

  // Get current user profile
  Future<ApiResponse<User>> getCurrentUser() async {
    if (useMockService) {
      return await _mockService.getCurrentUser();
    }
    return await _apiService.get<User>(
      ApiConstants.auth.profile,
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Update profile
  Future<ApiResponse<User>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? department,
    String? position,
  }) async {
    final data = <String, dynamic>{};
    
    if (fullName != null) data['full_name'] = fullName;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (department != null) data['department'] = department;
    if (position != null) data['position'] = position;

    return await _apiService.put<User>(
      ApiConstants.auth.updateProfile,
      data: data,
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Change password
  Future<ApiResponse<String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _apiService.put<String>(
      ApiConstants.auth.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      fromJson: (json) => json?.toString() ?? 'Password changed successfully',
    );
  }

  // Forgot password
  Future<ApiResponse<String>> forgotPassword({
    required String email,
  }) async {
    return await _apiService.post<String>(
      ApiConstants.auth.forgotPassword,
      data: {
        'email': email,
      },
      fromJson: (json) => json?.toString() ?? 'Reset instructions sent',
    );
  }

  // Reset password
  Future<ApiResponse<String>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await _apiService.post<String>(
      ApiConstants.auth.resetPassword,
      data: {
        'token': token,
        'new_password': newPassword,
      },
      fromJson: (json) => json?.toString() ?? 'Password reset successfully',
    );
  }

  // Refresh token
  Future<ApiResponse> refreshToken() async {
    if (useMockService) {
      // Mock refresh - just return success
      return ApiResponse(
        success: true,
        message: 'Token refreshed successfully',
        data: 'mock_refreshed_token',
      );
    }
    
    final response = await _apiService.post(
      ApiConstants.auth.refreshToken,
    );

    return response;
  }

  // Verify email
  Future<ApiResponse<String>> verifyEmail({
    required String token,
  }) async {
    return await _apiService.post<String>(
      ApiConstants.auth.verifyEmail,
      data: {
        'token': token,
      },
      fromJson: (json) => json?.toString() ?? 'Email verified successfully',
    );
  }

  // Resend verification email
  Future<ApiResponse<String>> resendVerification({
    required String email,
  }) async {
    return await _apiService.post<String>(
      ApiConstants.auth.resendVerification,
      data: {
        'email': email,
      },
      fromJson: (json) => json?.toString() ?? 'Verification email sent',
    );
  }
}