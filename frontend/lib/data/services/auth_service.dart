import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/user.dart' hide LoginResponse;
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'mock_auth_service.dart';
import 'firebase_auth_service.dart';
import 'simple_firebase_auth_service.dart';

class AuthService {
  final ApiService _apiService = ApiService.instance;
  final MockAuthService _mockService = MockAuthService.instance;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final SimpleFirebaseAuthService _simpleFirebaseService = SimpleFirebaseAuthService();
  
  // Development flag - set to true to use mock service, false to use Firebase
  static const bool useMockService = false;
  static const bool useFirebaseAuth = false;
  static const bool useSimpleFirebase = false; // Use simplified version

  // Initialize the auth service
  Future<void> initialize() async {
    if (useMockService) {
      await _mockService.initialize();
    } else if (useSimpleFirebase) {
      await _simpleFirebaseService.initialize();
    } else if (useFirebaseAuth) {
      await _firebaseAuthService.initialize();
    } else {
      await _apiService.initializeToken();
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    if (useMockService) {
      return _mockService.isAuthenticated;
    } else if (useSimpleFirebase) {
      return _simpleFirebaseService.isAuthenticated;
    } else if (useFirebaseAuth) {
      return _firebaseAuthService.isAuthenticated;
    } else {
      return _apiService.isAuthenticated;
    }
  }

  // Save token to storage and ApiService (for Firebase, this saves the ID token)
  Future<void> saveToken(String token) async {
    if (!useFirebaseAuth) {
      await _apiService.setToken(token);
    }
    // For Firebase Auth, tokens are managed automatically
  }

  // Validate and refresh token
  Future<bool> validateAndRefreshToken() async {
    if (!isAuthenticated) return false;
    
    try {
      if (useFirebaseAuth) {
        // For Firebase Auth, check if user is still authenticated
        // and refresh the ID token for API calls
        final idToken = await _firebaseAuthService.getIdToken();
        if (idToken != null) {
          await _apiService.setToken(idToken);
          return true;
        }
        return false;
      }
      
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
    } else if (useSimpleFirebase) {
      final response = await _simpleFirebaseService.login(email: email, password: password);
      
      // For compatibility with existing code, return the user data in the expected format
      if (response.success && response.data != null) {
        // Get Firebase ID token for API calls
        final idToken = await _simpleFirebaseService.getIdToken();
        if (idToken != null) {
          await _apiService.setToken(idToken);
        }
        
        return ApiResponse(
          success: true,
          message: response.message,
          data: {
            'user': response.data,
            'token': idToken ?? '',
          },
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.message,
          data: null,
        );
      }
    } else if (useFirebaseAuth) {
      final response = await _firebaseAuthService.login(email: email, password: password);
      
      // For compatibility with existing code, return the user data in the expected format
      if (response.success && response.data != null) {
        // Get Firebase ID token for API calls
        final idToken = await _firebaseAuthService.getIdToken();
        if (idToken != null) {
          await _apiService.setToken(idToken);
        }
        
        return ApiResponse(
          success: true,
          message: response.message,
          data: {
            'user': response.data!.toJson(),
            'token': idToken ?? '',
          },
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.message,
          data: null,
        );
      }
    }
    
    print('🔐 AUTH_SERVICE: Starting login...');
    print('🔐 AUTH_SERVICE: Email: $email');
    print('🔐 AUTH_SERVICE: API URL: ${ApiConstants.baseUrl}${ApiConstants.auth.login}');
    print('🔐 AUTH_SERVICE: Timeout: 120 seconds');
    
    final startTime = DateTime.now();
    
    final response = await _apiService.post(
      ApiConstants.auth.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    
    final duration = DateTime.now().difference(startTime);
    print('🔐 AUTH_SERVICE: Login response received in ${duration.inSeconds}s');
    print('🔐 AUTH_SERVICE: Response success: ${response.success}');
    print('🔐 AUTH_SERVICE: Response message: ${response.message}');

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
    } else if (useFirebaseAuth) {
      await _apiService.clearToken(); // Clear any stored token
      return await _firebaseAuthService.logout();
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
    } else if (useSimpleFirebase) {
      return await _simpleFirebaseService.getCurrentUser();
    } else if (useFirebaseAuth) {
      return await _firebaseAuthService.getCurrentUser();
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

    final response = await _apiService.put<User>(
      ApiConstants.auth.updateProfile,
      data: data,
      fromJson: (json) => User.fromJson(json),
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after profile update...');
      _apiService.clearCache();
    }
    
    return response;
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