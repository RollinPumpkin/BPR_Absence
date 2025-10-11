import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/user.dart' as AppUser;
import '../../firebase_options.dart';

class SimpleFirebaseAuthService {
  static final SimpleFirebaseAuthService _instance = SimpleFirebaseAuthService._internal();
  factory SimpleFirebaseAuthService() => _instance;
  SimpleFirebaseAuthService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _isInitialized = false;

  // Initialize Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('🔥 Initializing SimpleFirebaseAuthService...');
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      
      print('✅ SimpleFirebaseAuthService initialized successfully');
    } catch (e) {
      print('❌ SimpleFirebaseAuthService initialization error: $e');
      throw e;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _auth?.currentUser != null;

  // Get current user
  User? get currentUser => _auth?.currentUser;

  // Login with email and password
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      await initialize();
      
      print('🔐 SimpleFirebase login attempt: $email');
      print('🔐 Password length: ${password.length}');
      
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print('✅ Firebase Auth successful: ${credential.user!.uid}');
        
        // Get user data from Firestore
        final userData = await _getUserFromFirestore(credential.user!);
        
        if (userData != null) {
          print('✅ Login complete with user data');
          
          // Save user data to SharedPreferences for compatibility
          await _saveUserToPreferences(userData);
          
          // Get ID token for API calls
          final idToken = await credential.user!.getIdToken();
          
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: 'Login successful',
            data: {
              'user': userData,
              'token': idToken,
            },
          );
        } else {
          await _auth!.signOut();
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: 'User data not found in database',
            data: null,
          );
        }
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Login failed: No user credential',
          data: null,
        );
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'Account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Try again later';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('❌ Login error: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Login failed: $e',
        data: null,
      );
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> _getUserFromFirestore(User firebaseUser) async {
    try {
      print('🔍 Looking for user in Firestore...');
      
      // Try to find by Firebase UID
      QuerySnapshot query = await _firestore!
          .collection('users')
          .where('firebase_uid', isEqualTo: firebaseUser.uid)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        print('✅ Found user by Firebase UID');
        final doc = query.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        
        print('📋 User data: ${data['full_name']} (${data['role']})');
        return data;
      }
      
      // Fallback: find by email
      print('🔄 Trying to find by email...');
      query = await _firestore!
          .collection('users')
          .where('email', isEqualTo: firebaseUser.email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        print('✅ Found user by email');
        final doc = query.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        
        // Update with Firebase UID
        await doc.reference.update({
          'firebase_uid': firebaseUser.uid,
          'updated_at': FieldValue.serverTimestamp(),
        });
        
        print('✅ Updated user with Firebase UID');
        print('📋 User data: ${data['full_name']} (${data['role']})');
        return data;
      }
      
      print('❌ User not found in Firestore');
      return null;
      
    } catch (e) {
      print('❌ Error getting user from Firestore: $e');
      return null;
    }
  }

  // Logout
  Future<ApiResponse<String>> logout() async {
    try {
      await _auth!.signOut();
      
      // Clear SharedPreferences
      await _clearUserFromPreferences();
      
      print('✅ Logout successful');
      
      return ApiResponse<String>(
        success: true,
        message: 'Logout successful',
        data: 'Logged out',
      );
    } catch (e) {
      print('❌ Logout error: $e');
      
      return ApiResponse<String>(
        success: false,
        message: 'Logout failed: $e',
        data: null,
      );
    }
  }

  // Clear user data from SharedPreferences
  Future<void> _clearUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove('user_id');
      await prefs.remove('employee_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      
      print('🧹 User data cleared from SharedPreferences');
      
    } catch (e) {
      print('❌ Error clearing user preferences: $e');
    }
  }

  // Save user data to SharedPreferences for compatibility with letters page
  Future<void> _saveUserToPreferences(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('user_id', userData['id'] ?? '');
      await prefs.setString('employee_id', userData['employee_id'] ?? '');
      await prefs.setString('user_email', userData['email'] ?? '');
      await prefs.setString('user_name', userData['full_name'] ?? '');
      await prefs.setString('user_role', userData['role'] ?? '');
      
      print('💾 User data saved to SharedPreferences');
      print('   user_id: ${userData['id']}');
      print('   employee_id: ${userData['employee_id']}');
      print('   email: ${userData['email']}');
      
    } catch (e) {
      print('❌ Error saving user to preferences: $e');
    }
  }

  // Get current user data
  Future<ApiResponse<AppUser.User>> getCurrentUser() async {
    try {
      if (_auth?.currentUser == null) {
        return ApiResponse<AppUser.User>(
          success: false,
          message: 'No user signed in',
          data: null,
        );
      }
      
      final userData = await _getUserFromFirestore(_auth!.currentUser!);
      
      if (userData != null) {
        // Add required fields with defaults
        userData['status'] = userData['status'] ?? 'active';
        userData['is_active'] = userData['is_active'] ?? true;
        userData['role'] = userData['role'] ?? 'employee';
        
        final user = AppUser.User.fromJson(userData);
        
        return ApiResponse<AppUser.User>(
          success: true,
          message: 'User retrieved',
          data: user,
        );
      } else {
        return ApiResponse<AppUser.User>(
          success: false,
          message: 'User data not found',
          data: null,
        );
      }
    } catch (e) {
      print('❌ Error getting current user: $e');
      
      return ApiResponse<AppUser.User>(
        success: false,
        message: 'Failed to get user: $e',
        data: null,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth?.signOut();
      print('SimpleFirebaseAuth: Signed out successfully');
    } catch (e) {
      print('SimpleFirebaseAuth: Sign out error: $e');
    }
  }

  Future<String?> getIdToken() async {
    try {
      final user = _auth?.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('SimpleFirebaseAuth: Get ID token error: $e');
      return null;
    }
  }
}