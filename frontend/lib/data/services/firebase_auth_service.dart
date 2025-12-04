import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/api_response.dart';
import '../models/user.dart' as AppUser;
import '../../firebase_options.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  User? _currentFirebaseUser;
  AppUser.User? _currentAppUser;

  // Initialize Firebase
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      
      // Listen to auth state changes
      _auth!.authStateChanges().listen(_onAuthStateChanged);
      
      print('✅ Firebase Auth initialized successfully');
    } catch (e) {
      print('❌ Firebase Auth initialization error: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _currentFirebaseUser != null;

  // Get current Firebase user
  User? get currentFirebaseUser => _currentFirebaseUser;

  // Get current app user
  AppUser.User? get currentAppUser => _currentAppUser;

  // Get Firebase ID token
  Future<String?> getIdToken() async {
    try {
      if (_currentFirebaseUser != null) {
        return await _currentFirebaseUser!.getIdToken();
      }
      return null;
    } catch (e) {
      print('❌ Error getting ID token: $e');
      return null;
    }
  }

  // Handle auth state changes
  void _onAuthStateChanged(User? user) async {
    _currentFirebaseUser = user;
    
    if (user != null) {
      // Load user data from Firestore
      await _loadUserData(user.uid);
    } else {
      _currentAppUser = null;
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String firebaseUid) async {
    try {
      print('🔍 Loading user data for Firebase UID: $firebaseUid');
      
      final userQuery = await _firestore!
          .collection('users')
          .where('firebase_uid', isEqualTo: firebaseUid)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        print('✅ Found user by Firebase UID');
        final userData = userQuery.docs.first.data();
        print('📋 Raw user data: $userData');
        
        // Add document ID to userData
        userData['id'] = userQuery.docs.first.id;
        
        // Ensure required fields have default values
        userData['status'] = userData['status'] ?? 'active';
        userData['is_active'] = userData['is_active'] ?? true;
        userData['role'] = userData['role'] ?? 'employee';
        
        print('📋 Processed user data: $userData');
        
        try {
          _currentAppUser = AppUser.User.fromJson(userData);
          print('✅ User object created successfully: ${_currentAppUser!.fullName}');
        } catch (parseError) {
          print('❌ Error parsing user data: $parseError');
          print('📋 Data that failed to parse: $userData');
          return;
        }
      } else {
        print('⚠️ User not found by Firebase UID, trying email fallback...');
        // Try to find user by email as fallback
        final emailQuery = await _firestore!
            .collection('users')
            .where('email', isEqualTo: _currentFirebaseUser!.email)
            .limit(1)
            .get();
            
        if (emailQuery.docs.isNotEmpty) {
          print('✅ Found user by email');
          final userData = emailQuery.docs.first.data();
          print('📋 Raw user data (by email): $userData');
          
          // Add document ID to userData
          userData['id'] = emailQuery.docs.first.id;
          
          // Ensure required fields have default values
          userData['status'] = userData['status'] ?? 'active';
          userData['is_active'] = userData['is_active'] ?? true;
          userData['role'] = userData['role'] ?? 'employee';
          
          print('📋 Processed user data (by email): $userData');
          
          try {
            _currentAppUser = AppUser.User.fromJson(userData);
            print('✅ User object created successfully: ${_currentAppUser!.fullName}');
          } catch (parseError) {
            print('❌ Error parsing user data: $parseError');
            print('📋 Data that failed to parse: $userData');
            return;
          }
          
          // Update Firestore document with Firebase UID
          try {
            await emailQuery.docs.first.reference.update({
              'firebase_uid': firebaseUid,
              'updated_at': FieldValue.serverTimestamp(),
            });
            print('✅ Updated Firestore document with Firebase UID');
          } catch (updateError) {
            print('❌ Error updating Firestore with Firebase UID: $updateError');
          }
        } else {
          print('❌ User data not found in Firestore for UID: $firebaseUid and email: ${_currentFirebaseUser!.email}');
        }
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      print('❌ Error stack trace: ${e.toString()}');
    }
  }

  // Login with email and password
  Future<ApiResponse<AppUser.User>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting Firebase Auth login for: $email');
      print('🔐 Password length: ${password.length}');
      
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print('✅ Firebase Auth login successful, UID: ${credential.user!.uid}');
        _currentFirebaseUser = credential.user;
        
        // Load user data from Firestore
        print('🔄 Loading user data from Firestore...');
        await _loadUserData(credential.user!.uid);
        
        if (_currentAppUser != null) {
          print('✅ Firebase Auth login complete: ${_currentAppUser!.fullName}');
          print('   User ID: ${_currentAppUser!.id}');
          print('   Role: ${_currentAppUser!.role}');
          print('   Email: ${_currentAppUser!.email}');
          
          return ApiResponse<AppUser.User>(
            success: true,
            message: 'Login successful',
            data: _currentAppUser!,
          );
        } else {
          print('❌ User data not found in Firestore after Firebase login');
          await _auth!.signOut();
          return ApiResponse<AppUser.User>(
            success: false,
            message: 'User data not found in Firestore',
            data: null,
          );
        }
      } else {
        print('❌ No user credential returned from Firebase Auth');
        return ApiResponse<AppUser.User>(
          success: false,
          message: 'Login failed: No user credential returned',
          data: null,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed login attempts. Please try again later';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      
      print('❌ Firebase Auth login error: $errorMessage');
      
      return ApiResponse<AppUser.User>(
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('❌ Firebase Auth login error: $e');
      
      return ApiResponse<AppUser.User>(
        success: false,
        message: 'Login failed: $e',
        data: null,
      );
    }
  }

  // Register user (create in both Firebase Auth and Firestore)
  Future<ApiResponse<AppUser.User>> register({
    required String fullName,
    required String email,
    required String password,
    required String employeeId,
    required String department,
    required String position,
    String? phoneNumber,
    String role = 'employee',
  }) async {
    try {
      print('📝 Attempting Firebase Auth registration for: $email');
      
      // Create user in Firebase Auth
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(fullName);
        
        // Create user document in Firestore
        final userData = {
          'firebase_uid': credential.user!.uid,
          'employee_id': employeeId,
          'full_name': fullName,
          'email': email,
          'role': role,
          'department': department,
          'position': position,
          'phone': phoneNumber ?? '',
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        await _firestore!.collection('users').add(userData);
        
        // Load the created user data
        await _loadUserData(credential.user!.uid);
        
        if (_currentAppUser != null) {
          print('✅ Firebase Auth registration successful: ${_currentAppUser!.fullName}');
          
          return ApiResponse<AppUser.User>(
            success: true,
            message: 'Registration successful',
            data: _currentAppUser!,
          );
        } else {
          return ApiResponse<AppUser.User>(
            success: false,
            message: 'Registration failed: Could not load user data',
            data: null,
          );
        }
      } else {
        return ApiResponse<AppUser.User>(
          success: false,
          message: 'Registration failed: No user credential returned',
          data: null,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      
      print('❌ Firebase Auth registration error: $errorMessage');
      
      return ApiResponse<AppUser.User>(
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('❌ Firebase Auth registration error: $e');
      
      return ApiResponse<AppUser.User>(
        success: false,
        message: 'Registration failed: $e',
        data: null,
      );
    }
  }

  // Logout
  Future<ApiResponse<String>> logout() async {
    try {
      await _auth!.signOut();
      _currentFirebaseUser = null;
      _currentAppUser = null;
      
      print('✅ Firebase Auth logout successful');
      
      return ApiResponse<String>(
        success: true,
        message: 'Logout successful',
        data: 'Logged out successfully',
      );
    } catch (e) {
      print('❌ Firebase Auth logout error: $e');
      
      return ApiResponse<String>(
        success: false,
        message: 'Logout failed: $e',
        data: null,
      );
    }
  }

  // Get current user
  Future<ApiResponse<AppUser.User>> getCurrentUser() async {
    try {
      if (_currentAppUser != null) {
        return ApiResponse<AppUser.User>(
          success: true,
          message: 'User retrieved successfully',
          data: _currentAppUser!,
        );
      } else {
        return ApiResponse<AppUser.User>(
          success: false,
          message: 'No user is currently signed in',
          data: null,
        );
      }
    } catch (e) {
      print('❌ Error getting current user: $e');
      
      return ApiResponse<AppUser.User>(
        success: false,
        message: 'Failed to get current user: $e',
        data: null,
      );
    }
  }

  // Reset password
  Future<ApiResponse<String>> resetPassword(String email) async {
    try {
      await _auth!.sendPasswordResetEmail(email: email);
      
      return ApiResponse<String>(
        success: true,
        message: 'Password reset email sent successfully',
        data: 'Password reset email sent',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Password reset failed';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = 'Password reset failed: ${e.message}';
      }
      
      return ApiResponse<String>(
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Password reset failed: $e',
        data: null,
      );
    }
  }
}