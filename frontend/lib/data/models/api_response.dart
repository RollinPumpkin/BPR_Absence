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
    print('🔧 ListResponse.fromJson - Input: $json');
    print('🔧 ListResponse.fromJson - Looking for key: $itemsKey');
    
    List<T> processedItems = [];
    
    final itemsData = json[itemsKey];
    print('🔧 ListResponse.fromJson - Items data: $itemsData');
    print('🔧 ListResponse.fromJson - Items data type: ${itemsData.runtimeType}');
    
    if (itemsData is List) {
      for (int i = 0; i < itemsData.length; i++) {
        final item = itemsData[i];
        print('🔧 ListResponse.fromJson - Processing item $i: $item');
        print('🔧 ListResponse.fromJson - Item $i type: ${item.runtimeType}');
        
        if (item != null && item is Map<String, dynamic>) {
          try {
            final processedItem = fromJsonT(item);
            processedItems.add(processedItem);
            print('✅ ListResponse.fromJson - Successfully processed item $i');
          } catch (e) {
            print('❌ ListResponse.fromJson - Error processing item $i: $e');
            print('❌ ListResponse.fromJson - Problematic item: $item');
            // Continue processing other items instead of failing completely
          }
        } else {
          print('⚠️ ListResponse.fromJson - Invalid item $i (null or not Map): $item');
        }
      }
    } else {
      print('❌ ListResponse.fromJson - Items data is not a List: ${itemsData.runtimeType}');
    }
    
    print('🔧 ListResponse.fromJson - Final processed items count: ${processedItems.length}');
    
    return ListResponse<T>(
      items: processedItems,
      pagination: json['pagination'] != null 
          ? PaginationData.fromJson(json['pagination'])
          : null,
      filters: json['filters'],
    );
  }
}