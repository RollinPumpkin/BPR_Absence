import '../models/api_response.dart';
import '../models/user.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'user_service.dart';

class EmployeeSyncService {
  final ApiService _apiService = ApiService.instance;
  final UserService _userService = UserService();

  // Sync all users from DB to employee database
  Future<ApiResponse<Map<String, dynamic>>> syncUsersToEmployeeDatabase() async {
    try {
      print('🔄 Starting user sync to employee database...');
      
      // Step 1: Get all users from the database
      print('📥 Step 1: Fetching all users from database...');
      final usersResponse = await _userService.getAllUsers(
        page: 1,
        limit: 1000, // Get all users at once
      );
      
      if (!usersResponse.success || usersResponse.data == null) {
        print('❌ Failed to fetch users: ${usersResponse.message}');
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Failed to fetch users: ${usersResponse.message}',
          data: null,
        );
      }
      
      final users = usersResponse.data!.items;
      print('📊 Found ${users.length} users to sync');
      
      if (users.isEmpty) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'No users found to sync',
          data: {'syncedCount': 0, 'skippedCount': 0, 'errorCount': 0},
        );
      }
      
      // Step 2: Process each user for employee database
      print('🔄 Step 2: Processing users for employee database...');
      int syncedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;
      List<String> syncedUsers = [];
      List<String> skippedUsers = [];
      List<String> errorUsers = [];
      
      for (final user in users) {
        try {
          print('🔄 Processing user: ${user.fullName} (${user.employeeId})');
          
          // Convert user to employee format
          final employeeData = _convertUserToEmployeeData(user);
          print('📋 Employee data for ${user.fullName}: $employeeData');
          
          // Check if user should be synced (only employees and active users)
          if (!_shouldSyncUser(user)) {
            print('⏭️ Skipping user ${user.fullName}: ${_getSkipReason(user)}');
            skippedCount++;
            skippedUsers.add('${user.fullName} (${_getSkipReason(user)})');
            continue;
          }
          
          // Step 3: Sync to employee database
          final syncResult = await _syncUserToEmployeeDB(employeeData);
          
          if (syncResult.success) {
            syncedCount++;
            syncedUsers.add(user.fullName);
            print('✅ Successfully synced user: ${user.fullName}');
          } else {
            errorCount++;
            errorUsers.add('${user.fullName}: ${syncResult.message}');
            print('❌ Failed to sync user ${user.fullName}: ${syncResult.message}');
          }
          
        } catch (e) {
          errorCount++;
          errorUsers.add('${user.fullName}: $e');
          print('❌ Error processing user ${user.fullName}: $e');
        }
        
        // Add small delay to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Step 4: Return sync summary
      final summary = {
        'totalUsers': users.length,
        'syncedCount': syncedCount,
        'skippedCount': skippedCount,
        'errorCount': errorCount,
        'syncedUsers': syncedUsers,
        'skippedUsers': skippedUsers,
        'errorUsers': errorUsers,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      print('🎯 Sync completed!');
      print('📊 Summary: ${summary}');
      
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'User sync completed successfully',
        data: summary,
      );
      
    } catch (e) {
      print('❌ Error in syncUsersToEmployeeDatabase: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Sync failed: $e',
        data: null,
      );
    }
  }

  // Convert User model to employee database format
  Map<String, dynamic> _convertUserToEmployeeData(User user) {
    return {
      'employee_id': user.employeeId,
      'full_name': user.fullName,
      'email': user.email,
      'phone': user.phone,
      'department': user.department,
      'position': user.position,
      'role': user.role,
      'status': user.status,
      'is_active': user.isActive,
      'hire_date': user.hireDate?.toIso8601String(),
      'salary': user.salary,
      'address': user.address,
      'emergency_contact': user.emergencyContact,
      'emergency_phone': user.emergencyPhone,
      'date_of_birth': user.dateOfBirth?.toIso8601String(),
      'gender': user.gender,
      'marital_status': user.maritalStatus,
      'national_id': user.nationalId,
      'bank_account': user.bankAccount,
      'bank_name': user.bankName,
      'profile_picture': user.profilePicture,
      'synced_from_user_id': user.id,
      'synced_at': DateTime.now().toIso8601String(),
    };
  }

  // Check if user should be synced to employee database
  bool _shouldSyncUser(User user) {
    // Sync only employees and active users
    if (user.role == 'super_admin' || user.role == 'admin') {
      return false; // Don't sync admin users to employee database
    }
    
    if (!user.isActive) {
      return false; // Don't sync inactive users
    }
    
    if (user.status != 'active') {
      return false; // Don't sync non-active status users
    }
    
    return true;
  }

  // Get reason why user was skipped
  String _getSkipReason(User user) {
    if (user.role == 'super_admin' || user.role == 'admin') {
      return 'Admin user';
    }
    
    if (!user.isActive) {
      return 'Inactive user';
    }
    
    if (user.status != 'active') {
      return 'Non-active status';
    }
    
    return 'Unknown reason';
  }

  // Sync individual user to employee database
  Future<ApiResponse<Map<String, dynamic>>> _syncUserToEmployeeDB(
    Map<String, dynamic> employeeData
  ) async {
    try {
      // Use the create employee endpoint to add user to employee database
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.users.create,
        data: employeeData,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      return response;
      
    } catch (e) {
      print('❌ Error syncing user to employee DB: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Sync error: $e',
        data: null,
      );
    }
  }

  // Get sync status/history
  Future<ApiResponse<Map<String, dynamic>>> getSyncStatus() async {
    try {
      // This would call a backend endpoint to get sync history
      // For now, return basic info
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Sync status retrieved',
        data: {
          'last_sync': 'Not implemented yet',
          'total_synced': 'Not implemented yet',
          'sync_status': 'Ready',
        },
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Failed to get sync status: $e',
        data: null,
      );
    }
  }

  // Sync specific users by IDs
  Future<ApiResponse<Map<String, dynamic>>> syncSpecificUsers(
    List<String> userIds
  ) async {
    try {
      print('🔄 Starting specific user sync for ${userIds.length} users...');
      
      int syncedCount = 0;
      int errorCount = 0;
      List<String> syncedUsers = [];
      List<String> errorUsers = [];
      
      for (final userId in userIds) {
        try {
          // Get user by ID
          final userResponse = await _userService.getUserById(userId);
          
          if (!userResponse.success || userResponse.data == null) {
            errorCount++;
            errorUsers.add('User ID $userId: Not found');
            continue;
          }
          
          final user = userResponse.data!;
          
          if (!_shouldSyncUser(user)) {
            errorCount++;
            errorUsers.add('${user.fullName}: ${_getSkipReason(user)}');
            continue;
          }
          
          final employeeData = _convertUserToEmployeeData(user);
          final syncResult = await _syncUserToEmployeeDB(employeeData);
          
          if (syncResult.success) {
            syncedCount++;
            syncedUsers.add(user.fullName);
          } else {
            errorCount++;
            errorUsers.add('${user.fullName}: ${syncResult.message}');
          }
          
        } catch (e) {
          errorCount++;
          errorUsers.add('User ID $userId: $e');
        }
      }
      
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Specific user sync completed',
        data: {
          'targetUsers': userIds.length,
          'syncedCount': syncedCount,
          'errorCount': errorCount,
          'syncedUsers': syncedUsers,
          'errorUsers': errorUsers,
        },
      );
      
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Specific sync failed: $e',
        data: null,
      );
    }
  }
}