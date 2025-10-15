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
    return Assignment(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dueDate: json['dueDate'] != null 
          ? DateTime.tryParse(json['dueDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'pending',
      assignedTo: json['assignedTo']?.toString(),
      assignedBy: json['assignedBy']?.toString(),
      createdBy: json['createdBy']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
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