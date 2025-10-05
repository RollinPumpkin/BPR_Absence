import '../models/api_response.dart';
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
  Future<ApiResponse<Map<String, dynamic>>> getDashboardSummary() async {
    return await _apiService.get<Map<String, dynamic>>(
      ApiConstants.dashboard.summary,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}