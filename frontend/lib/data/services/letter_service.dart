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

    return await _apiService.post<Letter>(
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
      fromJson: (json) => ListResponse<Letter>.fromJson(
        json['data'], // Extract the 'data' object first
        (item) => Letter.fromJson(item),
        'letters', // Then look for 'letters' within 'data'
      ),
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

    return await _apiService.post<Letter>(
      '${ApiConstants.letters.reply}/$originalLetterId',
      data: {
        'content': content,
        'attachments': uploadedAttachments.map((a) => a.toJson()).toList(),
      },
      fromJson: (json) => Letter.fromJson(json),
    );
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
    return await _apiService.delete<String>(
      '${ApiConstants.letters.list}/$id',
      fromJson: (json) => json?.toString() ?? 'Letter deleted successfully',
    );
  }

  // Archive letter
  Future<ApiResponse<Letter>> archiveLetter(String id) async {
    return await _apiService.put<Letter>(
      '${ApiConstants.letters.archive}/$id',
      fromJson: (json) => Letter.fromJson(json),
    );
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
  Future<ApiResponse<List<Letter>>> getPendingLetters({
    int page = 1,
    int limit = 20,
    String? letterType,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (letterType != null) queryParams['letter_type'] = letterType;

    return await _apiService.get<List<Letter>>(
      '/letters/pending',
      queryParameters: queryParams,
      fromJson: (json) {
        if (json['data'] != null && json['data']['letters'] is List) {
          return (json['data']['letters'] as List)
              .map((item) => Letter.fromJson(item))
              .toList();
        }
        return <Letter>[];
      },
    );
  }

  // Approve letter request
  Future<ApiResponse<Map<String, dynamic>>> approveLetter(
    String letterId, {
    String? reason,
  }) async {
    return await _apiService.put<Map<String, dynamic>>(
      '/letters/$letterId/status',
      data: {
        'status': 'approved',
        'reason': reason ?? 'Letter request approved',
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Reject letter request
  Future<ApiResponse<Map<String, dynamic>>> rejectLetter(
    String letterId, {
    String? reason,
  }) async {
    return await _apiService.put<Map<String, dynamic>>(
      '/letters/$letterId/status',
      data: {
        'status': 'rejected',
        'reason': reason ?? 'Letter request rejected',
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Update letter status (generic method)
  Future<ApiResponse<Map<String, dynamic>>> updateLetterStatus(
    String letterId,
    String status, {
    String? reason,
  }) async {
    return await _apiService.put<Map<String, dynamic>>(
      '/letters/$letterId/status',
      data: {
        'status': status,
        'reason': reason,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
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
