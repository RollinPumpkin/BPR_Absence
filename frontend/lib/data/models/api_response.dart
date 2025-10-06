class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final String? error;
  final PaginationData? pagination;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.error,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errors: json['errors'],
    );
  }

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

class PaginationData {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationData({
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalRecords: json['total_records'] ?? 0,
      limit: json['limit'] ?? 20,
      hasNextPage: json['has_next_page'] ?? false,
      hasPrevPage: json['has_prev_page'] ?? false,
    );
  }
}

class ListResponse<T> {
  final List<T> items;
  final PaginationData? pagination;
  final Map<String, dynamic>? filters;

  ListResponse({
    required this.items,
    this.pagination,
    this.filters,
  });

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
    String itemsKey,
  ) {
    return ListResponse<T>(
      items: (json[itemsKey] as List<dynamic>?)
          ?.map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList() ?? [],
      pagination: json['pagination'] != null 
          ? PaginationData.fromJson(json['pagination'])
          : null,
      filters: json['filters'],
    );
  }
}