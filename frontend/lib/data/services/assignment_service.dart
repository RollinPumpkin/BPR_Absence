import 'package:dio/dio.dart';
import 'dart:convert';
import 'api_service.dart';
import '../constants/api_constants.dart';
import '../models/assignment.dart';

class AssignmentService {
  final ApiService _apiService = ApiService.instance;

  // Test method to check if API connection works
  Future<bool> testConnection() async {
    try {
      print('🧪 Testing API connection...');
      print('🧪 Testing URL: ${ApiConstants.baseUrl}${ApiConstants.assignments.test}');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.assignments.test,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      print('🧪 Test response success: ${response.success}');
      print('🧪 Test response message: ${response.message}');
      print('🧪 Test response error: ${response.error}');
      print('🧪 Test data: ${response.data}');
      return response.success;
    } catch (e) {
      print('🧪 Test connection failed: $e');
      return false;
    }
  }

  // Debug method to test direct API call
  Future<void> debugApiCall() async {
    print('🐛 DEBUG: Starting API debug test...');
    try {
      // Test connection first
      print('🐛 Step 1: Testing connection...');
      final testResult = await testConnection();
      print('🐛 Connection test result: $testResult');
      
      if (testResult) {
        print('🐛 Step 2: Testing upcoming assignments...');
        await getUpcomingAssignments();
      } else {
        print('🐛 Connection failed, but continuing with assignment test...');
        try {
          await getUpcomingAssignments();
        } catch (e) {
          print('🐛 Assignment test also failed: $e');
        }
      }
    } catch (e) {
      print('🐛 DEBUG API call failed: $e');
    }
  }

  Future<List<Assignment>> getUpcomingAssignments() async {
    try {
      print('🚀 Fetching upcoming assignments...');
      print('📍 Using endpoint: ${ApiConstants.assignments.upcoming}');
      print('🌐 Full URL: ${ApiConstants.baseUrl}${ApiConstants.assignments.upcoming}');
      
      // Add more detailed debugging
      print('🔑 Checking if token is available...');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.assignments.upcoming,
        fromJson: (data) {
          print('🔄 Processing response data: $data');
          return data as Map<String, dynamic>;
        },
      );

      print('📱 API Response success: ${response.success}');
      print('📱 API Response message: ${response.message}');
      print('📱 API Response error: ${response.error}');
      
      if (response.data != null) {
        print('📱 API Data keys: ${response.data!.keys.toList()}');
      }

      if (response.success && response.data != null) {
        print('📱 Full response data structure: ${response.data}');
        
        // Backend returns: { data: { assignments: [...], count: N } }
        // So we need to access response.data['data']['assignments']
        dynamic assignmentsData;
        
        if (response.data!.containsKey('data') && response.data!['data'] is Map) {
          final dataMap = response.data!['data'] as Map<String, dynamic>;
          assignmentsData = dataMap['assignments'];
          print('📋 Found assignments in data.assignments structure');
        } else if (response.data!.containsKey('assignments')) {
          assignmentsData = response.data!['assignments'];
          print('📋 Found assignments in direct assignments structure');
        } else {
          print('❌ Could not find assignments in response structure');
          print('❌ Available keys: ${response.data!.keys.toList()}');
          throw Exception('Assignments data not found in response');
        }
        
        print('📋 Raw assignments data type: ${assignmentsData.runtimeType}');
        print('📋 Raw assignments data: $assignmentsData');
        
        if (assignmentsData is List) {
          final List<dynamic> assignmentsJson = assignmentsData;
          print('📋 Found ${assignmentsJson.length} assignments in response');
          
          final assignments = assignmentsJson
              .map((json) {
                print('📋 Processing assignment: ${json['title']}');
                return Assignment.fromJson(json as Map<String, dynamic>);
              })
              .toList();
              
          print('✅ Successfully parsed ${assignments.length} assignments');
          return assignments;
        } else {
          print('❌ Assignments data is not a list: $assignmentsData');
          print('❌ Full response data: ${response.data}');
          throw Exception('Invalid assignments data format - expected List, got ${assignmentsData.runtimeType}');
        }
      } else {
        final errorMsg = response.message ?? response.error ?? 'Failed to load assignments';
        print('❌ API Error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      print('💥 Exception in getUpcomingAssignments: $e');
      print('💥 Exception type: ${e.runtimeType}');
      print('💥 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Assignment>> getAllAssignments({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/assignments',
        queryParameters: queryParams,
        fromJson: (data) => data as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        final List<dynamic> assignmentsJson = response.data!['assignments'] ?? [];
        return assignmentsJson
            .map((json) => Assignment.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to load assignments');
      }
    } catch (e) {
      print('Error fetching assignments: $e');
      throw Exception('Error fetching assignments: $e');
    }
  }

  Future<void> createSampleAssignments() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/assignments/seed',
        fromJson: (data) => data as Map<String, dynamic>,
      );
      
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to create sample assignments');
      }
    } catch (e) {
      print('Error creating sample assignments: $e');
      throw Exception('Error creating sample assignments: $e');
    }
  }

  // Helper method to get tasks for today
  List<Assignment> getTodayTasks(List<Assignment> assignments) {
    final today = DateTime.now();
    return assignments.where((assignment) {
      return assignment.dueDate.year == today.year &&
             assignment.dueDate.month == today.month &&
             assignment.dueDate.day == today.day;
    }).toList();
  }

  // Helper method to check if a date has tasks
  bool hasTasksOnDate(List<Assignment> assignments, DateTime date) {
    return assignments.any((assignment) {
      return assignment.dueDate.year == date.year &&
             assignment.dueDate.month == date.month &&
             assignment.dueDate.day == date.day;
    });
  }
}