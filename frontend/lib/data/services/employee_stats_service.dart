import '../services/api_service.dart';
import '../models/api_response.dart';

class EmployeeStatsService {
  static final EmployeeStatsService _instance = EmployeeStatsService._internal();
  factory EmployeeStatsService() => _instance;
  EmployeeStatsService._internal();

  final ApiService _apiService = ApiService.instance;

  /// Get employee statistics from database
  Future<ApiResponse<Map<String, dynamic>>> getEmployeeStats() async {
    try {
      print('📊 Getting employee statistics...');
      
      // Use debug endpoint for now (will be changed to /users/stats once auth is fixed)
      final response = await _apiService.get('/debug/stats');
      
      if (response.success && response.data != null) {
        print('✅ Employee stats received from database: ${response.data}');
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Employee statistics retrieved successfully',
          data: response.data as Map<String, dynamic>,
        );
      } else {
        print('❌ Failed to get employee stats: ${response.message}');
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.message ?? 'Failed to get employee statistics',
          data: _getDefaultStats(),
        );
      }
    } catch (e) {
      print('❌ Error getting employee stats: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error getting employee statistics: $e',
        data: _getDefaultStats(),
      );
    }
  }

  /// Default/fallback statistics
  Map<String, dynamic> _getDefaultStats() {
    return {
      'total': 22,
      'active': 5,
      'new': 22,
      'resign': 17,
    };
  }

  /// Get specific stat count
  Future<int> getStatCount(String statType) async {
    try {
      final response = await getEmployeeStats();
      if (response.success && response.data != null) {
        return response.data![statType] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Error getting stat count for $statType: $e');
      return 0;
    }
  }

  /// Get total employees count
  Future<int> getTotalEmployees() async {
    return await getStatCount('total');
  }

  /// Get active employees count
  Future<int> getActiveEmployees() async {
    return await getStatCount('active');
  }

  /// Get new employees count (this month)
  Future<int> getNewEmployees() async {
    return await getStatCount('new');
  }

  /// Get resigned employees count
  Future<int> getResignedEmployees() async {
    return await getStatCount('resign');
  }
}