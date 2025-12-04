# Admin Notification System

Complete notification system for account requests from login page to admin/superadmin dashboard.

## Overview

This system allows users without accounts to request access through the login page. Their request is sent as a notification to admin/superadmin users, who can review and approve/reject the request directly from the notification panel.

## Features

### 🔔 Real-time Notifications
- **Live Updates**: Notifications appear instantly in admin dashboard
- **Unread Counter**: Badge showing number of unread notifications
- **Auto-refresh**: StreamController-based architecture ensures latest data

### 📝 Account Requests
- **Login Page Form**: Users fill in: Full Name, Email, Phone, Division, Notes
- **Direct Submission**: Creates Firestore notification (no WhatsApp needed)
- **Status Tracking**: pending → approved/rejected

### 👥 Role-Based Access
- **Target Roles**: admin, super_admin, account_officer
- **Filtered Queries**: Only relevant roles see notifications
- **Permission Check**: isAdmin getter validates access

### 🎨 User Interface
- **Notification Bell**: Icon with red badge showing unread count
- **Bottom Sheet**: Slide-up panel with notification list
- **Detail Dialog**: Full request information with approve/reject actions
- **Visual Indicators**: Blue dot for unread, colored icons by type

## Architecture

### Services

#### `AdminNotificationService`
**Location**: `frontend/lib/core/services/admin_notification_service.dart`

**Key Methods**:
```dart
// Initialize with user context
await adminNotificationService.initialize();

// Create notification from login page
await createAccountRequest(
  fullName: 'John Doe',
  email: 'john@example.com',
  phone: '081234567890',
  division: 'IT',
  additionalNotes: 'Urgent request',
);

// Start real-time listener (admin only)
startNotificationsListener();

// Mark as read
await markAsRead(notificationId);

// Update request status
await updateAccountRequestStatus(
  notificationId: id,
  status: 'approved',
  adminNotes: 'Account created',
);

// Get unread count
final count = await getUnreadCount();
```

**Streams**:
- `notificationsStream`: Real-time notification list
- `unreadCountStream`: Real-time unread count

### Widgets

#### `NotificationBell`
**Location**: `frontend/lib/widgets/notification_bell.dart`

Icon button with badge, opens notification panel on tap.

**Usage**:
```dart
// In AppBar or header
const NotificationBell()
```

**Features**:
- Red badge with count (99+ if > 99)
- StreamBuilder for real-time updates
- Opens NotificationBottomSheet on tap

#### `NotificationBottomSheet`
Modal bottom sheet showing notification list.

**Features**:
- "Mark all read" button
- Scrollable list with cards
- Unread: blue background, bold text, blue dot
- Read: white background, normal text
- Tap to open NotificationDetailDialog
- Icon and color by notification type

#### `NotificationDetailDialog`
Full-screen dialog showing account request details.

**Features**:
- Request information: name, email, phone, division, notes
- Status badge: pending/approved/rejected
- Approve/Reject buttons (pending only)
- Loading state during processing
- Success/error feedback

#### `AccountRequestDialog`
**Location**: `frontend/lib/widgets/account_request_dialog.dart`

Form dialog for requesting new account from login page.

**Fields**:
- Full Name (required)
- Email (required, validated)
- Phone Number (required, 10-13 digits)
- Division (required)
- Additional Notes (optional)

**Features**:
- Form validation
- Loading state during submission
- Success confirmation dialog
- Error handling with SnackBar

## Firestore Structure

### Collection: `admin_notifications`

**Document Fields**:
```javascript
{
  type: 'account_request',           // Type of notification
  title: 'New Account Request',      // Notification title
  message: 'John Doe requested...',  // Short message
  
  data: {                            // Request-specific data
    full_name: 'John Doe',
    email: 'john@example.com',
    phone: '081234567890',
    division: 'IT',
    additional_notes: 'Urgent...'
  },
  
  is_read: false,                    // Read status
  target_roles: [                    // Who can see this
    'admin',
    'super_admin',
    'account_officer'
  ],
  
  status: 'pending',                 // pending, approved, rejected
  
  // Timestamps
  created_at: Timestamp,
  created_by: 'system',
  read_at: Timestamp,
  read_by: 'user_id',
  processed_at: Timestamp,
  processed_by: 'admin_id',
  
  admin_notes: 'Account created'     // Admin comments
}
```

