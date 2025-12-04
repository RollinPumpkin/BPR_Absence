import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/admin_notification_service.dart';
import '../core/constants/colors.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({Key? key}) : super(key: key);

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _notificationService = AdminNotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    
    // Listen to unread count stream
    _notificationService.unreadCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    });
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: _showNotifications,
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class NotificationBottomSheet extends StatefulWidget {
  const NotificationBottomSheet({Key? key}) : super(key: key);

  @override
  State<NotificationBottomSheet> createState() => _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<NotificationBottomSheet> {
  final _notificationService = AdminNotificationService();

  void _markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    // Mark as read when opened
    if (notification['is_read'] == false) {
      _notificationService.markAsRead(notification['id']);
    }

    showDialog(
      context: context,
      builder: (context) => NotificationDetailDialog(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _markAllAsRead,
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Mark all read'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          
          // Notification list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _notificationService.notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No notifications',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final notifications = snapshot.data!;
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final isUnread = notification['is_read'] == false;
                    final type = notification['type'] ?? 'general';
                    
                    return Card(
                      color: isUnread ? Colors.blue.shade50 : Colors.white,
                      child: ListTile(
                        leading: _getNotificationIcon(type, isUnread),
                        title: Text(
                          notification['title'] ?? 'Notification',
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['message'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(notification['created_at']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: isUnread
                            ? const Icon(Icons.circle, size: 12, color: Colors.blue)
                            : null,
                        onTap: () => _showNotificationDetail(notification),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getNotificationIcon(String type, bool isUnread) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'account_request':
        iconData = Icons.person_add;
        iconColor = Colors.purple;
        break;
      case 'alert':
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'info':
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: isUnread ? iconColor.withOpacity(0.2) : Colors.grey.shade200,
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final DateTime dateTime = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}

class NotificationDetailDialog extends StatefulWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailDialog({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  State<NotificationDetailDialog> createState() => _NotificationDetailDialogState();
}

class _NotificationDetailDialogState extends State<NotificationDetailDialog> {
  final _notificationService = AdminNotificationService();
  bool _isProcessing = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isProcessing = true);

    final success = await _notificationService.updateAccountRequestStatus(
      notificationId: widget.notification['id'],
      status: status,
    );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${status == "approved" ? "approved" : "rejected"}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.notification['data'] as Map<String, dynamic>?;
    final status = widget.notification['status'] ?? 'pending';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person_add, color: AppColors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.notification['title'] ?? 'Notification',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Account request details
            if (data != null) ...[
              _buildDetailRow('Full Name', data['full_name']),
              _buildDetailRow('Email', data['email']),
              _buildDetailRow('Phone', data['phone']),
              _buildDetailRow('Division', data['division']),
              if (data['additional_notes'] != null)
                _buildDetailRow('Notes', data['additional_notes']),
            ],
            
            const SizedBox(height: 16),
            Text(
              widget.notification['message'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        if (status == 'pending' && !_isProcessing) ...[
          TextButton.icon(
            onPressed: () => _updateStatus('rejected'),
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            onPressed: () => _updateStatus('approved'),
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        if (_isProcessing)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
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
            value ?? '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
