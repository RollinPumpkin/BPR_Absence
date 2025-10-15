import 'dart:convert';
import 'package:http/http.dart' as http;

// Simple test to fetch users data
Future<void> testFetchUsers() async {
  const String baseUrl = 'http://localhost:3000/api';
  const String token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjNkNTJhMjY2MTBjOWIwMTdkZDRhNzdhMWQ3YzI2N2VhYWNlOWQ0NjMiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiU3VwZXIgQWRtaW5pc3RyYXRvciIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9icHItYWJzZW5zLWZpcmViYXNlIiwiYXVkIjoiYnByLWFic2Vucy1maXJlYmFzZSIsImF1dGhfdGltZSI6MTczNDI2MDQwNCwidXNlcl9pZCI6ImdBSHdNZEo4V09SRVZDeFVTeUduTUdmdTdwRzIiLCJzdWIiOiJnQUh3TWRKOFdPUkVWQ3hVU3lHbk1HZnU3cEcyIiwiaWF0IjoxNzM0MjYwNDA0LCJleHAiOjE3MzQyNjQwMDQsImVtYWlsIjoiYWRtaW5AZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsiYWRtaW5AZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.Lm1t8Q0qUFY0LJZuSL-1J3-4fqJlQpMJrOlvb3m2QLvZrJxcfRGZXKqWM3KN5oQJR9YZo5aGqLpE8oQEVCMbBF-XsqNfGhHlR2LzGbJzCeJsOGMbR3uZoJm9wOQD-YvQo3gQ8k1iE5wP8hF2dMlQV6JoWQH4aQGfI2Lk8n5Qj-jM7';

  try {
    print('🧪 Testing direct HTTP call to /api/admin/users...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users?page=1&limit=5'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('📊 Status Code: ${response.statusCode}');
    print('📊 Response Headers: ${response.headers}');
    print('📊 Response Body Length: ${response.body.length}');
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('✅ Response JSON Structure:');
      print('   - success: ${jsonData['success']}');
      print('   - data type: ${jsonData['data'].runtimeType}');
      
      if (jsonData['data'] != null) {
        final data = jsonData['data'];
        print('   - data.users type: ${data['users'].runtimeType}');
        print('   - data.users length: ${data['users'].length}');
        print('   - data.pagination: ${data['pagination']}');
        
        if (data['users'].isNotEmpty) {
          print('📋 First user sample:');
          final firstUser = data['users'][0];
          print('   - id: ${firstUser['id']}');
          print('   - full_name: ${firstUser['full_name']}');
          print('   - email: ${firstUser['email']}');
          print('   - role: ${firstUser['role']}');
          print('   - employee_id: ${firstUser['employee_id']}');
        }
      }
    } else {
      print('❌ Error Response: ${response.body}');
    }
    
  } catch (e) {
    print('❌ Exception: $e');
  }
}

void main() async {
  await testFetchUsers();
}