import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AttendanceDetailDialog extends StatelessWidget {
  final String status;
  final String date;
  final String checkIn;
  final String checkOut;
  final String workHours;
  final String location;
  final String address;
  final String lat;
  final String long;
  final String? userName;
  final String? employeeId;
  final String? photoUrl;

  const AttendanceDetailDialog({
    super.key,
    required this.status,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.workHours,
    required this.location,
    required this.address,
    required this.lat,
    required this.long,
    this.userName,
    this.employeeId,
    this.photoUrl,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'present':
      case 'completed':
        return AppColors.primaryGreen;
      case 'late':
        return AppColors.vibrantOrange;
      case 'absent':
        return AppColors.errorRed;
      case 'leave':
      case 'sick':
        return Colors.blue;
      case 'working':
      case 'incomplete':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'present':
      case 'completed':
        return Icons.check_circle;
      case 'late':
        return Icons.access_time;
      case 'absent':
        return Icons.cancel;
      case 'leave':
      case 'sick':
        return Icons.local_hospital;
      case 'working':
        return Icons.work;
      case 'incomplete':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      case 'leave':
        return 'Leave';
      case 'sick':
        return 'Sick';
      case 'completed':
        return 'Completed';
      case 'working':
        return 'Working';
      case 'incomplete':
        return 'Incomplete';
      default:
        return status;
    }
  }

  Future<void> _viewPhoto() async {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      final uri = Uri.parse(photoUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _downloadPhoto() async {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      final uri = Uri.parse(photoUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attendance Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Employee Info
                  _buildInfoCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName ?? 'Employee User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                employeeId ?? 'EMP001',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor()),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(),
                                size: 14,
                                color: _getStatusColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusLabel(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Attendance Information
                  _buildInfoCard(
                    title: 'Attendance Information',
                    child: Column(
                      children: [
                        _buildDetailRow('Date', date),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildDetailRow('Check In', checkIn)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDetailRow('Check Out', checkOut)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildDetailRow('Status', status)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDetailRow('Work Hours', workHours)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location Information
                  _buildInfoCard(
                    title: 'Location Information',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildDetailRow('Location', location)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDetailRow('Detail Address', address)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildDetailRow('Lat', lat)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDetailRow('Long', long)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Proof of Attendance
                  if (photoUrl != null && photoUrl!.isNotEmpty)
                    _buildInfoCard(
                      title: 'Proof of Attendance',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                photoUrl!.split('/').last,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _viewPhoto,
                              child: Icon(
                                Icons.visibility,
                                size: 20,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _downloadPhoto,
                              child: Icon(
                                Icons.download,
                                size: 20,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}