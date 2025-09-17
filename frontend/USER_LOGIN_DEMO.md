# How to Test User vs Admin Login

The login page now supports role-based authentication. Here's how to test it:

## Demo Login Credentials

### For Admin Access:
- **Email**: `admin@bpr.com` (or any email containing "admin")
- **Password**: `any password`
- **Result**: Will route to `/admin/dashboard` (Admin Dashboard)

### For Regular User Access:
- **Email**: `user@bpr.com` (or any email NOT containing "admin")
- **Password**: `any password` 
- **Result**: Will route to `/user/dashboard` (User Dashboard)

## What You'll See

### Admin Dashboard Features:
- Employee management
- Attendance management for all users
- Assignment management (create/assign tasks)
- Letter approval system
- Reports and analytics

### User Dashboard Features:
- Personal attendance (clock in/out)
- View assigned tasks
- Submit leave/permission letters
- Personal profile management
- Activity history

## How It Works

The app now determines user roles based on the email:
- If email contains "admin" → routes to admin pages
- Otherwise → routes to user pages

This is a demo implementation. In production, you would:
1. Connect to the backend API
2. Verify actual credentials
3. Get user role from the database
4. Store authentication token

## Testing Steps

1. Open the app
2. Wait for splash screen
3. Enter one of the demo emails above
4. Enter any password
5. Click "SIGN IN"
6. You'll be routed to the appropriate dashboard based on the email

## UI Differences

- **Admin**: Red/orange accent colors, management features
- **User**: Blue/green accent colors, personal features
- **Navigation**: Different bottom navigation items for each role
