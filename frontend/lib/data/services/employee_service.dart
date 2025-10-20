import '../models/api_response.dart';
import 'api_service.dart';

class EmployeeService {
  static const String _baseEndpoint = '/users/admin/employees';

  // Get all employees with filters
  static Future<ApiResponse<Map<String, dynamic>>> getEmployees({
    int page = 1,
    int limit = 20,
    String? search,
    String? department,
    String? status,
    String? role,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (department != null && department.isNotEmpty) queryParams['department'] = department;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (role != null && role.isNotEmpty) queryParams['role'] = role;

    final query = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    return await ApiService.instance.get<Map<String, dynamic>>('$_baseEndpoint?$query');
  }

  // Get single employee by ID
  static Future<ApiResponse<Map<String, dynamic>>> getEmployee(String employeeId) async {
    return await ApiService.instance.get<Map<String, dynamic>>('$_baseEndpoint/$employeeId');
  }

  // Create new employee
  static Future<ApiResponse<Map<String, dynamic>>> createEmployee(Map<String, dynamic> employeeData) async {
    return await ApiService.instance.post<Map<String, dynamic>>('/users/admin/create-employee', data: employeeData);
  }

  // Update employee
  static Future<ApiResponse<Map<String, dynamic>>> updateEmployee(String employeeId, Map<String, dynamic> updateData) async {
    return await ApiService.instance.put<Map<String, dynamic>>('$_baseEndpoint/$employeeId', data: updateData);
  }

  // Delete employee
  static Future<ApiResponse<Map<String, dynamic>>> deleteEmployee(String employeeId) async {
    return await ApiService.instance.delete<Map<String, dynamic>>('$_baseEndpoint/$employeeId');
  }

  // Update employee status
  static Future<ApiResponse<Map<String, dynamic>>> updateEmployeeStatus(String employeeId, String status, {String? reason}) async {
    final data = {
      'status': status,
      if (reason != null) 'reason': reason,
    };
    return await ApiService.instance.patch<Map<String, dynamic>>('$_baseEndpoint/$employeeId/status', data);
  }

  // Reset employee password
  static Future<ApiResponse<Map<String, dynamic>>> resetEmployeePassword(String employeeId, {String? newPassword}) async {
    final data = <String, dynamic>{};
    if (newPassword != null) data['new_password'] = newPassword;
    
    return await ApiService.instance.post<Map<String, dynamic>>('$_baseEndpoint/$employeeId/reset-password', data: data);
  }

  // Get departments
  static Future<ApiResponse<Map<String, dynamic>>> getDepartments() async {
    return await ApiService.instance.get<Map<String, dynamic>>('/users/admin/departments');
  }

  // Get employee analytics
  static Future<ApiResponse<Map<String, dynamic>>> getEmployeeAnalytics() async {
    return await ApiService.instance.get<Map<String, dynamic>>('/users/admin/analytics');
  }

  // Bulk import employees
  static Future<ApiResponse<Map<String, dynamic>>> bulkImportEmployees(List<Map<String, dynamic>> employees) async {
    return await ApiService.instance.post<Map<String, dynamic>>('/users/admin/bulk-import', data: {'employees': employees});
  }
}