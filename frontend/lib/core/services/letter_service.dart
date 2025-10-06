import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LetterService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Get authorization token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Get headers with authorization
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
  
  // Get all letters with filtering
  static Future<LetterResponse> getLetters({
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final uri = Uri.parse('$baseUrl/letters').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LetterResponse.fromJson(data);
      } else {
        throw Exception('Failed to load letters: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting letters: $e');
      throw Exception('Failed to load letters: $e');
    }
  }
  
  // Get letter statistics
  static Future<LetterStatistics> getLetterStatistics() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/letters/statistics'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LetterStatistics.fromJson(data['data']);
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting letter statistics: $e');
      throw Exception('Failed to load statistics: $e');
    }
  }
  
  // Submit new letter
  static Future<bool> submitLetter({
    required String letterType,
    required String subject,
    required String content,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final body = {
        'letter_type': letterType,
        'subject': subject,
        'content': content,
        'priority': 'medium',
        if (additionalData != null) ...additionalData,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/letters'),
        headers: headers,
        body: json.encode(body),
      );
      
      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to submit letter: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting letter: $e');
      return false;
    }
  }
}

// Data models
class LetterResponse {
  final bool success;
  final List<Letter> letters;
  final LetterPagination pagination;
  
  LetterResponse({
    required this.success,
    required this.letters,
    required this.pagination,
  });
  
  factory LetterResponse.fromJson(Map<String, dynamic> json) {
    return LetterResponse(
      success: json['success'] ?? false,
      letters: (json['data']['letters'] as List?)
          ?.map((item) => Letter.fromJson(item))
          .toList() ?? [],
      pagination: LetterPagination.fromJson(json['data']['pagination'] ?? {}),
    );
  }
}

class Letter {
  final String id;
  final String letterNumber;
  final String letterType;
  final String subject;
  final String content;
  final String recipientName;
  final String recipientEmployeeId;
  final String recipientDepartment;
  final String senderName;
  final String senderPosition;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final List<ApprovalHistory> approvalHistory;
  final Map<String, dynamic>? additionalInfo;
  
  Letter({
    required this.id,
    required this.letterNumber,
    required this.letterType,
    required this.subject,
    required this.content,
    required this.recipientName,
    required this.recipientEmployeeId,
    required this.recipientDepartment,
    required this.senderName,
    required this.senderPosition,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    required this.approvalHistory,
    this.additionalInfo,
  });
  
  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'] ?? '',
      letterNumber: json['letter_number'] ?? '',
      letterType: json['letter_type'] ?? '',
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      recipientName: json['recipient_name'] ?? '',
      recipientEmployeeId: json['recipient_employee_id'] ?? '',
      recipientDepartment: json['recipient_department'] ?? '',
      senderName: json['sender_name'] ?? '',
      senderPosition: json['sender_position'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? 'medium',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      approvalHistory: (json['approval_history'] as List?)
          ?.map((item) => ApprovalHistory.fromJson(item))
          .toList() ?? [],
      additionalInfo: json['medical_info'] ?? json['vacation_info'] ?? json['wfh_info'],
    );
  }
}

class ApprovalHistory {
  final String action;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String notes;
  
  ApprovalHistory({
    required this.action,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.notes,
  });
  
  factory ApprovalHistory.fromJson(Map<String, dynamic> json) {
    return ApprovalHistory(
      action: json['action'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class LetterPagination {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;
  
  LetterPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
  
  factory LetterPagination.fromJson(Map<String, dynamic> json) {
    return LetterPagination(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalRecords: json['total_records'] ?? 0,
      limit: json['limit'] ?? 20,
      hasNextPage: json['has_next_page'] ?? false,
      hasPrevPage: json['has_prev_page'] ?? false,
    );
  }
}

class LetterStatistics {
  final int totalLetters;
  final int pendingLetters;
  final int approvedLetters;
  final int rejectedLetters;
  final Map<String, int> lettersByType;
  
  LetterStatistics({
    required this.totalLetters,
    required this.pendingLetters,
    required this.approvedLetters,
    required this.rejectedLetters,
    required this.lettersByType,
  });
  
  factory LetterStatistics.fromJson(Map<String, dynamic> json) {
    return LetterStatistics(
      totalLetters: json['total_letters'] ?? 0,
      pendingLetters: json['pending_letters'] ?? 0,
      approvedLetters: json['approved_letters'] ?? 0,
      rejectedLetters: json['rejected_letters'] ?? 0,
      lettersByType: Map<String, int>.from(json['letters_by_type'] ?? {}),
    );
  }
}