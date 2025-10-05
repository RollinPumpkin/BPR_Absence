import '../models/api_response.dart';
import '../models/attendance.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AttendanceService {
  final ApiService _apiService = ApiService.instance;

  // Check in
  Future<ApiResponse<Attendance>> checkIn({
    required double latitude,
    required double longitude,
    String? notes,
    String? photoUrl,
  }) async {
    return await _apiService.post<Attendance>(
      ApiConstants.attendance.checkIn,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (notes != null) 'notes': notes,
        if (photoUrl != null) 'photo_url': photoUrl,
      },
      fromJson: (json) => Attendance.fromJson(json),
    );
  }

  // Check out
  Future<ApiResponse<Attendance>> checkOut({
    required String attendanceId,
    required double latitude,
    required double longitude,
    String? notes,
    String? photoUrl,
  }) async {
    return await _apiService.put<Attendance>(
      '${ApiConstants.attendance.checkOut}/$attendanceId',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (notes != null) 'notes': notes,
        if (photoUrl != null) 'photo_url': photoUrl,
      },
      fromJson: (json) => Attendance.fromJson(json),
    );
  }

  // Get attendance records
  Future<ApiResponse<ListResponse<Attendance>>> getAttendanceRecords({
    int page = 1,
    int limit = 10,
    String? startDate,
    String? endDate,
    String? status,
    String? userId,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (status != null) queryParams['status'] = status;
    if (userId != null) queryParams['user_id'] = userId;

    return await _apiService.get<ListResponse<Attendance>>(
      ApiConstants.attendance.list,
      queryParameters: queryParams,
      fromJson: (json) => ListResponse<Attendance>.fromJson(
        json,
        (item) => Attendance.fromJson(item),
        'data',
      ),
    );
  }

  // Get current attendance status
  Future<ApiResponse<Attendance?>> getCurrentAttendance() async {
    return await _apiService.get<Attendance?>(
      ApiConstants.attendance.current,
      fromJson: (json) => json != null ? Attendance.fromJson(json) : null,
    );
  }

  // Get attendance statistics
  Future<ApiResponse<AttendanceStatistics>> getAttendanceStatistics({
    String? userId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};

    if (userId != null) queryParams['user_id'] = userId;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    return await _apiService.get<AttendanceStatistics>(
      ApiConstants.attendance.statistics,
      queryParameters: queryParams,
      fromJson: (json) => AttendanceStatistics.fromJson(json),
    );
  }

  // Get attendance by ID
  Future<ApiResponse<Attendance>> getAttendanceById(String id) async {
    return await _apiService.get<Attendance>(
      '${ApiConstants.attendance.list}/$id',
      fromJson: (json) => Attendance.fromJson(json),
    );
  }

  // Update attendance record
  Future<ApiResponse<Attendance>> updateAttendance({
    required String id,
    String? notes,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    
    if (notes != null) data['notes'] = notes;
    if (status != null) data['status'] = status;

    return await _apiService.put<Attendance>(
      '${ApiConstants.attendance.list}/$id',
      data: data,
      fromJson: (json) => Attendance.fromJson(json),
    );
  }

  // Delete attendance record (admin only)
  Future<ApiResponse<String>> deleteAttendance(String id) async {
    return await _apiService.delete<String>(
      '${ApiConstants.attendance.list}/$id',
      fromJson: (json) => json?.toString() ?? 'Attendance deleted successfully',
    );
  }

  // Get attendance report for admin
  Future<ApiResponse<List<Attendance>>> getAttendanceReport({
    required String startDate,
    required String endDate,
    String? userId,
    String? department,
  }) async {
    final queryParams = <String, dynamic>{
      'start_date': startDate,
      'end_date': endDate,
    };

    if (userId != null) queryParams['user_id'] = userId;
    if (department != null) queryParams['department'] = department;

    return await _apiService.get<List<Attendance>>(
      ApiConstants.attendance.report,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((item) => Attendance.fromJson(item))
          .toList(),
    );
  }

  // Get late arrivals report
  Future<ApiResponse<List<Attendance>>> getLateArrivals({
    String? startDate,
    String? endDate,
    String? userId,
  }) async {
    final queryParams = <String, dynamic>{};

    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (userId != null) queryParams['user_id'] = userId;

    return await _apiService.get<List<Attendance>>(
      ApiConstants.attendance.lateArrivals,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((item) => Attendance.fromJson(item))
          .toList(),
    );
  }

  // Get early departures report
  Future<ApiResponse<List<Attendance>>> getEarlyDepartures({
    String? startDate,
    String? endDate,
    String? userId,
  }) async {
    final queryParams = <String, dynamic>{};

    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (userId != null) queryParams['user_id'] = userId;

    return await _apiService.get<List<Attendance>>(
      ApiConstants.attendance.earlyDepartures,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((item) => Attendance.fromJson(item))
          .toList(),
    );
  }

  // Get absent users
  Future<ApiResponse<List<String>>> getAbsentUsers({
    String? date,
  }) async {
    final queryParams = <String, dynamic>{};

    if (date != null) queryParams['date'] = date;

    return await _apiService.get<List<String>>(
      ApiConstants.attendance.absentUsers,
      queryParameters: queryParams,
      fromJson: (json) => List<String>.from(json ?? []),
    );
  }

  // Export attendance data
  Future<ApiResponse<String>> exportAttendance({
    required String startDate,
    required String endDate,
    String? format, // 'excel' or 'pdf'
    String? userId,
    String? department,
  }) async {
    final queryParams = <String, dynamic>{
      'start_date': startDate,
      'end_date': endDate,
    };

    if (format != null) queryParams['format'] = format;
    if (userId != null) queryParams['user_id'] = userId;
    if (department != null) queryParams['department'] = department;

    return await _apiService.get<String>(
      ApiConstants.attendance.export,
      queryParameters: queryParams,
      fromJson: (json) => json?.toString() ?? '',
    );
  }
}