### Queries

**Admin notifications** (used by service):
```dart
_firestore.collection('admin_notifications')
  .where('target_roles', arrayContains: userRole)
  .orderBy('created_at', descending: true)
  .limit(50)
```

**Unread count**:
```dart
_firestore.collection('admin_notifications')
  .where('target_roles', arrayContains: userRole)
  .where('is_read', isEqualTo: false)
  .get()
```

## Integration Points

### 1. Login Page
**File**: `frontend/lib/modules/auth/login_page.dart`

Changed "Add Account" link from WhatsApp to dialog:
```dart
GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => const AccountRequestDialog(),
    );
  },
  child: Text("Request Account"),
)
```

### 2. Admin Dashboard Header
**File**: `frontend/lib/modules/admin/dashboard/widgets/header.dart`

Replaced static bell icon with NotificationBell widget:
```dart
Row(
  children: [
    const NotificationBell(),  // ← Changed from CircleAvatar
    const SizedBox(width: 10),
    GestureDetector(...),  // Profile avatar
  ],
)
```

### 3. Admin Dashboard Page
**File**: `frontend/lib/modules/admin/dashboard/dashboard_page.dart`

Added import for notification bell:
```dart
import 'package:frontend/widgets/notification_bell.dart';
```

## Usage Guide

### For Users (Login Page)

1. Open login page
2. Click "Request Account" link at bottom
3. Fill in form:
   - Full Name
   - Email
   - Phone Number
   - Division
   - Additional Notes (optional)
4. Click "Submit Request"
5. See confirmation: "Request sent to admin"
6. Wait for email confirmation when account is created

### For Admins

1. Login to admin dashboard
2. See notification bell in top-right (next to profile)
3. Red badge shows unread count
4. Click bell to open notification panel
5. See list of notifications:
   - Blue background = unread
   - White background = read
   - Purple icon = account request
6. Click notification to see details
7. Review request information
8. Click "Approve" or "Reject"
9. Notification status updates to approved/rejected

### For Developers

**Initialize service** (already done in NotificationBell):
```dart
final service = AdminNotificationService();
await service.initialize();
```

**Create notification** (from any page):
```dart
await service.createAccountRequest(
  fullName: 'Jane Smith',
  email: 'jane@example.com',
  phone: '081234567890',
  division: 'HR',
);
```

**Listen to notifications**:
```dart
service.notificationsStream.listen((notifications) {
  print('${notifications.length} notifications');
});

service.unreadCountStream.listen((count) {
  print('$count unread notifications');
});
```

**Manual queries**:
```dart
// One-time fetch
final notifications = await service.getAllNotifications(limit: 20);
final unreadCount = await service.getUnreadCount();
```

## Testing

### Test Account Request Flow

1. **Logout** if logged in
2. Go to login page
3. Click "Request Account"
4. Fill in test data:
   ```
   Name: Test User
   Email: test@example.com
   Phone: 081234567890
   Division: IT Department
   Notes: This is a test request
   ```
5. Submit
6. Login as admin
7. Check notification bell (should show badge)
8. Open notifications
9. Click test notification
10. Approve or reject

### Test Real-time Updates

1. Open admin dashboard in two browser tabs (both logged in as admin)
2. In tab 1, click notification bell
3. In tab 2, use browser console to create notification:
   ```javascript
   // Open browser DevTools → Console
   // This simulates a new request
   ```
4. Watch tab 1 - notification should appear instantly

### Test Unread Counter

1. Create several notifications (use account request form multiple times)
2. Badge should show correct count
3. Open notification panel
4. Click "Mark all read"
5. Badge should disappear
6. Refresh page
7. Badge should stay hidden (read status persisted)

## Console Logs

The service prints logs for debugging:

- `🔔 AdminNotificationService initialized`
- `👤 User ID: [id]`
- `👑 Role: [role]`
- `✅ Account request notification created`
- `🔔 Admin Notifications updated: X total, Y unread`
- `✅ Notification marked as read: [id]`
- `✅ All notifications marked as read`
- `✅ Account request status updated: approved/rejected`
- `❌ Error messages with details`

## Notification Types

Currently implemented:
- **account_request**: New user requesting account (purple icon)

