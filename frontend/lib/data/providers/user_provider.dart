import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/user_statistics.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:frontend/data/services/api_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService.instance;
  
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  bool _hasMore = false;
  UserStatistics? _statistics;
  
  // Filters
  String? _searchQuery;
  String? _departmentFilter;
  String? _positionFilter;
  String? _roleFilter;
  bool? _isActiveFilter;
  bool _showNewDataOnly = false; // New: filter for recently created data

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalUsers => _totalUsers;
  bool get hasMore => _hasMore;
  
  // Filter getters
  String? get searchQuery => _searchQuery;
  String? get departmentFilter => _departmentFilter;
  String? get positionFilter => _positionFilter;
  String? get roleFilter => _roleFilter;
  bool? get isActiveFilter => _isActiveFilter;
  bool get showNewDataOnly => _showNewDataOnly; // New getter
  UserStatistics? get statistics => _statistics;

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Fetch all users with pagination and filters
  Future<void> fetchUsers({
    bool refresh = false,
    int page = 1,
    int limit = 20,
  }) async {
    if (refresh) {
      _users.clear();
      _currentPage = 1;
    }

    _setLoading(true);
    _clearError();

    try {
      print('UserProvider: Fetching users with page=$page, limit=$limit');
      final response = await _userService.getAllUsers(
        page: page,
        limit: limit,
        search: _searchQuery,
        department: _departmentFilter,
        position: _positionFilter,
        role: _roleFilter,
        isActive: _isActiveFilter,
      );

      print('UserProvider: Response success=${response.success}, data=${response.data != null}');
      if (response.success && response.data != null) {
        print('📋 UserProvider: Processing response data...');
        try {
          final listResponse = response.data!;
          print('📋 UserProvider: ListResponse type: ${listResponse.runtimeType}');
          print('📋 UserProvider: ListResponse items count: ${listResponse.items.length}');
          
          // Filter out any null items, terminated employees, and validate each item
          final validItems = <User>[];
          for (int i = 0; i < listResponse.items.length; i++) {
            final item = listResponse.items[i];
            if (item.status != 'terminated') {  // Filter out terminated employees
              // Apply client-side filter for new data if enabled
              if (_showNewDataOnly && item.createdAt != null) {
                final daysSinceCreation = DateTime.now().difference(item.createdAt!).inDays;
                if (daysSinceCreation > 7) {
                  // Skip this item as it's older than 7 days
                  continue;
                }
              }
              
              validItems.add(item);
              print('📋 UserProvider: Valid item $i: ${item.fullName} (${item.role}) - Status: ${item.status}');
            } else if (item.status == 'terminated') {
              print('⚠️ UserProvider: Terminated employee filtered out: ${item.fullName}');
            } else {
              print('⚠️ UserProvider: Null item found at index $i, skipping');
            }
          }
          
          if (refresh || page == 1) {
            _users = validItems;
            print('📋 UserProvider: Set _users to ${_users.length} valid items (refresh/page1)');
          } else {
            _users.addAll(validItems);
            print('📋 UserProvider: Added ${validItems.length} valid items, total now: ${_users.length}');
          }
          
          // Sort users by createdAt (newest to oldest)
          _users.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1; // null values go to the end
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!); // Descending order (newest first)
          });
          print('📋 UserProvider: Sorted ${_users.length} users by createdAt (newest first)');
          
          if (listResponse.pagination != null) {
            final pagination = listResponse.pagination!;
            _currentPage = pagination.currentPage;
            _totalPages = pagination.totalPages;
            _totalUsers = pagination.totalRecords;
            _hasMore = pagination.hasNextPage;
          } else {
            // No pagination data, assume single page
            _currentPage = 1;
            _totalPages = 1;
            _totalUsers = listResponse.items.length;
            _hasMore = false;
          }
          
          print('📊 UserProvider: Loaded ${_users.length} users (Page $_currentPage/$_totalPages)');
        } catch (e) {
          print('❌ UserProvider: Error processing response data: $e');
          print('❌ UserProvider: Response data: ${response.data}');
          _setError('Error processing user data: ${e.toString()}');
          return;
        }
      } else {
        _setError(response.message ?? 'Failed to fetch users');
      }
    } catch (e) {
      print('❌ UserProvider fetchUsers error: $e');
      print('❌ UserProvider error type: ${e.runtimeType}');
      print('❌ UserProvider stack trace: ${StackTrace.current}');
      _setError('Error fetching users: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load more users (pagination)
  Future<void> loadMoreUsers() async {
    if (!_hasMore || _isLoading) return;
    
    await fetchUsers(page: _currentPage + 1);
  }

  // Refresh users list
  Future<void> refreshUsers() async {
    await fetchUsers(refresh: true);
    await fetchStatistics();
  }

  // Search users
  Future<void> searchUsers(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    await fetchUsers(refresh: true);
  }

  // Filter by department
  Future<void> filterByDepartment(String? department) async {
    _departmentFilter = department;
    await fetchUsers(refresh: true);
  }

  // Filter by position
  Future<void> filterByPosition(String? position) async {
    _positionFilter = position;
    await fetchUsers(refresh: true);
  }

  // Filter by role
  Future<void> filterByRole(String? role) async {
    _roleFilter = role;
    await fetchUsers(refresh: true);
  }

  // Filter by active status
  Future<void> filterByActiveStatus(bool? isActive) async {
    _isActiveFilter = isActive;
    await fetchUsers(refresh: true);
  }

  // Filter by new data (created within last 7 days)
  Future<void> filterByNewData(bool showNewOnly) async {
    _showNewDataOnly = showNewOnly;
    await fetchUsers(refresh: true);
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _searchQuery = null;
    _departmentFilter = null;
    _positionFilter = null;
    _roleFilter = null;
    _isActiveFilter = null;
    _showNewDataOnly = false;
    await fetchUsers(refresh: true);
  }

  // Get user by ID
  User? getUserById(String id) {
    return _users.where((user) => user.id == id).firstOrNull;
  }

  // Get user by employee ID
  User? getUserByEmployeeId(String employeeId) {
    return _users.where((user) => user.employeeId == employeeId).firstOrNull;
  }

  // Get users by department
  List<User> getUsersByDepartment(String department) {
    return _users.where((user) => user.department == department).toList();
  }

  // Get users by role
  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Get active users
  List<User> getActiveUsers() {
    return _users.where((user) => user.isActive).toList();
  }

  // Get departments list
  List<String> getDepartments() {
    return _users
        .where((user) => user.department != null)
        .map((user) => user.department!)
        .toSet()
        .toList()
      ..sort();
  }

  // Get positions list
  List<String> getPositions() {
    return _users
        .where((user) => user.position != null)
        .map((user) => user.position!)
        .toSet()
        .toList()
      ..sort();
  }

  // Get roles list
  List<String> getRoles() {
    return _users
        .map((user) => user.role)
        .toSet()
        .toList()
      ..sort();
  }

  // Add user to local list (after creation)
  void addUser(User user) {
    _users.insert(0, user);
    _totalUsers++;
    notifyListeners();
  }

  // Update user in local list
  void updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  // Remove user from local list
  void removeUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
    _totalUsers--;
    notifyListeners();
  }

  // Get statistics
  Map<String, int> getUserStatistics() {
    // Use total from pagination for accurate count
    final total = _totalUsers > 0 ? _totalUsers : _users.length;
    final active = _users.where((user) => user.isActive).length;
    final inactive = total - active;
    final admins = _users.where((user) => user.role == 'admin' || user.role == 'super_admin').length;
    final employees = _users.where((user) => user.role == 'employee').length;

    print('📊 UserProvider getUserStatistics:');
    print('   - Total (from pagination): $_totalUsers');
    print('   - Total (calculated): $total');
    print('   - Active (from loaded users): $active');
    print('   - Loaded users count: ${_users.length}');

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'admins': admins,
      'employees': employees,
    };
  }

  // Fetch and update statistics from API
  Future<void> fetchStatistics() async {
    try {
      print('📊 UserProvider: Fetching statistics from /api/users/stats...');
      
      // Use the same stats endpoint as dashboard for consistency
      final response = await _apiService.get<Map<String, dynamic>>(
        '/users/stats',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        final apiStats = response.data!;
        print('📊 UserProvider: API stats received: $apiStats');
        
        // Calculate role distribution from loaded users (for roles breakdown)
        final roleDistribution = <String, int>{};
        final departmentDistribution = <String, int>{};
        
        for (final user in _users) {
          roleDistribution[user.role] = (roleDistribution[user.role] ?? 0) + 1;
        }
        
        for (final user in _users) {
          if (user.department != null) {
            departmentDistribution[user.department!] = (departmentDistribution[user.department!] ?? 0) + 1;
          }
        }
        
        _statistics = UserStatistics(
          totalUsers: apiStats['total'] ?? 0,
          activeUsers: apiStats['active'] ?? 0,
          inactiveUsers: apiStats['resign'] ?? 0,
          roleDistribution: roleDistribution,
          departmentDistribution: departmentDistribution,
        );
        
        print('📊 UserProvider: Statistics updated - Total: ${_statistics!.totalUsers}, Active: ${_statistics!.activeUsers}');
      } else {
        print('❌ UserProvider: Failed to fetch stats from API: ${response.message}');
        
        // Fallback to local calculation
        final localStats = getUserStatistics();
        final roleDistribution = <String, int>{};
        final departmentDistribution = <String, int>{};
        
        for (final user in _users) {
          roleDistribution[user.role] = (roleDistribution[user.role] ?? 0) + 1;
        }
        
        for (final user in _users) {
          if (user.department != null) {
            departmentDistribution[user.department!] = (departmentDistribution[user.department!] ?? 0) + 1;
          }
        }
        
        _statistics = UserStatistics(
          totalUsers: localStats['total'] ?? 0,
          activeUsers: localStats['active'] ?? 0,
          inactiveUsers: localStats['inactive'] ?? 0,
          roleDistribution: roleDistribution,
          departmentDistribution: departmentDistribution,
        );
      }

      notifyListeners();
    } catch (e) {
      print('❌ UserProvider: Error fetching statistics: $e');
    }
  }

  // Initialize - fetch initial data
  Future<void> initialize() async {
    print('📊 UserProvider: Starting initialization...');
    
    // Test simple API call first
    await testSimpleApiCall();
    
    await fetchUsers(refresh: true);
    await fetchStatistics();
    print('📊 UserProvider: Initialization complete');
  }

  // Test method to see raw API response
  Future<void> testSimpleApiCall() async {
    try {
      print('🧪 Testing simple API call...');
      
      // Check current user info first
      print('👤 Checking current user...');
      // We need to get current user from AuthProvider
      
      // Try to refresh token first
      print('🔄 Attempting to validate/refresh token...');
      final tokenValid = await _authService.validateAndRefreshToken();
      print('🔄 Token validation result: $tokenValid');
      
      final response = await _userService.getAllUsers(page: 1, limit: 5);
      print('🧪 Raw response success: ${response.success}');
      print('🧪 Raw response message: ${response.message}');
      if (!response.success) {
        print('❌ API Error Details: ${response.message}');
        print('❌ API Error Code: ${response.data}');
      }
      print('🧪 Raw response data type: ${response.data.runtimeType}');
      if (response.data != null) {
        print('🧪 Raw response data: ${response.data}');
      }
    } catch (e) {
      print('🧪 Test API call error: $e');
    }
  }

  // Current user management
  User? _currentUser;
  Map<String, dynamic>? _userStatistics;

  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userStatistics => _userStatistics;

  // Get current user profile
  Future<void> getCurrentUser() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      print('👤 UserProvider: Fetching current user profile...');
      final response = await _userService.getCurrentUser();
      
      print('👤 UserProvider: Response success: ${response.success}');
      print('👤 UserProvider: Response message: ${response.message}');
      print('👤 UserProvider: Response data: ${response.data}');
      
      if (response.success && response.data != null) {
        print('👤 UserProvider: Creating User from JSON...');
        _currentUser = User.fromJson(response.data!);
        print('👤 UserProvider: Current user loaded: ${_currentUser!.fullName}');
        print('👤 UserProvider: Phone: ${_currentUser!.phone}');
        print('👤 UserProvider: Position: ${_currentUser!.position}');
        print('👤 UserProvider: Department: ${_currentUser!.department}');
        await getUserStatisticsForUser(_currentUser!.id);
      } else {
        _errorMessage = response.message ?? 'Failed to load user profile';
        print('❌ UserProvider: Failed to load profile: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Error loading user profile: $e';
      print('❌ Error in getCurrentUser: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(String userId, Map<String, dynamic> userData) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _userService.updateUser(userId, userData);
      
      if (response.success) {
        // Update current user if it's the same user
        if (_currentUser?.id == userId && response.data != null) {
          _currentUser = response.data;
        }
        
        // Update user in the list if it exists
        final userIndex = _users.indexWhere((user) => user.id == userId);
        if (userIndex != -1 && response.data != null) {
          _users[userIndex] = response.data!;
        }
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      print('❌ Error in updateProfile: $e');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Get user statistics with user ID
  Future<void> getUserStatisticsForUser(String userId) async {
    try {
      final response = await _userService.getUserStatisticsById(userId);
      
      if (response.success && response.data != null) {
        _userStatistics = response.data;
      }
    } catch (e) {
      print('❌ Error getting user statistics: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _users.clear();
    _currentUser = null;
    _userStatistics = null;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _totalUsers = 0;
    notifyListeners();
  }
}