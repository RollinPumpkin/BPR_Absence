import 'api_service.dart';
import '../models/api_response.dart';
import '../constants/api_constants.dart';

class ShiftService {
  final ApiService _apiService = ApiService.instance;
  static const String _baseUrl = '/shifts';

  // Get shift assignments for date range
  Future<ApiResponse<List<dynamic>>> getAssignments({
    String? startDate,
    String? endDate,
    String? employeeId,
    String? role,
  }) async {
    final queryParams = <String, String>{};
    
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (employeeId != null) queryParams['employeeId'] = employeeId;
    if (role != null) queryParams['role'] = role;

    return _apiService.get(
      '$_baseUrl/assignments',
      queryParameters: queryParams,
      fromJson: (json) => json['data'] as List<dynamic>,
    );
  }

  // Get shift assignment for specific date and employee
  Future<ApiResponse<Map<String, dynamic>?>> getAssignment({
    required String date,
    required String employeeId,
  }) async {
    return _apiService.get(
      '$_baseUrl/assignment/$date/$employeeId',
      fromJson: (json) => json['data'] as Map<String, dynamic>?,
    );
  }

  // Create or update shift assignment
  Future<ApiResponse<Map<String, dynamic>>> createAssignment({
    required String date,
    required String employeeId,
    required String employeeName,
    required String role,
    required String shiftType,
    required String shiftStartTime,
    required String shiftEndTime,
    String? notes,
  }) async {
    return _apiService.post(
      '$_baseUrl/assignments',
      data: {
        'date': date,
        'employee_id': employeeId,
        'employee_name': employeeName,
        'role': role,
        'shift_type': shiftType,
        'shift_start_time': shiftStartTime,
        'shift_end_time': shiftEndTime,
        if (notes != null) 'notes': notes,
      },
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Bulk create shift assignments
  Future<ApiResponse<List<dynamic>>> bulkCreateAssignments({
    required List<Map<String, dynamic>> assignments,
  }) async {
    return _apiService.post(
      '$_baseUrl/assignments/bulk',
      data: {'assignments': assignments},
      fromJson: (json) => json['data'] as List<dynamic>,
    );
  }

  // Delete shift assignment
  Future<ApiResponse<void>> deleteAssignment(String assignmentId) async {
    return _apiService.delete(
      '$_baseUrl/assignments/$assignmentId',
      fromJson: (_) => null,
    );
  }

  // Get shift definitions
  Future<ApiResponse<List<dynamic>>> getShiftDefinitions() async {
    return _apiService.get(
      '$_baseUrl/definitions',
      fromJson: (json) => json['data'] as List<dynamic>,
    );
  }

  // Create or update shift definition
  Future<ApiResponse<Map<String, dynamic>>> saveShiftDefinition({
    String? id,
    required String name,
    required String startTime,
    required String endTime,
    String? color,
    String? description,
  }) async {
    return _apiService.post(
      '$_baseUrl/definitions',
      data: {
        if (id != null) 'id': id,
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
        if (color != null) 'color': color,
        if (description != null) 'description': description,
      },
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Delete shift definition
  Future<ApiResponse<void>> deleteShiftDefinition(String definitionId) async {
    return _apiService.delete(
      '$_baseUrl/definitions/$definitionId',
      fromJson: (_) => null,
    );
  }
}
