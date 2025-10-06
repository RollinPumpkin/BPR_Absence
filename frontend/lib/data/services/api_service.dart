import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';

class ApiService {
  static ApiService? _instance;
  late Dio _dio;
  String? _token;
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const int _cacheTimeout = 5 * 60 * 1000; // 5 minutes

  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate, br',
        'User-Agent': 'BPR-Absence-App/1.0.0',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor to add auth token and handle caching
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
          print('🔑 Token added to request: ${_token?.substring(0, 20)}...');
        } else {
          print('⚠️ No token available for request: ${options.method} ${options.path}');
        }
        
        // Add detailed request tracking for debugging
        print('🌐 Full URL: ${options.baseUrl}${options.path}');
        print('🌐 Request method: ${options.method}');
        print('🌐 Request headers: ${options.headers}');
        
        final startTime = DateTime.now();
        options.extra['startTime'] = startTime;
        
        print('🚀 Request: ${options.method} ${options.path}');
        if (options.queryParameters?.isNotEmpty == true) {
          print('📋 Query Parameters: ${options.queryParameters}');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra['startTime'] as DateTime?;
        if (startTime != null) {
          final duration = DateTime.now().difference(startTime);
          print('✅ Response: ${response.statusCode} ${response.statusMessage} (${duration.inMilliseconds}ms)');
        }
        
        handler.next(response);
      },
      onError: (error, handler) {
        final startTime = error.requestOptions.extra['startTime'] as DateTime?;
        if (startTime != null) {
          final duration = DateTime.now().difference(startTime);
          print('❌ Error: ${error.message} (${duration.inMilliseconds}ms)');
        }
        
        print('🔍 Error Details: ${error.response?.data}');
        
        // Handle token expiration with retry
        if (error.response?.statusCode == 401) {
          _handleTokenExpiration();
        }
        
        handler.next(error);
      },
    ));

    // Add simple retry logic for network failures
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        // Retry on network errors and timeouts
        if (_shouldRetry(error) && error.requestOptions.extra['retryCount'] == null) {
          error.requestOptions.extra['retryCount'] = 1;
          try {
            await Future.delayed(const Duration(seconds: 1));
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // Fall through to default error handling
          }
        }
        handler.next(error);
      },
    ));
  }

  // Initialize token from storage
  Future<void> initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    print('🔑 Token initialized: ${_token != null ? "Available" : "Not found"}');
  }

  // Set token and save to storage
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('💾 Token saved to storage: ${token.substring(0, 20)}...');
  }

  // Clear token from memory and storage
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _clearCache(); // Clear cache when token is cleared
    print('🗑️ Token cleared from storage');
  }

  // Handle token expiration
  void _handleTokenExpiration() {
    clearToken();
    print('⏰ Token expired, cleared from storage');
    // Navigate to login screen or show login dialog
    // This would typically be handled by a navigation service
  }

  // Cache management
  String _getCacheKey(String endpoint, Map<String, dynamic>? queryParameters) {
    return '$endpoint${queryParameters != null ? '?${jsonEncode(queryParameters)}' : ''}';
  }

  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp).inMilliseconds < _cacheTimeout;
  }

  void _cacheResponse(String cacheKey, dynamic data) {
    _cache[cacheKey] = data;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  void _clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    print('🧹 Cache cleared');
  }

  // Clear specific cache entry
  void clearCacheForEndpoint(String endpoint) {
    _cache.removeWhere((key, value) => key.startsWith(endpoint));
    _cacheTimestamps.removeWhere((key, value) => key.startsWith(endpoint));
  }

  // Check if request should be retried
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.response?.statusCode ?? 0) >= 500;
  }

  // Generic GET request with caching
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = _getCacheKey(endpoint, queryParameters);
      
      // Check cache first (unless force refresh is requested)
      if (useCache && !forceRefresh && _isCacheValid(cacheKey)) {
        final cachedData = _cache[cacheKey];
        if (cachedData != null) {
          print('📦 Using cached data for: $endpoint');
          return ApiResponse<T>(
            success: true,
            data: fromJson != null ? fromJson(cachedData) : cachedData as T,
            message: 'Data retrieved from cache',
          );
        }
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      print('🌐 Raw HTTP Response Status: ${response.statusCode}');
      print('🌐 Raw HTTP Response Data: ${response.data}');

      final apiResponse = _handleResponse<T>(response, fromJson);
      print('🔄 Processed API Response: success=${apiResponse.success}, message=${apiResponse.message}');
      
      // Cache successful responses
      if (useCache && apiResponse.success && apiResponse.data != null) {
        _cacheResponse(cacheKey, response.data['data'] ?? response.data);
      }

      return apiResponse;
    } on DioException catch (e) {
      print('💥 DioException in GET request: ${e.type}');
      print('💥 DioException message: ${e.message}');
      print('💥 DioException response: ${e.response?.data}');
      print('💥 DioException status: ${e.response?.statusCode}');
      return _handleError<T>(e);
    }
  }

  // Generic POST request with cache invalidation
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    List<String>? invalidateCacheEndpoints,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      final apiResponse = _handleResponse<T>(response, fromJson);
      
      // Invalidate cache for specified endpoints after successful POST
      if (apiResponse.success && invalidateCacheEndpoints != null) {
        for (final cacheEndpoint in invalidateCacheEndpoints) {
          clearCacheForEndpoint(cacheEndpoint);
        }
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST request with FormData for file uploads
  Future<ApiResponse<T>> postFormData<T>(
    String endpoint, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    List<String>? invalidateCacheEndpoints,
  }) async {
    try {
      print('📤 [ApiService] Uploading FormData to: $endpoint');
      
      final response = await _dio.post(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5), // Extended timeout for file uploads
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      print('✅ [ApiService] FormData upload successful');
      final apiResponse = _handleResponse<T>(response, fromJson);
      
      // Invalidate cache for specified endpoints after successful POST
      if (apiResponse.success && invalidateCacheEndpoints != null) {
        for (final cacheEndpoint in invalidateCacheEndpoints) {
          clearCacheForEndpoint(cacheEndpoint);
        }
      }

      return apiResponse;
    } on DioException catch (e) {
      print('❌ [ApiService] FormData upload failed: ${e.message}');
      return _handleError<T>(e);
    }
  }

  // Generic PUT request with cache invalidation
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    List<String>? invalidateCacheEndpoints,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      final apiResponse = _handleResponse<T>(response, fromJson);
      
      // Invalidate cache for specified endpoints after successful PUT
      if (apiResponse.success && invalidateCacheEndpoints != null) {
        for (final cacheEndpoint in invalidateCacheEndpoints) {
          clearCacheForEndpoint(cacheEndpoint);
        }
      }

      return apiResponse;
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJson,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData();
      
      // Add file
      formData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      ));

      // Add additional data
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  // Handle successful response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    final data = response.data;
    
    if (data is Map<String, dynamic>) {
      final success = data['success'] ?? true;
      final message = data['message'] ?? 'Success';
      
      if (success) {
        T? resultData;
        
        if (fromJson != null && data['data'] != null) {
          resultData = fromJson(data['data']);
        } else if (T == String && data['data'] is String) {
          resultData = data['data'] as T;
        } else if (T == dynamic) {
          resultData = data['data'] as T?;
        }

        return ApiResponse<T>(
          success: true,
          message: message,
          data: resultData,
          pagination: data['pagination'] != null 
              ? PaginationData.fromJson(data['pagination'])
              : null,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: message,
          error: data['error']?.toString(),
        );
      }
    }

    // For non-standard responses
    return ApiResponse<T>(
      success: true,
      message: 'Success',
      data: fromJson != null ? fromJson(data) : data as T?,
    );
  }

  // Handle errors with enhanced error information
  ApiResponse<T> _handleError<T>(DioException error) {
    String message = 'An error occurred';
    String? errorDetails;
    String? errorCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        errorCode = 'CONNECTION_TIMEOUT';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        errorCode = 'SEND_TIMEOUT';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server response timeout. Please try again.';
        errorCode = 'RECEIVE_TIMEOUT';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? _getStatusMessage(statusCode);
          errorDetails = responseData['error']?.toString();
          errorCode = responseData['code']?.toString() ?? 'HTTP_$statusCode';
        } else {
          message = _getStatusMessage(statusCode);
          errorCode = 'HTTP_$statusCode';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        errorCode = 'REQUEST_CANCELLED';
        break;
      case DioExceptionType.connectionError:
        message = 'Unable to connect to server. Please check your internet connection.';
        errorCode = 'CONNECTION_ERROR';
        break;
      case DioExceptionType.unknown:
        message = error.message ?? 'Unknown network error occurred';
        errorCode = 'UNKNOWN_ERROR';
        break;
      default:
        message = 'Network error occurred';
        errorCode = 'NETWORK_ERROR';
    }

    // Log error for debugging
    print('🚨 API Error: $errorCode - $message');
    if (errorDetails != null) {
      print('📋 Error Details: $errorDetails');
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      error: errorDetails ?? error.message,
    );
  }

  // Get user-friendly message for HTTP status codes
  String _getStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication required. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission for this action.';
      case 404:
        return 'Requested resource not found.';
      case 409:
        return 'Conflict occurred. The resource already exists.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Server is temporarily unavailable. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'Server error occurred (${statusCode ?? 'Unknown'})';
    }
  }

  // Network connectivity check
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('/health', 
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        )
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // Get current token
  String? get currentToken => _token;
}
