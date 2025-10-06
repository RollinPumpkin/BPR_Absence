import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/services/assignment_service.dart';

void main() async {
  print('🧪 Flutter Assignment Test');
  
  final apiService = ApiService.instance;
  final assignmentService = AssignmentService();
  
  try {
    // Step 1: Login
    print('🔐 Step 1: Login test...');
    final loginResponse = await apiService.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': 'user@gmail.com',
        'password': 'user123'
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
    
    print('✅ Login response success: ${loginResponse.success}');
    print('📄 Login response message: ${loginResponse.message}');
    if (loginResponse.data != null) {
      print('🔑 Has token: ${loginResponse.data!.containsKey('token')}');
    }
    
    if (!loginResponse.success) {
      print('❌ Login failed, stopping test');
      return;
    }
    
    // Step 2: Test connection
    print('\n📡 Step 2: Connection test...');
    final connectionTest = await assignmentService.testConnection();
    print('📡 Connection test result: $connectionTest');
    
    // Step 3: Get assignments
    print('\n📋 Step 3: Get assignments...');
    final assignments = await assignmentService.getUpcomingAssignments();
    print('📋 Retrieved ${assignments.length} assignments');
    
    for (var assignment in assignments) {
      print('  - ${assignment.title} (Due: ${assignment.dueDate}, Priority: ${assignment.priority})');
    }
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('📍 Stack trace: $stackTrace');
  }
}