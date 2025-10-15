import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/user_statistics.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/data/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  
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
          
          // Filter out any null items and validate each item
          final validItems = <User>[];
          for (int i = 0; i < listResponse.items.length; i++) {
            final item = listResponse.items[i];
            if (item != null) {
              validItems.add(item);
              print('📋 UserProvider: Valid item $i: ${item.fullName} (${item.role})');
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

  // Clear all filters
  Future<void> clearFilters() async {
    _searchQuery = null;
    _departmentFilter = null;
    _positionFilter = null;
    _roleFilter = null;
    _isActiveFilter = null;
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
    final total = _users.length;
    final active = _users.where((user) => user.isActive).length;
    final inactive = total - active;
    final admins = _users.where((user) => user.role == 'admin' || user.role == 'super_admin').length;
    final employees = _users.where((user) => user.role == 'employee').length;

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'admins': admins,
      'employees': employees,
    };
  }

  // Fetch and update statistics
  Future<void> fetchStatistics() async {
    try {
      final stats = getUserStatistics();
      final roleDistribution = <String, int>{};
      final departmentDistribution = <String, int>{};
      
      // Calculate role distribution
      for (final user in _users) {
        roleDistribution[user.role] = (roleDistribution[user.role] ?? 0) + 1;
      }
      
      // Calculate department distribution
      for (final user in _users) {
        if (user.department != null) {
          departmentDistribution[user.department!] = (departmentDistribution[user.department!] ?? 0) + 1;
        }
      }
      
      _statistics = UserStatistics(
        totalUsers: stats['total'] ?? 0,
        activeUsers: stats['active'] ?? 0,
        inactiveUsers: stats['inactive'] ?? 0,
        roleDistribution: roleDistribution,
        departmentDistribution: departmentDistribution,
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
    }
  }

  // Initialize - fetch initial data
  Future<void> initialize() async {
    print('📊 UserProvider: Starting initialization...');
    
    // Test simple API call first
    await testSimpleApiCall();
    
    await fetchUsers(refresh: true);
    // Temporarily disable fetchStatistics to debug
    // await fetchStatistics();
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

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _users.clear();
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _totalUsers = 0;
    notifyListeners();
  }
}