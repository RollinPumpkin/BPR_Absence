import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../data/providers/auth_provider.dart';

class UserContextService with ChangeNotifier {
  static final UserContextService _instance = UserContextService._internal();
  factory UserContextService() => _instance;
  UserContextService._internal();

  User? _currentUser;
  AuthProvider? _authProvider;

  // Getters
  User? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id;
  String? get currentUserEmployeeId => _currentUser?.employeeId;
  String? get currentUserName => _currentUser?.fullName;
  String? get currentUserRole => _currentUser?.role;
  bool get isLoggedIn => _currentUser != null;

  // Initialize with auth provider
  void initialize(AuthProvider authProvider) {
    _authProvider = authProvider;
    _currentUser = authProvider.currentUser;
    
    // Listen to auth provider changes
    authProvider.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (_authProvider != null) {
      final newUser = _authProvider!.currentUser;
      if (newUser != _currentUser) {
        _currentUser = newUser;
        notifyListeners();
      }
    }
  }

  // Update current user
  void updateUser(User? user) {
    if (_currentUser != user) {
      _currentUser = user;
      notifyListeners();
    }
  }

  // Clear user data
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  // Check if user is admin
  bool get isAdmin => hasRole('admin') || hasRole('account_officer');

  // Check if user is HR
  bool get isHR => hasRole('hr');

  // Check if user is manager
  bool get isManager => hasRole('manager');

  // Check if user is employee
  bool get isEmployee => hasRole('employee');

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthChanged);
    super.dispose();
  }
}