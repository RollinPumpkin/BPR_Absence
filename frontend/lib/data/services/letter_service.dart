import 'dart:io';
import '../models/api_response.dart';
import '../models/letter.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class LetterService {
  final ApiService _apiService = ApiService.instance;

  // Send a letter
  Future<ApiResponse<Letter>> sendLetter({
    required String recipientId,
    required String subject,
    required String content,
    required String letterType,
    required String priority,
    bool requiresResponse = false,
    DateTime? responseDeadline,
    List<String>? ccRecipients,
    String? templateUsed,
    String? referenceNumber,
    List<File>? attachments,
  }) async {
    // Handle file uploads first if attachments exist
    List<LetterAttachment> uploadedAttachments = [];
    
    if (attachments != null && attachments.isNotEmpty) {
      for (File file in attachments) {
        final uploadResponse = await _apiService.uploadFile<Map<String, dynamic>>(
          ApiConstants.letters.uploadAttachment,
          file,
          fieldName: 'attachment',
          fromJson: (json) => json as Map<String, dynamic>,
        );
        
        if (uploadResponse.success && uploadResponse.data != null) {
          uploadedAttachments.add(LetterAttachment.fromJson(uploadResponse.data!));
        }
      }
    }

    final response = await _apiService.post<Letter>(
      ApiConstants.letters.send,
      data: {
        'recipient_id': recipientId,
        'subject': subject,
        'content': content,
        'letter_type': letterType,
        'priority': priority,
        'requires_response': requiresResponse,
        if (responseDeadline != null) 
          'response_deadline': responseDeadline.toIso8601String(),
        if (ccRecipients != null) 'cc_recipients': ccRecipients,
        if (templateUsed != null) 'template_used': templateUsed,
        if (referenceNumber != null) 'reference_number': referenceNumber,
        'attachments': uploadedAttachments.map((a) => a.toJson()).toList(),
      },
      fromJson: (json) => Letter.fromJson(json),
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after letter sent...');
      _apiService.clearCache();
    }
    
    return response;
  }

  // Get received letters
  Future<ApiResponse<ListResponse<Letter>>> getReceivedLetters({
    int page = 1,
    int limit = 10,
    String? status,
    String? letterType,
    String? priority,
    String? startDate,
    String? endDate,
    bool forceRefresh = false, // Add force refresh parameter
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (letterType != null) queryParams['letter_type'] = letterType;
    if (priority != null) queryParams['priority'] = priority;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    return await _apiService.get<ListResponse<Letter>>(
      ApiConstants.letters.received,
      queryParameters: queryParams,
      forceRefresh: forceRefresh, // Pass force refresh to API service
      fromJson: (json) {
        print('🔍 getReceivedLetters fromJson - Input: $json');
        print('🔍 getReceivedLetters fromJson - Input type: ${json.runtimeType}');
        
        try {
          // Handle null response
          if (json == null) {
            print('⚠️ getReceivedLetters - json is null');
            return ListResponse<Letter>(items: []);
          }
          
          if (json is Map<String, dynamic>) {
            // Try multiple possible structures
            Map<String, dynamic>? dataObject;
            
            if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
              dataObject = json['data'] as Map<String, dynamic>;
              print('📋 getReceivedLetters - Using json.data structure');
            } else {
              dataObject = json;
              print('📋 getReceivedLetters - Using direct json structure');
            }
            
            return ListResponse<Letter>.fromJson(
              dataObject,
              (item) {
                print('🔍 Parsing received letter item: ${item['subject'] ?? 'Unknown'}');
                return Letter.fromJson(item);
              },
              'letters',
            );
          } else {
            print('❌ getReceivedLetters - json is not a Map: ${json.runtimeType}');
            return ListResponse<Letter>(items: []);
          }
        } catch (e, stackTrace) {
          print('❌ getReceivedLetters fromJson error: $e');
          print('❌ getReceivedLetters stackTrace: $stackTrace');
          return ListResponse<Letter>(items: []);
        }
      },
    );
  }

  // Get sent letters
  Future<ApiResponse<ListResponse<Letter>>> getSentLetters({
    int page = 1,
    int limit = 10,
    String? status,
    String? letterType,
    String? priority,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (letterType != null) queryParams['letter_type'] = letterType;
    if (priority != null) queryParams['priority'] = priority;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    return await _apiService.get<ListResponse<Letter>>(
      ApiConstants.letters.sent,
      queryParameters: queryParams,
      fromJson: (json) => ListResponse<Letter>.fromJson(
        json,
        (item) => Letter.fromJson(item),
        'data',
      ),
    );
  }

  // Get letter by ID
  Future<ApiResponse<Letter>> getLetterById(String id) async {
    return await _apiService.get<Letter>(
      '${ApiConstants.letters.list}/$id',
      fromJson: (json) => Letter.fromJson(json),
    );
  }

  // Mark letter as read
  Future<ApiResponse<Letter>> markAsRead(String id) async {
    return await _apiService.put<Letter>(
      '${ApiConstants.letters.markRead}/$id',
      fromJson: (json) => Letter.fromJson(json),
    );
  }

  // Reply to letter
  Future<ApiResponse<Letter>> replyToLetter({
    required String originalLetterId,
    required String content,
    List<File>? attachments,
  }) async {
    // Handle file uploads first if attachments exist
    List<LetterAttachment> uploadedAttachments = [];
    
    if (attachments != null && attachments.isNotEmpty) {
      for (File file in attachments) {
        final uploadResponse = await _apiService.uploadFile<Map<String, dynamic>>(
          ApiConstants.letters.uploadAttachment,
          file,
          fieldName: 'attachment',
          fromJson: (json) => json as Map<String, dynamic>,
        );
        
        if (uploadResponse.success && uploadResponse.data != null) {
          uploadedAttachments.add(LetterAttachment.fromJson(uploadResponse.data!));
        }
      }
    }

    final response = await _apiService.post<Letter>(
      '${ApiConstants.letters.reply}/$originalLetterId',
      data: {
        'content': content,
        'attachments': uploadedAttachments.map((a) => a.toJson()).toList(),
      },
      fromJson: (json) => Letter.fromJson(json),
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after letter reply...');
      _apiService.clearCache();
    }
    
    return response;
  }

  // Get letter templates
  Future<ApiResponse<List<LetterTemplate>>> getTemplates({
    String? letterType,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{};

    if (letterType != null) queryParams['letter_type'] = letterType;
    if (category != null) queryParams['category'] = category;

    return await _apiService.get<List<LetterTemplate>>(
      ApiConstants.letters.templates,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((item) => LetterTemplate.fromJson(item))
          .toList(),
    );
  }

  // Get letter statistics
  Future<ApiResponse<LetterStatistics>> getLetterStatistics({
    String? userId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};

    if (userId != null) queryParams['user_id'] = userId;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    return await _apiService.get<LetterStatistics>(
      ApiConstants.letters.statistics,
      queryParameters: queryParams,
      fromJson: (json) => LetterStatistics.fromJson(json),
    );
  }

  // Delete letter
  Future<ApiResponse<String>> deleteLetter(String id) async {
    final response = await _apiService.delete<String>(
      '${ApiConstants.letters.list}/$id',
      fromJson: (json) => json?.toString() ?? 'Letter deleted successfully',
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after letter deletion...');
      _apiService.clearCache();
    }
    
    return response;
  }

  // Archive letter
  Future<ApiResponse<Letter>> archiveLetter(String id) async {
    final response = await _apiService.put<Letter>(
      '${ApiConstants.letters.archive}/$id',
      fromJson: (json) => Letter.fromJson(json),
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after letter archive...');
      _apiService.clearCache();
    }
    
    return response;
  }

  // Get archived letters
  Future<ApiResponse<ListResponse<Letter>>> getArchivedLetters({
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiService.get<ListResponse<Letter>>(
      ApiConstants.letters.archived,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => ListResponse<Letter>.fromJson(
        json,
        (item) => Letter.fromJson(item),
        'data',
      ),
    );
  }

  // Search letters
  Future<ApiResponse<ListResponse<Letter>>> searchLetters({
    required String query,
    int page = 1,
    int limit = 10,
    String? letterType,
    String? priority,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
      'page': page,
      'limit': limit,
    };

    if (letterType != null) queryParams['letter_type'] = letterType;
    if (priority != null) queryParams['priority'] = priority;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    return await _apiService.get<ListResponse<Letter>>(
      ApiConstants.letters.search,
      queryParameters: queryParams,
      fromJson: (json) => ListResponse<Letter>.fromJson(
        json,
        (item) => Letter.fromJson(item),
        'data',
      ),
    );
  }

  // Get pending responses
  Future<ApiResponse<List<Letter>>> getPendingResponses() async {
    return await _apiService.get<List<Letter>>(
      ApiConstants.letters.pendingResponses,
      fromJson: (json) => (json as List)
          .map((item) => Letter.fromJson(item))
          .toList(),
    );
  }

  // Get overdue responses
  Future<ApiResponse<List<Letter>>> getOverdueResponses() async {
    return await _apiService.get<List<Letter>>(
      ApiConstants.letters.overdueResponses,
      fromJson: (json) => (json as List)
          .map((item) => Letter.fromJson(item))
          .toList(),
    );
  }

  // ==================== ADMIN APPROVAL METHODS ====================

  // Get pending letters for admin approval
  Future<ApiResponse<ListResponse<Letter>>> getPendingLetters({
    int page = 1,
    int limit = 20,
    String? letterType,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (letterType != null) queryParams['letter_type'] = letterType;

    return await _apiService.get<ListResponse<Letter>>(
      ApiConstants.letters.pending,
      queryParameters: queryParams,
      fromJson: (json) {
        print('🔍 getPendingLetters fromJson - Input: $json');
        print('🔍 getPendingLetters fromJson - Input type: ${json.runtimeType}');
        
        try {
          // Handle different possible response structures
          if (json == null) {
            print('⚠️ getPendingLetters - json is null');
            return ListResponse<Letter>(items: []);
          }
          
          if (json is Map<String, dynamic>) {
            // Try multiple possible structures
            Map<String, dynamic>? dataObject;
            
            if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
              dataObject = json['data'] as Map<String, dynamic>;
              print('📋 getPendingLetters - Using json.data structure');
            } else {
              dataObject = json;
              print('📋 getPendingLetters - Using direct json structure');
            }
            
            return ListResponse<Letter>.fromJson(
              dataObject,
              (item) {
                print('🔍 Parsing letter item: ${item['subject'] ?? 'Unknown'}');
                return Letter.fromJson(item);
              },
              'letters', // Look for 'letters' key in the data object
            );
          } else {
            print('❌ getPendingLetters - json is not a Map: ${json.runtimeType}');
            return ListResponse<Letter>(items: []);
          }
        } catch (e, stackTrace) {
          print('❌ getPendingLetters fromJson error: $e');
          print('❌ getPendingLetters stackTrace: $stackTrace');
          return ListResponse<Letter>(items: []);
        }
      },
    );
  }

  // Approve letter request
  Future<ApiResponse<Map<String, dynamic>>> approveLetter(
    String letterId, {
    String? approvalNotes,
  }) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      ApiConstants.letters.statusById(letterId),
      data: {
        'status': 'approved',
        'approval_notes': approvalNotes ?? 'Letter request approved',
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after letter approval...');
      _apiService.clearCache();
    }
    
    return response;
  }

  // Reject letter request
  Future<ApiResponse<Map<String, dynamic>>> rejectLetter(
    String letterId, {
    String? reason,
  }) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      ApiConstants.letters.statusById(letterId),
      data: {
        'status': 'rejected',
        'reason': reason ?? 'Letter request rejected',
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after letter rejection...');
      _apiService.clearCache();
    }
    
    return response;
  }

  // Update letter status (generic method)
  Future<ApiResponse<Map<String, dynamic>>> updateLetterStatus(
    String letterId,
    String status, {
    String? reason,
  }) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      ApiConstants.letters.statusById(letterId),
      data: {
        'status': status,
        'reason': reason,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    if (response.success) {
      // Clear cache to force refresh on next load
      print('🧹 Clearing API cache after letter status update...');
      _apiService.clearCache();
    }
    
    return response;
  }

  // Export letters
  Future<ApiResponse<String>> exportLetters({
    required String startDate,
    required String endDate,
    String? format, // 'excel' or 'pdf'
    String? letterType,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'start_date': startDate,
      'end_date': endDate,
    };

    if (format != null) queryParams['format'] = format;
    if (letterType != null) queryParams['letter_type'] = letterType;
    if (status != null) queryParams['status'] = status;

    return await _apiService.get<String>(
      ApiConstants.letters.export,
      queryParameters: queryParams,
      fromJson: (json) => json?.toString() ?? '',
    );
  }
}
