import 'package:flutter/material.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'pending', 'in-progress', 'completed', 'overdue'
  final String? assignedTo;
  final String? assignedBy;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.assignedBy,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing Assignment from JSON: ${json['title'] ?? 'Unknown Title'}');
      
      // Parse dueDate with Firestore timestamp support
      DateTime dueDate = DateTime.now();
      final dueDateData = json['dueDate'];
      if (dueDateData != null) {
        if (dueDateData is Map<String, dynamic> && dueDateData.containsKey('_seconds')) {
          // Firestore timestamp format
          final seconds = dueDateData['_seconds'] as int;
          final nanoseconds = dueDateData['_nanoseconds'] as int? ?? 0;
          dueDate = DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ~/ 1000000)
          );
        } else if (dueDateData is String) {
          dueDate = DateTime.tryParse(dueDateData) ?? DateTime.now();
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
      
      // Handle assignedTo - could be a list or string
      String? assignedTo;
      final assignedToData = json['assignedTo'];
      if (assignedToData != null) {
        if (assignedToData is List && assignedToData.isNotEmpty) {
          assignedTo = assignedToData.first?.toString();
        } else if (assignedToData is String) {
          assignedTo = assignedToData;
        }
      }
      
      return Assignment(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        dueDate: dueDate,
        priority: json['priority']?.toString() ?? 'medium',
        status: json['status']?.toString() ?? 'pending',
        assignedTo: assignedTo,
        assignedBy: json['assignedBy']?.toString(),
        createdBy: json['createdBy']?.toString(),
        createdAt: createdAt,
        updatedAt: updatedAt,
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
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? status,
    String? assignedTo,
    String? assignedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
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
    );
  }

  // Helper getters
  bool get isOverdue => DateTime.now().isAfter(dueDate) && status != 'completed';
  
  bool get isUpcoming => dueDate.isAfter(DateTime.now());
  
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