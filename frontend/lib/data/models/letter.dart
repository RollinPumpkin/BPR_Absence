class Letter {
  final String id;
  final String recipientId;
  final String senderId;
  final String subject;
  final String content;
  final String letterType;
  final String status;
  final String priority;
  final String? letterNumber;
  final DateTime? letterDate;
  final bool requiresResponse;
  final DateTime? responseDeadline;
  final bool responseReceived;
  final String? responseContent;
  final DateTime? responseDate;
  final List<LetterAttachment> attachments;
  final List<String> ccRecipients;
  final String? templateUsed;
  final String? referenceNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // User details
  final String? recipientName;
  final String? recipientEmployeeId;
  final String? recipientDepartment;
  final String? senderName;
  final String? senderPosition;

  Letter({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.subject,
    required this.content,
    required this.letterType,
    required this.status,
    required this.priority,
    this.letterNumber,
    this.letterDate,
    required this.requiresResponse,
    this.responseDeadline,
    required this.responseReceived,
    this.responseContent,
    this.responseDate,
    required this.attachments,
    required this.ccRecipients,
    this.templateUsed,
    this.referenceNumber,
    this.createdAt,
    this.updatedAt,
    this.recipientName,
    this.recipientEmployeeId,
    this.recipientDepartment,
    this.senderName,
    this.senderPosition,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'] ?? '',
      recipientId: json['recipient_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      letterType: json['letter_type'] ?? '',
      status: json['status'] ?? 'sent',
      priority: json['priority'] ?? 'normal',
      letterNumber: json['letter_number'],
      letterDate: _parseFirestoreTimestamp(json['letter_date']),
      requiresResponse: json['requires_response'] ?? false,
      responseDeadline: _parseFirestoreTimestamp(json['response_deadline']),
      responseReceived: json['response_received'] ?? false,
      responseContent: json['response_content'],
      responseDate: _parseFirestoreTimestamp(json['response_date']),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((item) => LetterAttachment.fromJson(item))
          .toList() ?? [],
      ccRecipients: List<String>.from(json['cc_recipients'] ?? []),
      templateUsed: json['template_used'],
      referenceNumber: json['reference_number'],
      createdAt: _parseFirestoreTimestamp(json['created_at']),
      updatedAt: _parseFirestoreTimestamp(json['updated_at']),
      recipientName: json['recipient_name'],
      recipientEmployeeId: json['recipient_employee_id'],
      recipientDepartment: json['recipient_department'],
      senderName: json['sender_name'],
      senderPosition: json['sender_position'],
    );
  }

  // Helper method to parse Firestore timestamp format
  static DateTime? _parseFirestoreTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    
    if (timestamp is Map<String, dynamic>) {
      // Firestore timestamp format: {"_seconds": 1234567890, "_nanoseconds": 123000000}
      if (timestamp.containsKey('_seconds')) {
        final seconds = timestamp['_seconds'] as int;
        final nanoseconds = timestamp['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000)
        );
      }
    }
    
    if (timestamp is String) {
      // Regular ISO string format
      try {
        return DateTime.parse(timestamp);
      } catch (_) {
        return null;
      }
    }
    
    return null;
  }

  String get displayType {
    switch (letterType) {
      case 'warning':
        return 'Warning Letter';
      case 'promotion':
        return 'Promotion Letter';
      case 'transfer':
        return 'Transfer Notice';
      case 'termination':
        return 'Termination Letter';
      case 'appreciation':
        return 'Appreciation Letter';
      case 'memo':
        return 'Memo';
      case 'announcement':
        return 'Announcement';
      default:
        return 'Letter';
    }
  }

  String get displayPriority {
    switch (priority) {
      case 'urgent':
        return 'Urgent';
      case 'high':
        return 'High';
      case 'normal':
        return 'Normal';
      case 'low':
        return 'Low';
      default:
        return 'Normal';
    }
  }

  bool get isOverdue {
    if (!requiresResponse || responseReceived || responseDeadline == null) {
      return false;
    }
    return DateTime.now().isAfter(responseDeadline!);
  }
}

class LetterAttachment {
  final String filename;
  final String fileUrl;
  final int? fileSize;
  final String? fileType;

  LetterAttachment({
    required this.filename,
    required this.fileUrl,
    this.fileSize,
    this.fileType,
  });

  factory LetterAttachment.fromJson(Map<String, dynamic> json) {
    return LetterAttachment(
      filename: json['filename'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileSize: json['file_size'],
      fileType: json['file_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'file_url': fileUrl,
      'file_size': fileSize,
      'file_type': fileType,
    };
  }
}

class LetterTemplate {
  final String id;
  final String name;
  final String letterType;
  final String subjectTemplate;
  final String contentTemplate;
  final List<String> variables;
  final String category;
  final bool requiresResponse;
  final String defaultPriority;

  LetterTemplate({
    required this.id,
    required this.name,
    required this.letterType,
    required this.subjectTemplate,
    required this.contentTemplate,
    required this.variables,
    required this.category,
    required this.requiresResponse,
    required this.defaultPriority,
  });

  factory LetterTemplate.fromJson(Map<String, dynamic> json) {
    return LetterTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      letterType: json['letter_type'] ?? '',
      subjectTemplate: json['subject_template'] ?? '',
      contentTemplate: json['content_template'] ?? '',
      variables: List<String>.from(json['variables'] ?? []),
      category: json['category'] ?? '',
      requiresResponse: json['requires_response'] ?? false,
      defaultPriority: json['default_priority'] ?? 'normal',
    );
  }
}

class LetterStatistics {
  final int totalLetters;
  final int sentLetters;
  final int readLetters;
  final int pendingResponses;
  final int respondedLetters;
  final int overdueResponses;
  final Map<String, int> byType;
  final Map<String, int> byPriority;

  LetterStatistics({
    required this.totalLetters,
    required this.sentLetters,
    required this.readLetters,
    required this.pendingResponses,
    required this.respondedLetters,
    required this.overdueResponses,
    required this.byType,
    required this.byPriority,
  });

  factory LetterStatistics.fromJson(Map<String, dynamic> json) {
    return LetterStatistics(
      totalLetters: json['total_letters'] ?? 0,
      sentLetters: json['sent_letters'] ?? 0,
      readLetters: json['read_letters'] ?? 0,
      pendingResponses: json['pending_responses'] ?? 0,
      respondedLetters: json['responded_letters'] ?? 0,
      overdueResponses: json['overdue_responses'] ?? 0,
      byType: Map<String, int>.from(json['by_type'] ?? {}),
      byPriority: Map<String, int>.from(json['by_priority'] ?? {}),
    );
  }
}