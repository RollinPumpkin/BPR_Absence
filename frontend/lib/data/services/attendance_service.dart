import '../models/api_response.dart';
import '../models/attendance.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AttendanceService {
  final ApiService _apiService = ApiService.instance;

  // Check in
  Future<ApiResponse<Attendance>> checkIn({
    required double latitude,
    required double longitude,
    String? notes,
    String? photoUrl,
  }) async {
    final response = await _apiService.post<Attendance>(
      ApiConstants.attendance.checkIn,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (notes != null) 'notes': notes,
        if (photoUrl != null) 'photo_url': photoUrl,
      },
      fromJson: (json) => Attendance.fromJson(json),
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after check in...');
      _apiService.clearCache();
    }
    
    return response;
  }

  // Check out
  Future<ApiResponse<Attendance>> checkOut({
    required String attendanceId,
    required double latitude,
    required double longitude,
    String? notes,
    String? photoUrl,
  }) async {
    final response = await _apiService.put<Attendance>(
      '${ApiConstants.attendance.checkOut}/$attendanceId',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (notes != null) 'notes': notes,
        if (photoUrl != null) 'photo_url': photoUrl,
      },
      fromJson: (json) => Attendance.fromJson(json),
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after check out...');
      _apiService.clearCache();
    }
    
    return response;
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
        json['data'] ?? json, // Access nested data object
        (item) => Attendance.fromJson(item),
        'attendance', // Use 'attendance' key instead of 'data'
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

  // Get monthly attendance summary
  Future<ApiResponse<AttendanceMonthlySummary>> getMonthlySummary({
    int? month,
    int? year,
  }) async {
    try {
      print('📊 AttendanceService: Fetching monthly summary...');
      print('📊 AttendanceService: Month=$month, Year=$year');
      
      final queryParams = <String, dynamic>{};

      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      print('📊 AttendanceService: Query params: $queryParams');
      print('📊 AttendanceService: Endpoint: ${ApiConstants.attendance.summary}');
      print('📊 AttendanceService: Full URL: ${ApiConstants.baseUrl}${ApiConstants.attendance.summary}');

      final response = await _apiService.get<AttendanceMonthlySummary>(
        ApiConstants.attendance.summary,
        queryParameters: queryParams,
        fromJson: (json) {
          print('📊 AttendanceService: fromJson called with: $json');
          try {
            final result = AttendanceMonthlySummary.fromJson(json);
            print('📊 AttendanceService: Successfully parsed AttendanceMonthlySummary');
            return result;
          } catch (e, stackTrace) {
            print('❌ AttendanceService: Error in fromJson: $e');
            print('❌ AttendanceService: Stack trace: $stackTrace');
            rethrow;
          }
        },
      );
      
      print('📊 AttendanceService: Response success: ${response.success}');
      print('📊 AttendanceService: Response message: ${response.message}');
      print('📊 AttendanceService: Response data null: ${response.data == null}');
      
      return response;
    } catch (e, stackTrace) {
      print('❌ AttendanceService: Exception caught: $e');
      print('❌ AttendanceService: Exception type: ${e.runtimeType}');
      print('❌ AttendanceService: Stack trace: $stackTrace');
      
      return ApiResponse<AttendanceMonthlySummary>(
        success: false,
        message: 'Failed to fetch attendance summary: ${e.toString()}',
        error: e.toString(),
      );
    }
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

    final response = await _apiService.put<Attendance>(
      '${ApiConstants.attendance.list}/$id',
      data: data,
      fromJson: (json) => Attendance.fromJson(json),
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after attendance update...');
      _apiService.clearCache();
    }
    
    return response;
  }

  // Delete attendance record (admin only)
  Future<ApiResponse<String>> deleteAttendance(String id) async {
    final response = await _apiService.delete<String>(
      '${ApiConstants.attendance.list}/$id',
      fromJson: (json) => json?.toString() ?? 'Attendance deleted successfully',
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after attendance deletion...');
      _apiService.clearCache();
    }
    
    return response;
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

  // Submit attendance with image upload
  Future<ApiResponse<Map<String, dynamic>>> submitAttendanceWithImage({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required double latitude,
    required double longitude,
    required String address,
    required XFile image,
    String? notes,
  }) async {
    try {
      print('📤 [AttendanceService] Submitting attendance with image...');
      print('📍 Type: $type');
      print('📅 Start Date: $startDate');
      print('📅 End Date: $endDate');
      print('🌍 Location: $latitude, $longitude');
      
      // Create FormData for multipart upload
      FormData formData = FormData.fromMap({
        'type': type.toLowerCase().replaceAll(' ', '_'), // clock_in, clock_out, absent, etc.
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'image': MultipartFile.fromBytes(
          await image.readAsBytes(),
          filename: image.name.isNotEmpty ? image.name : 'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'timestamp': DateTime.now().toIso8601String(),
        if (notes != null) 'notes': notes,
      });

      final imageBytes = await image.readAsBytes();
      print('📷 Image size: ${imageBytes.length} bytes');
      
      final response = await _apiService.postFormData<Map<String, dynamic>>(
        '/attendance/submit',
        formData: formData,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      print('✅ [AttendanceService] Attendance submitted successfully');
      return response;

    } catch (e) {
      print('❌ [AttendanceService] Error submitting attendance: $e');
      rethrow;
    }
  }
}