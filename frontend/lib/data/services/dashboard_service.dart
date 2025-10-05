import '../models/api_response.dart';
import '../models/activity_summary.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService.instance;

  // Get user dashboard data
  Future<ApiResponse<Map<String, dynamic>>> getUserDashboard() async {
    return await _apiService.get<Map<String, dynamic>>(
      ApiConstants.dashboard.user,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Get admin dashboard data
  Future<ApiResponse<Map<String, dynamic>>> getAdminDashboard() async {
    return await _apiService.get<Map<String, dynamic>>(
      ApiConstants.dashboard.admin,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Get dashboard statistics
  Future<ApiResponse<Map<String, dynamic>>> getDashboardStatistics() async {
    return await _apiService.get<Map<String, dynamic>>(
      ApiConstants.dashboard.statistics,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Get dashboard summary
  Future<ApiResponse<DashboardSummary>> getDashboardSummary() async {
    return await _apiService.get<DashboardSummary>(
      ApiConstants.dashboard.summary,
      fromJson: (json) => DashboardSummary.fromJson(json),
    );
  }

  // Get activity summary specifically
  Future<ApiResponse<ActivitySummary>> getActivitySummary({String period = 'week'}) async {
    final queryParams = <String, dynamic>{
      'period': period,
    };

    return await _apiService.get<ActivitySummary>(
      ApiConstants.dashboard.userActivity,
      queryParameters: queryParams,
      fromJson: (json) => ActivitySummary.fromJson(json),
    );
  }
}