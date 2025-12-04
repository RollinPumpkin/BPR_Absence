import 'package:flutter/material.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/services/assignment_service.dart';

class AssignmentTestPage extends StatefulWidget {
  const AssignmentTestPage({super.key});

  @override
  State<AssignmentTestPage> createState() => _AssignmentTestPageState();
}

class _AssignmentTestPageState extends State<AssignmentTestPage> {
  final ApiService _apiService = ApiService.instance;
  final AssignmentService _assignmentService = AssignmentService();
  String _testResults = '';
  bool _isLoading = false;

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Starting tests...\n';
    });

    try {
      // Test 1: Login
      _appendResult('🔐 Testing login...');
      final loginResponse = await _apiService.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': 'user@gmail.com',
          'password': 'user123'
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (loginResponse.success) {
        _appendResult('✅ Login successful');
        _appendResult('🔑 Token received');
      } else {
        _appendResult('❌ Login failed: ${loginResponse.message}');
        return;
      }

      // Test 2: Test assignments connection
      _appendResult('📡 Testing assignments connection...');
      final connectionTest = await _assignmentService.testConnection();
      _appendResult(connectionTest ? '✅ Connection test passed' : '❌ Connection test failed');

      // Test 3: Get upcoming assignments
      _appendResult('📋 Getting upcoming assignments...');
      final assignments = await _assignmentService.getUpcomingAssignments();
      _appendResult('✅ Received ${assignments.length} assignments:');
      
      for (var assignment in assignments) {
        _appendResult('  - ${assignment.title} (${assignment.priority})');
      }

    } catch (e) {
      _appendResult('❌ Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _appendResult(String message) {
    setState(() {
      _testResults += '$message\n';
    });
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _runTests,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Run Assignment Tests'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}