import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/user_notification_service.dart';
import '../core/constants/colors.dart';

class UserNotificationBell extends StatefulWidget {
  const UserNotificationBell({Key? key}) : super(key: key);

  @override
  State<UserNotificationBell> createState() => _UserNotificationBellState();
}

class _UserNotificationBellState extends State<UserNotificationBell> {
  final _notificationService = UserNotificationService();
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
      builder: (context) => const UserNotificationBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
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

class UserNotificationBottomSheet extends StatefulWidget {
  const UserNotificationBottomSheet({Key? key}) : super(key: key);

  @override
  State<UserNotificationBottomSheet> createState() => _UserNotificationBottomSheetState();
}

class _UserNotificationBottomSheetState extends State<UserNotificationBottomSheet> {
  final _notificationService = UserNotificationService();

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
      builder: (context) => UserNotificationDetailDialog(notification: notification),
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
      case 'assignment':
        iconData = Icons.assignment;
        iconColor = Colors.blue;
        break;
      case 'reminder':
        iconData = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case 'alert':
        iconData = Icons.warning;
        iconColor = Colors.red;
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

class UserNotificationDetailDialog extends StatelessWidget {
  final Map<String, dynamic> notification;

  const UserNotificationDetailDialog({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = notification['data'] as Map<String, dynamic>?;
    final type = notification['type'] ?? 'general';

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            type == 'assignment' ? Icons.assignment : Icons.alarm,
            color: type == 'assignment' ? Colors.blue : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notification['title'] ?? 'Notification',
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
            Text(
              notification['message'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            
            if (data != null && type == 'assignment') ...[
              if (data['assigned_by'] != null)
                _buildDetailRow('Assigned By', data['assigned_by']),
              if (data['deadline'] != null)
                _buildDetailRow('Deadline', _formatDeadline(data['deadline'])),
            ],
            
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatTimestamp(notification['created_at'])}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (type == 'assignment' && data?['assignment_id'] != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/user/assignments',
                arguments: {'assignment_id': data!['assignment_id']},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('View Assignment'),
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

  String _formatDeadline(dynamic deadline) {
    if (deadline == null) return '-';
    try {
      final DateTime date = deadline is Timestamp 
          ? deadline.toDate() 
          : DateTime.parse(deadline.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return deadline.toString();
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final DateTime date = (timestamp as Timestamp).toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
