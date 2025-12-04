import 'package:flutter/material.dart';

class AssignmentDraft {
  final String name;
  final String description;
  final List<String> categories;
  final String priority; // Add priority field
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeOfDay? time;
  final String? link;

  AssignmentDraft({
    required this.name,
    required this.description,
    required this.categories,
    required this.priority, // Make priority required
    this.startDate,
    this.endDate,
    this.time,
    this.link,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'categories': categories,
      'priority': priority, // Add to JSON
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'time': time != null 
          ? "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}"
          : null,
      'link': link,
    };
  }
}
