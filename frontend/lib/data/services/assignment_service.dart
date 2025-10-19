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
          if (data == null) {
            return <String, dynamic>{};
          }
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
        ApiConstants.assignments.list,
        queryParameters: queryParams,
        fromJson: (data) {
          // Enhanced null safety for response data
          if (data == null) {
            print('❌ Received null data from assignments API');
            return <String, dynamic>{};
          }
          
          if (data is! Map<String, dynamic>) {
            print('❌ Received invalid data type: ${data.runtimeType}');
            return <String, dynamic>{};
          }
          
          print('📱 Valid data received: ${data.keys.toList()}');
          return data;
        },
      );
      
      print('📱 getAllAssignments Response success: ${response.success}');
      print('📱 getAllAssignments Response message: ${response.message}');
      print('📱 getAllAssignments Response data: ${response.data}');
      print('📱 getAllAssignments Response error: ${response.error}');
      
      if (response.success) {
        if (response.data == null) {
          print('⚠️ getAllAssignments - Response data is null, returning empty list');
          return [];
        }
        
        print('📱 getAllAssignments Full response data: ${response.data}');
        print('📱 getAllAssignments Response data type: ${response.data.runtimeType}');
        
        // Handle different response structures with enhanced null safety
        dynamic assignmentsData;
        
        try {
          if (response.data is Map<String, dynamic>) {
            final responseMap = response.data as Map<String, dynamic>;
            
            if (responseMap.containsKey('data') && responseMap['data'] is Map) {
              final dataMap = responseMap['data'] as Map<String, dynamic>;
              assignmentsData = dataMap['assignments'];
              print('📋 Found assignments in data.assignments structure');
            } else if (responseMap.containsKey('assignments')) {
              assignmentsData = responseMap['assignments'];
              print('📋 Found assignments in direct assignments structure');
            } else {
              print('❌ Could not find assignments in response structure');
              print('❌ Available keys: ${responseMap.keys.toList()}');
              // Return empty list instead of throwing
              return [];
            }
          } else {
            print('❌ Response data is not a Map: ${response.data.runtimeType}');
            return [];
          }
          
          if (assignmentsData == null) {
            print('⚠️ Assignments data is null, returning empty list');
            return [];
          }
          
          if (assignmentsData is List) {
            final List<dynamic> assignmentsJson = assignmentsData;
            print('📋 getAllAssignments Found ${assignmentsJson.length} assignments');
            
            // Process assignments with error handling
            List<Assignment> assignments = [];
            for (int i = 0; i < assignmentsJson.length; i++) {
              try {
                final json = assignmentsJson[i];
                if (json != null && json is Map<String, dynamic>) {
                  assignments.add(Assignment.fromJson(json));
                }
              } catch (e) {
                print('❌ Error parsing assignment $i: $e');
                // Continue processing other assignments
              }
            }
            
            print('✅ Successfully parsed ${assignments.length} assignments');
            return assignments;
          } else {
            print('❌ Assignments data is not a list: ${assignmentsData.runtimeType}');
            return [];
          }
        } catch (e) {
          print('❌ Error processing assignments response: $e');
          return [];
        }
      } else {
        final errorMessage = response.message ?? response.error ?? 'Failed to load assignments';
        print('❌ API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error fetching assignments: $e');
      throw Exception('Error fetching assignments: $e');
    }
  }

  Future<void> createSampleAssignments() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/assignments/seed',
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