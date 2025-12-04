import 'package:dio/dio.dart';

void main() async {
  print('🧪 Testing assignments endpoint manually...');
  
  try {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Step 1: Login
    print('🔐 Step 1: Logging in...');
    final loginData = {
      'email': 'user@gmail.com',
      'password': 'user123'
    };

    final loginResponse = await dio.post('/api/auth/login', data: loginData);
    print('✅ Login successful: ${loginResponse.statusCode}');
    
    final token = loginResponse.data['data']['token'];
    print('🔑 Token received: ${token.substring(0, 20)}...');

    // Step 2: Test assignments endpoint
    print('📋 Step 2: Getting upcoming assignments...');
    final assignmentsResponse = await dio.get(
      '/api/assignments/upcoming',
      options: Options(headers: {'Authorization': 'Bearer $token'})
    );

    print('✅ Assignments response: ${assignmentsResponse.statusCode}');
    print('📊 Response data: ${assignmentsResponse.data}');
    
    if (assignmentsResponse.data['data'] != null) {
      final assignments = assignmentsResponse.data['data']['assignments'];
      print('📋 Found ${assignments.length} assignments');
      
      for (var assignment in assignments) {
        print('  - ${assignment['title']} (Due: ${assignment['dueDate']})');
      }
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}