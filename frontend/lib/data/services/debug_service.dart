import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

// Simple debug service to test connectivity
class DebugService {
  static Future<void> testBackendConnectivity() async {
    try {
      // Test 1: Basic connectivity
      print('🧪 Testing basic connectivity to backend...');
      
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl.replaceAll('/api', ''),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      // Test health endpoint
      final healthResponse = await dio.get('/health');
      print('✅ Health check: ${healthResponse.statusCode}');
      
      // Test assignments test endpoint
      final testResponse = await dio.get(ApiConstants.assignments.test);
      print('✅ Assignments test: ${testResponse.statusCode}');
      print('📄 Test response: ${testResponse.data}');
      
    } catch (e) {
      print('❌ Connectivity test failed: $e');
    }
  }
  
  static Future<void> testWithAuth() async {
    try {
      print('🧪 Testing with authentication...');
      
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl.replaceAll('/api', ''),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      // Login first
      final loginData = {
        'email': 'user@gmail.com',
        'password': 'user123'
      };
      
      final loginResponse = await dio.post(ApiConstants.auth.login, data: loginData);
      print('✅ Login: ${loginResponse.statusCode}');
      
      final token = loginResponse.data['data']['token'];
      print('🔑 Got token: ${token.substring(0, 20)}...');
      
      // Test assignments with auth
      final authResponse = await dio.get(
        ApiConstants.assignments.upcoming,
        options: Options(headers: {'Authorization': 'Bearer $token'})
      );
      print('✅ Assignments with auth: ${authResponse.statusCode}');
      print('📄 Assignments count: ${authResponse.data['data']['count']}');
      
    } catch (e) {
      print('❌ Auth test failed: $e');
    }
  }
  
  // Instance methods for widget testing
  Future<bool> testBasicConnectivity() async {
    try {
      print('🧪 [DebugService] Testing basic connectivity...');
      
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl.replaceAll('/api', ''),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      final response = await dio.get('/health');
      print('✅ [DebugService] Health check: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [DebugService] Basic connectivity failed: $e');
      return false;
    }
  }
  
  Future<bool> testAuthEndpoint() async {
    try {
      print('🧪 [DebugService] Testing auth endpoint...');
      
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl.replaceAll('/api', ''),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      final loginData = {
        'email': 'user@gmail.com',
        'password': 'user123'
      };
      
      final response = await dio.post(ApiConstants.auth.login, data: loginData);
      print('✅ [DebugService] Auth test: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['data']['token'] != null) {
        // Store token for next test
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data['data']['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [DebugService] Auth test failed: $e');
      return false;
    }
  }
  
  Future<bool> testAssignmentsEndpoint() async {
    try {
      print('🧪 [DebugService] Testing assignments endpoint...');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        print('❌ [DebugService] No token available for assignments test');
        return false;
      }
      
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl.replaceAll('/api', ''),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      final response = await dio.get(
        ApiConstants.assignments.upcoming,
        options: Options(headers: {'Authorization': 'Bearer $token'})
      );
      
      print('✅ [DebugService] Assignments test: ${response.statusCode}');
      print('📄 [DebugService] Assignments data: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [DebugService] Assignments test failed: $e');
      return false;
    }
  }
}