Extensible for future types:
- **alert**: Critical system alerts (orange icon)
- **info**: General information (blue icon)
- **announcement**: Company announcements (green icon)
- **reminder**: Task/deadline reminders (yellow icon)

## Security Considerations

### Current Setup
Firestore rules currently allow all access:
```javascript
match /{document=**} {
  allow read, write: if true;
}
```

### Production Recommendations

**Protect admin_notifications collection**:
```javascript
match /admin_notifications/{notificationId} {
  // Anyone can create (for account requests)
  allow create: if true;
  
  // Only admins can read
  allow read: if request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in 
    ['admin', 'super_admin', 'account_officer'];
  
  // Only admins can update/delete
  allow update, delete: if request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in 
    ['admin', 'super_admin', 'account_officer'];
}
```

**Validate notification data**:
```javascript
match /admin_notifications/{notificationId} {
  allow create: if 
    request.resource.data.keys().hasAll(['type', 'title', 'message', 'data']) &&
    request.resource.data.type == 'account_request' &&
    request.resource.data.data.keys().hasAll(['full_name', 'email', 'phone', 'division']);
}
```

## Dependencies

**Required packages** (already in `pubspec.yaml`):
- `cloud_firestore`: Firestore database
- `shared_preferences`: User context storage
- `provider`: State management (for auth)

**No additional packages needed** - uses existing dependencies.

## File Structure

```
frontend/
├── lib/
│   ├── core/
│   │   └── services/
│   │       ├── admin_notification_service.dart  ← Service
│   │       └── notification_service.dart        ← Old (permission-based)
│   ├── widgets/
│   │   ├── notification_bell.dart               ← Bell icon + badge
│   │   └── account_request_dialog.dart          ← Request form
│   └── modules/
│       ├── auth/
│       │   └── login_page.dart                  ← Changed to use dialog
│       └── admin/
│           └── dashboard/
│               └── widgets/
│                   └── header.dart              ← Uses NotificationBell
│
backend/
└── firestore.rules                              ← Security rules

NOTIFICATION_SYSTEM_README.md                    ← This file
```

## Troubleshooting

### Badge not showing
- Check console for "AdminNotificationService initialized"
- Verify user role is admin/super_admin/account_officer
- Check Firestore console for notifications with matching target_roles

### Notifications not updating
- Verify startNotificationsListener() was called
- Check console for "Admin Notifications updated: X total, Y unread"
- Ensure Firestore indexes are created (Firestore will prompt if needed)

### Cannot submit request
- Check console for errors
- Verify form validation passes
- Check network tab for Firestore write operation
- Ensure Firestore rules allow writes

### Approve/Reject not working
- Check user has admin role
- Verify notification ID is valid
- Check console for update errors
- Ensure Firestore connection is active

## Future Enhancements

### Planned Features
- ✅ Email notifications when request is approved/rejected
- ✅ Push notifications via Firebase Cloud Messaging
- ✅ Notification settings per admin (mute, frequency)
- ✅ Notification history page with filters
- ✅ Bulk operations (approve/reject multiple)
- ✅ Admin notes/comments on requests
- ✅ Auto-create user account on approval

### Extensibility
The system is designed to support multiple notification types. To add new type:

1. Create notification with custom type:
   ```dart
   await _firestore.collection('admin_notifications').add({
     'type': 'deadline_reminder',
     'title': 'Assignment Due Soon',
     'message': 'Task XYZ due in 2 hours',
     'data': {'assignment_id': '123', 'deadline': timestamp},
     // ... other fields
   });
   ```

2. Add icon mapping in NotificationBottomSheet:
   ```dart
   case 'deadline_reminder':
     iconData = Icons.access_time;
     iconColor = Colors.yellow;
     break;
   ```

3. Create custom detail dialog if needed (similar to NotificationDetailDialog)

## Support

For questions or issues:
1. Check console logs for error messages
2. Review Firestore console for data consistency
3. Verify user roles in SharedPreferences
4. Test with different admin accounts

## Changelog

**v1.0.0** - Initial Implementation
- AdminNotificationService with StreamControllers
- NotificationBell widget with badge
- NotificationBottomSheet with list view
- NotificationDetailDialog with approve/reject
- AccountRequestDialog for login page
- Integration with admin dashboard header
- Real-time updates with Firestore snapshots
- Firestore structure: admin_notifications collection
