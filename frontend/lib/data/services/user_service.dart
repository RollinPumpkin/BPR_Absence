import '../models/api_response.dart';
import '../models/user.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService.instance;

  // Get all users (admin only)
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
      fromJson: (json) => ListResponse<User>.fromJson(
        json,
        (item) => User.fromJson(item),
        'data',
      ),
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
  Future<ApiResponse<User>> createUser({
    required String fullName,
    required String email,
    required String password,
    required String employeeId,
    required String department,
    required String position,
    String? phoneNumber,
    String role = 'employee',
    bool isActive = true,
    DateTime? hireDate,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
  }) async {
    return await _apiService.post<User>(
      ApiConstants.users.create,
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'employee_id': employeeId,
        'department': department,
        'position': position,
        'role': role,
        'is_active': isActive,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (hireDate != null) 'hire_date': hireDate.toIso8601String(),
        if (address != null) 'address': address,
        if (emergencyContact != null) 'emergency_contact': emergencyContact,
        if (emergencyPhone != null) 'emergency_phone': emergencyPhone,
      },
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Update user
  Future<ApiResponse<User>> updateUser({
    required String id,
    String? fullName,
    String? email,
    String? employeeId,
    String? department,
    String? position,
    String? phoneNumber,
    String? role,
    bool? isActive,
    DateTime? hireDate,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
  }) async {
    final data = <String, dynamic>{};
    
    if (fullName != null) data['full_name'] = fullName;
    if (email != null) data['email'] = email;
    if (employeeId != null) data['employee_id'] = employeeId;
    if (department != null) data['department'] = department;
    if (position != null) data['position'] = position;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (role != null) data['role'] = role;
    if (isActive != null) data['is_active'] = isActive;
    if (hireDate != null) data['hire_date'] = hireDate.toIso8601String();
    if (address != null) data['address'] = address;
    if (emergencyContact != null) data['emergency_contact'] = emergencyContact;
    if (emergencyPhone != null) data['emergency_phone'] = emergencyPhone;

    return await _apiService.put<User>(
      '${ApiConstants.users.list}/$id',
      data: data,
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Delete user (admin only)
  Future<ApiResponse<String>> deleteUser(String id) async {
    return await _apiService.delete<String>(
      '${ApiConstants.users.list}/$id',
      fromJson: (json) => json?.toString() ?? 'User deleted successfully',
    );
  }

  // Activate user
  Future<ApiResponse<User>> activateUser(String id) async {
    return await _apiService.put<User>(
      '${ApiConstants.users.activate}/$id',
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Deactivate user
  Future<ApiResponse<User>> deactivateUser(String id) async {
    return await _apiService.put<User>(
      '${ApiConstants.users.deactivate}/$id',
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Reset user password (admin only)
  Future<ApiResponse<String>> resetUserPassword({
    required String id,
    required String newPassword,
  }) async {
    return await _apiService.put<String>(
      '${ApiConstants.users.resetPassword}/$id',
      data: {
        'new_password': newPassword,
      },
      fromJson: (json) => json?.toString() ?? 'Password reset successfully',
    );
  }

  // Get users by department
  Future<ApiResponse<List<User>>> getUsersByDepartment({
    required String department,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'department': department,
    };

    if (isActive != null) queryParams['is_active'] = isActive;

    return await _apiService.get<List<User>>(
      ApiConstants.users.byDepartment,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((item) => User.fromJson(item))
          .toList(),
    );
  }

  // Get users by role
  Future<ApiResponse<List<User>>> getUsersByRole({
    required String role,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'role': role,
    };

    if (isActive != null) queryParams['is_active'] = isActive;

    return await _apiService.get<List<User>>(
      ApiConstants.users.byRole,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((item) => User.fromJson(item))
          .toList(),
    );
  }

  // Search users
  Future<ApiResponse<List<User>>> searchUsers({
    required String query,
    String? department,
    String? role,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
    };

    if (department != null) queryParams['department'] = department;
    if (role != null) queryParams['role'] = role;
    if (isActive != null) queryParams['is_active'] = isActive;

    return await _apiService.get<List<User>>(
      ApiConstants.users.search,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((item) => User.fromJson(item))
          .toList(),
    );
  }

  // Get user statistics (admin only)
  Future<ApiResponse<Map<String, dynamic>>> getUserStatistics() async {
    return await _apiService.get<Map<String, dynamic>>(
      ApiConstants.users.statistics,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Export users data (admin only)
  Future<ApiResponse<String>> exportUsers({
    String? format, // 'excel' or 'pdf'
    String? department,
    String? role,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{};

    if (format != null) queryParams['format'] = format;
    if (department != null) queryParams['department'] = department;
    if (role != null) queryParams['role'] = role;
    if (isActive != null) queryParams['is_active'] = isActive;

    return await _apiService.get<String>(
      ApiConstants.users.export,
      queryParameters: queryParams,
      fromJson: (json) => json?.toString() ?? '',
    );
  }

  // Bulk update users (admin only)
  Future<ApiResponse<String>> bulkUpdateUsers({
    required List<String> userIds,
    String? department,
    String? position,
    String? role,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{
      'user_ids': userIds,
    };

    if (department != null) data['department'] = department;
    if (position != null) data['position'] = position;
    if (role != null) data['role'] = role;
    if (isActive != null) data['is_active'] = isActive;

    return await _apiService.put<String>(
      ApiConstants.users.bulkUpdate,
      data: data,
      fromJson: (json) => json?.toString() ?? 'Users updated successfully',
    );
  }

  // Get user profile summary
  Future<ApiResponse<Map<String, dynamic>>> getUserProfileSummary(String id) async {
    return await _apiService.get<Map<String, dynamic>>(
      '${ApiConstants.users.profileSummary}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
