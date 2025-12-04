import 'server_config.dart';

class ApiConstants {
  // Base URLs
  static const String developmentUrl = 'http://localhost:3000/api';
  static const String firebaseServerUrl = 'http://localhost:3000/api';
  static const String productionUrl = 'https://your-production-url.com/api';
  
  // Development mode flag
  static const bool isDevelopment = true;
  static const bool useFirebaseServer = true;
  
  // Get current base URL based on environment and server config
  static String get baseUrl {
    if (ServerConfig.isDevelopmentMode && ServerConfig.useFirebaseNpmServer) {
      return ServerConfig.currentApiUrl;
    }
    return isDevelopment 
      ? (useFirebaseServer ? firebaseServerUrl : developmentUrl) 
      : productionUrl;
  }
  
  // Endpoint groups
  static const AuthEndpoints auth = AuthEndpoints();
  static const AttendanceEndpoints attendance = AttendanceEndpoints();
  static const LetterEndpoints letters = LetterEndpoints();
  static const UserEndpoints users = UserEndpoints();
  static const DashboardEndpoints dashboard = DashboardEndpoints();
  static const AssignmentEndpoints assignments = AssignmentEndpoints();
  
  // HTTP Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  
  // Status Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;
  
  // Timeout durations (in seconds) - Increased for mobile connections
  static const int connectTimeout = 120; // 2 minutes for slow mobile
  static const int receiveTimeout = 120;
  static const int sendTimeout = 120;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
  static const String deviceIdKey = 'device_id';
}

class AuthEndpoints {
  const AuthEndpoints();
  
  String get login => '/auth/login';
  String get register => '/auth/register';
  String get logout => '/auth/logout';
  String get profile => '/profile'; // Changed from /auth/profile to /profile
  String get updateProfile => '/profile'; // Changed from /auth/profile to /profile
  String get changePassword => '/auth/change-password';
  String get forgotPassword => '/auth/forgot-password';
  String get resetPassword => '/auth/reset-password';
  String get refreshToken => '/auth/refresh-token';
  String get verifyEmail => '/auth/verify-email';
  String get resendVerification => '/auth/resend-verification';
}

class AttendanceEndpoints {
  const AttendanceEndpoints();
  
  String get checkIn => '/attendance/checkin';
  String get checkOut => '/attendance/checkout';
  String get list => '/attendance';
  String get current => '/attendance/today';
  String get summary => '/attendance/summary';
  String get statistics => '/attendance/statistics';
  String get report => '/attendance/report';
  String get lateArrivals => '/attendance/late-arrivals';
  String get earlyDepartures => '/attendance/early-departures';
  String get absentUsers => '/attendance/absent-users';
  String get export => '/attendance/export';
}

class LetterEndpoints {
  const LetterEndpoints();
  
  String get send => '/letters/send';
  String get received => '/letters/received';
  String get sent => '/letters/sent';
  String get pending => '/letters/pending';
  String get list => '/letters';
  String get markRead => '/letters/mark-read';
  String get reply => '/letters/reply';
  String get templates => '/letters/templates';
  String get statistics => '/letters/statistics';
  String get archive => '/letters/archive';
  String get archived => '/letters/archived';
  String get search => '/letters/search';
  String get pendingResponses => '/letters/pending-responses';
  String get overdueResponses => '/letters/overdue-responses';
  String get export => '/letters/export';
  String get uploadAttachment => '/letters/upload-attachment';
  String statusById(String id) => '/letters/$id/status';
}

class UserEndpoints {
  const UserEndpoints();
  
  String get list => '/admin/users';
  String get create => '/users/admin/create-employee';
  String get activate => '/admin/users/activate';
  String get deactivate => '/admin/users/deactivate';
  String get resetPassword => '/admin/users/reset-password';
  String get byDepartment => '/admin/users/by-department';
  String get byRole => '/admin/users/by-role';
  String get search => '/admin/users/search';
  String get statistics => '/admin/users/statistics';
  String get export => '/admin/users/export';
  String get bulkUpdate => '/admin/users/bulk-update';
  String get profileSummary => '/admin/users/profile-summary';
}

class DashboardEndpoints {
  const DashboardEndpoints();
  
  String get user => '/dashboard/user';
  String get admin => '/dashboard/admin';
  String get statistics => '/dashboard/statistics';
  String get summary => '/dashboard/summary';
  String get userActivity => '/dashboard/user/activity';
}

class AssignmentEndpoints {
  const AssignmentEndpoints();
  
  String get base => '/assignments';
  String get list => '/assignments';
  String get upcoming => '/assignments/upcoming';
  String get test => '/assignments/test';
  String get create => '/assignments';
  String get update => '/assignments';
  String get delete => '/assignments';
  String assignmentById(String id) => '/assignments/$id';
}

class ApiEndpoints {
  // Build full URL for endpoint
  static String fullUrl(String endpoint) {
    return '${ApiConstants.baseUrl}$endpoint';
  }
  
  // Auth endpoints
  static String get login => fullUrl(ApiConstants.auth.login);
  static String get register => fullUrl(ApiConstants.auth.register);
  static String get logout => fullUrl(ApiConstants.auth.logout);
  
  // Profile endpoints
  static String get profile => fullUrl(ApiConstants.auth.profile);
  static String get changePassword => fullUrl(ApiConstants.auth.changePassword);
  static String get updateProfile => fullUrl(ApiConstants.auth.updateProfile);
  
  // User endpoints
  static String get users => fullUrl(ApiConstants.users.list);
  static String userById(String userId) => '${fullUrl(ApiConstants.users.list)}/$userId';
  
  // Attendance endpoints
  static String get attendance => fullUrl(ApiConstants.attendance.list);
  static String get attendanceToday => fullUrl(ApiConstants.attendance.current);
  static String get attendanceCheckin => fullUrl(ApiConstants.attendance.checkIn);
  static String get attendanceCheckout => fullUrl(ApiConstants.attendance.checkOut);
  static String get attendanceStatistics => fullUrl(ApiConstants.attendance.statistics);
  static String get attendanceReport => fullUrl(ApiConstants.attendance.report);
  
  // Letters endpoints
  static String get letters => fullUrl(ApiConstants.letters.list);
  static String letterById(String letterId) => '${fullUrl(ApiConstants.letters.list)}/$letterId';
  static String get letterTemplates => fullUrl(ApiConstants.letters.templates);
  static String get letterStatistics => fullUrl(ApiConstants.letters.statistics);
  static String letterResponse(String letterId) => '${fullUrl(ApiConstants.letters.list)}/$letterId/response';
  
  // Dashboard endpoints
  static String get userDashboard => fullUrl(ApiConstants.dashboard.user);
  static String get adminDashboard => fullUrl(ApiConstants.dashboard.admin);
  static String get dashboardStatistics => fullUrl(ApiConstants.dashboard.statistics);
  static String get dashboardSummary => fullUrl(ApiConstants.dashboard.summary);
  
  // Assignment endpoints
  static String get assignments => fullUrl(ApiConstants.assignments.list);
  static String get upcomingAssignments => fullUrl(ApiConstants.assignments.upcoming);
  static String get testAssignments => fullUrl(ApiConstants.assignments.test);
  static String assignmentById(String id) => fullUrl(ApiConstants.assignments.assignmentById(id));
}