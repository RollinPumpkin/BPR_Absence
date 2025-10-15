import '../models/api_response.dart';
import '../models/user.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService.instance;

  // Get all users (admin only) - SIMPLIFIED VERSION
  Future<ApiResponse<ListResponse<User>>> getAllUsers({
    int page = 1,
    int limit = 10,
    String? search,
    String? department,
    String? position,
    String? role,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (search != null) queryParams['search'] = search;
    if (department != null) queryParams['department'] = department;
    if (position != null) queryParams['position'] = position;
    if (role != null) queryParams['role'] = role;
    if (isActive != null) queryParams['is_active'] = isActive;

    return await _apiService.get<ListResponse<User>>(
      ApiConstants.users.list,
      queryParameters: queryParams,
      fromJson: (json) {
        print('🔧 UserService.getAllUsers - Processing response...');
        print('🔧 Response keys: ${json.keys.toList()}');
        
        try {
          // Handle different response structures
          List<dynamic> usersData = [];
          Map<String, dynamic>? paginationData;
          
          // Case 1: {users: [...], pagination: {...}}
          if (json['users'] is List) {
            usersData = json['users'];
            paginationData = json['pagination'];
            print('✅ Found users array directly');
          }
          // Case 2: {data: {users: [...], pagination: {...}}}
          else if (json['data'] is Map) {
            final dataMap = json['data'] as Map<String, dynamic>;
            if (dataMap['users'] is List) {
              usersData = dataMap['users'];
              paginationData = dataMap['pagination'];
              print('✅ Found users array in data field');
            }
          }
          // Case 3: Direct array [user1, user2, ...]
          else if (json is List) {
            usersData = json;
            print('✅ Response is direct users array');
          }
          
          if (usersData.isEmpty) {
            print('⚠️ No users found in response');
          }
          
          print('📊 Processing ${usersData.length} users...');
          
          // Convert users to User objects
          final users = <User>[];
          for (int i = 0; i < usersData.length; i++) {
            final userData = usersData[i];
            if (userData is Map<String, dynamic>) {
              try {
                final user = User.fromJson(userData);
                users.add(user);
                print('✅ User $i: ${user.fullName}');
              } catch (e) {
                print('❌ Error parsing user $i: $e');
                // Continue with other users
              }
            } else {
              print('⚠️ Invalid user data at index $i: ${userData.runtimeType}');
            }
          }
          
          print('✅ Successfully parsed ${users.length} users');
          
          return ListResponse<User>(
            items: users,
            pagination: paginationData != null ? PaginationData.fromJson(paginationData) : null,
          );
          
        } catch (e) {
          print('❌ Error in UserService.getAllUsers: $e');
          throw Exception('Failed to process users data: $e');
        }
      },
    );
  }

  // Get user by ID
  Future<ApiResponse<User>> getUserById(String id) async {
    return await _apiService.get<User>(
      '${ApiConstants.users.list}/$id',
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Create new user (admin only)
  Future<ApiResponse<User>> createUser(Map<String, dynamic> userData) async {
    return await _apiService.post<User>(
      ApiConstants.users.create,
      data: userData,
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Update user
  Future<ApiResponse<User>> updateUser(String id, Map<String, dynamic> userData) async {
    return await _apiService.put<User>(
      '${ApiConstants.users.list}/$id',
      data: userData,
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Delete user
  Future<ApiResponse<void>> deleteUser(String id) async {
    return await _apiService.delete('${ApiConstants.users.list}/$id');
  }

  // Activate user
  Future<ApiResponse<User>> activateUser(String id) async {
    return await _apiService.post<User>(
      ApiConstants.users.activate,
      data: {'id': id},
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Deactivate user
  Future<ApiResponse<User>> deactivateUser(String id) async {
    return await _apiService.post<User>(
      ApiConstants.users.deactivate,
      data: {'id': id},
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Reset password
  Future<ApiResponse<Map<String, dynamic>>> resetPassword(String id) async {
    return await _apiService.post<Map<String, dynamic>>(
      ApiConstants.users.resetPassword,
      data: {'id': id},
      fromJson: (json) => json,
    );
  }

  // Get users by department
  Future<ApiResponse<ListResponse<User>>> getUsersByDepartment(String department) async {
    return await getAllUsers(department: department);
  }

  // Get users by role
  Future<ApiResponse<ListResponse<User>>> getUsersByRole(String role) async {
    return await getAllUsers(role: role);
  }

  // Search users
  Future<ApiResponse<ListResponse<User>>> searchUsers(String query) async {
    return await getAllUsers(search: query);
  }

  // Get user statistics
  Future<ApiResponse<Map<String, dynamic>>> getUserStatistics() async {
    return await _apiService.get<Map<String, dynamic>>(
      ApiConstants.users.statistics,
      fromJson: (json) => json,
    );
  }

  // Export users
  Future<ApiResponse<Map<String, dynamic>>> exportUsers({
    String format = 'csv',
    List<String>? filters,
  }) async {
    final data = <String, dynamic>{
      'format': format,
    };
    
    if (filters != null) {
      data['filters'] = filters;
    }
    
    return await _apiService.post<Map<String, dynamic>>(
      ApiConstants.users.export,
      data: data,
      fromJson: (json) => json,
    );
  }

  // Bulk update users
  Future<ApiResponse<Map<String, dynamic>>> bulkUpdateUsers(
    List<String> userIds,
    Map<String, dynamic> updates,
  ) async {
    return await _apiService.post<Map<String, dynamic>>(
      ApiConstants.users.bulkUpdate,
      data: {
        'userIds': userIds,
        'updates': updates,
      },
      fromJson: (json) => json,
    );
  }

  // Get user profile summary
  Future<ApiResponse<Map<String, dynamic>>> getUserProfileSummary(String id) async {
    return await _apiService.get<Map<String, dynamic>>(
      '${ApiConstants.users.profileSummary}/$id',
      fromJson: (json) => json,
    );
  }

  // Change user password
  Future<ApiResponse<Map<String, dynamic>>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return await _apiService.post<Map<String, dynamic>>(
      '${ApiConstants.users.list}/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      fromJson: (json) => json,
    );
  }

  // Update user profile
  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> profileData) async {
    return await _apiService.put<User>(
      '${ApiConstants.users.list}/profile',
      data: profileData,
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Upload profile picture
  Future<ApiResponse<Map<String, dynamic>>> uploadProfilePicture(
    String filePath,
  ) async {
    // This would typically use multipart upload
    return await _apiService.post<Map<String, dynamic>>(
      '${ApiConstants.users.list}/profile-picture',
      data: {'filePath': filePath},
      fromJson: (json) => json,
    );
  }

  // Get user attendance summary
  Future<ApiResponse<Map<String, dynamic>>> getUserAttendanceSummary(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    
    return await _apiService.get<Map<String, dynamic>>(
      '${ApiConstants.users.list}/$userId/attendance-summary',
      queryParameters: queryParams,
      fromJson: (json) => json,
    );
  }

  // Get user letters summary
  Future<ApiResponse<Map<String, dynamic>>> getUserLettersSummary(String userId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '${ApiConstants.users.list}/$userId/letters-summary',
      fromJson: (json) => json,
    );
  }

  // Validate user credentials
  Future<ApiResponse<Map<String, dynamic>>> validateCredentials(
    String email,
    String password,
  ) async {
    return await _apiService.post<Map<String, dynamic>>(
      '${ApiConstants.users.list}/validate-credentials',
      data: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => json,
    );
  }

  // Check email availability
  Future<ApiResponse<Map<String, dynamic>>> checkEmailAvailability(String email) async {
    return await _apiService.get<Map<String, dynamic>>(
      '${ApiConstants.users.list}/check-email',
      queryParameters: {'email': email},
      fromJson: (json) => json,
    );
  }

  // Check employee ID availability
  Future<ApiResponse<Map<String, dynamic>>> checkEmployeeIdAvailability(String employeeId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '${ApiConstants.users.list}/check-employee-id',
      queryParameters: {'employeeId': employeeId},
      fromJson: (json) => json,
    );
  }
}