import 'package:flutter/material.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime? startDate; // Start date of assignment period
  final DateTime dueDate; // End date / due date
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'pending', 'in-progress', 'completed', 'overdue'
  final List<String> assignedTo; // List of employee names/IDs
  final String? assignedBy;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags; // Tags/categories list
  final String category; // Main category
  final List<String> attachments; // Links/attachments
  
  // Completion tracking
  final String? completionTime; // HH:mm:ss format
  final String? completionDate; // yyyy-MM-dd format
  final DateTime? completedAt;
  final String? completedBy;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    this.startDate,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.assignedTo = const [],
    this.assignedBy,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.category = '',
    this.attachments = const [],
    this.completionTime,
    this.completionDate,
    this.completedAt,
    this.completedBy,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing Assignment from JSON: ${json['title'] ?? 'Unknown Title'}');
      
      // Parse startDate with Firestore timestamp support
      DateTime? startDate;
      final startDateData = json['startDate'];
      if (startDateData != null) {
        if (startDateData is Map<String, dynamic> && startDateData.containsKey('_seconds')) {
          final seconds = startDateData['_seconds'] as int;
          final nanoseconds = startDateData['_nanoseconds'] as int? ?? 0;
          startDate = DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ~/ 1000000),
            isUtc: false,
          );
        } else if (startDateData is String) {
          final parsed = DateTime.tryParse(startDateData);
          startDate = parsed?.toLocal();
        }
      }
      
      // Parse dueDate with Firestore timestamp support
      DateTime dueDate = DateTime.now();
      final dueDateData = json['dueDate'];
      if (dueDateData != null) {
        if (dueDateData is Map<String, dynamic> && dueDateData.containsKey('_seconds')) {
          // Firestore timestamp format
          final seconds = dueDateData['_seconds'] as int;
          final nanoseconds = dueDateData['_nanoseconds'] as int? ?? 0;
          dueDate = DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ~/ 1000000),
            isUtc: false, // Keep as local time
          );
        } else if (dueDateData is String) {
          // Parse as UTC then convert to local
          final parsed = DateTime.tryParse(dueDateData);
          dueDate = parsed != null ? parsed.toLocal() : DateTime.now();
        }
      }
      
      // Parse createdAt with Firestore timestamp support
      DateTime createdAt = DateTime.now();
      final createdAtData = json['createdAt'];
      if (createdAtData != null) {
        if (createdAtData is Map<String, dynamic> && createdAtData.containsKey('_seconds')) {
          // Firestore timestamp format
          final seconds = createdAtData['_seconds'] as int;
          final nanoseconds = createdAtData['_nanoseconds'] as int? ?? 0;
          createdAt = DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ~/ 1000000)
          );
        } else if (createdAtData is String) {
          createdAt = DateTime.tryParse(createdAtData) ?? DateTime.now();
        }
      }
      
      // Parse updatedAt with Firestore timestamp support
      DateTime? updatedAt;
      final updatedAtData = json['updatedAt'];
      if (updatedAtData != null) {
        if (updatedAtData is Map<String, dynamic> && updatedAtData.containsKey('_seconds')) {
          // Firestore timestamp format
          final seconds = updatedAtData['_seconds'] as int;
          final nanoseconds = updatedAtData['_nanoseconds'] as int? ?? 0;
          updatedAt = DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ~/ 1000000)
          );
        } else if (updatedAtData is String) {
          updatedAt = DateTime.tryParse(updatedAtData);
        }
      }
      
      // Handle assignedTo - prioritize assignedToNames if available, fallback to assignedTo IDs
      List<String> assignedTo = [];
      
      // First try to get names from assignedToNames field (new format)
      final assignedToNamesData = json['assignedToNames'];
      if (assignedToNamesData != null && assignedToNamesData is List && assignedToNamesData.isNotEmpty) {
        assignedTo = assignedToNamesData.map((e) => e.toString()).toList();
      } else {
        // Fallback to assignedTo field (could be IDs or names)
        final assignedToData = json['assignedTo'];
        if (assignedToData != null) {
          if (assignedToData is List) {
            assignedTo = assignedToData.map((e) => e.toString()).toList();
          } else if (assignedToData is String) {
            assignedTo = [assignedToData];
          }
        }
      }
      
      // Handle tags - could be a list or string
      List<String> tags = [];
      final tagsData = json['tags'];
      if (tagsData != null) {
        if (tagsData is List) {
          tags = tagsData.map((e) => e.toString()).toList();
        } else if (tagsData is String) {
          tags = [tagsData];
        }
      }
      
      // Handle attachments - could be a list or string
      List<String> attachments = [];
      final attachmentsData = json['attachments'];
      if (attachmentsData != null) {
        if (attachmentsData is List) {
          attachments = attachmentsData.map((e) => e.toString()).toList();
        } else if (attachmentsData is String) {
          attachments = [attachmentsData];
        }
      }
      
      // Parse completedAt timestamp
      DateTime? completedAt;
      final completedAtData = json['completedAt'];
      if (completedAtData != null) {
        if (completedAtData is Map<String, dynamic> && completedAtData.containsKey('_seconds')) {
          final seconds = completedAtData['_seconds'] as int;
          final nanoseconds = completedAtData['_nanoseconds'] as int? ?? 0;
          completedAt = DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ~/ 1000000),
          );
        } else if (completedAtData is String) {
          completedAt = DateTime.tryParse(completedAtData);
        }
      }
      
      return Assignment(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        startDate: startDate,
        dueDate: dueDate,
        priority: json['priority']?.toString() ?? 'medium',
        status: json['status']?.toString() ?? 'pending',
        assignedTo: assignedTo,
        assignedBy: json['assignedBy']?.toString(),
        createdBy: json['createdBy']?.toString(),
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags,
        category: json['category']?.toString() ?? '',
        attachments: attachments,
        completionTime: json['completionTime']?.toString(),
        completionDate: json['completionDate']?.toString(),
        completedAt: completedAt,
        completedBy: json['completedBy']?.toString(),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing Assignment from JSON: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ Problematic JSON: $json');
      
      // Return a default assignment object instead of throwing
      return Assignment(
        id: json['id']?.toString() ?? 'error_${DateTime.now().millisecondsSinceEpoch}',
        title: json['title']?.toString() ?? 'Error parsing assignment',
        description: 'Failed to parse assignment data',
        startDate: null,
        dueDate: DateTime.now(),
        priority: 'medium',
        status: 'pending',
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tags': tags,
      'category': category,
      'attachments': attachments,
      'completionTime': completionTime,
      'completionDate': completionDate,
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
    };
  }

  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? status,
    List<String>? assignedTo,
    String? assignedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? category,
    List<String>? attachments,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
    );
  }

  // Helper getters
  bool get isOverdue => DateTime.now().isAfter(dueDate) && status != 'completed';
  
  bool get isUpcoming => dueDate.isAfter(DateTime.now());
  
  String get formattedStartDate {
    if (startDate == null) return '';
    return '${startDate!.day}/${startDate!.month}/${startDate!.year}';
  }
  
  String get formattedDueDate {
    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }
  
  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFDC2626); // Red
      case 'medium':
        return const Color(0xFFEA580C); // Orange
      case 'low':
        return const Color(0xFF059669); // Green
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF059669); // Green
      case 'in-progress':
        return const Color(0xFF2563EB); // Blue
      case 'overdue':
        return const Color(0xFFDC2626); // Red
      case 'pending':
        return const Color(0xFFEA580C); // Orange
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  @override
  String toString() {
    return 'Assignment(id: $id, title: $title, status: $status, priority: $priority, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Assignment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}