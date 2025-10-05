# BPR Absence - Frontend Backend Integration

## Overview

This document outlines the successful integration between the Flutter frontend and Node.js backend for the BPR Absence system. The integration provides a complete employee management solution with authentication, attendance tracking, and letter management.

## Architecture

### Backend (Node.js + Express + Firebase)
- **Authentication**: JWT-based authentication with role-based access control
- **Database**: Firebase Firestore for scalable data storage
- **API**: RESTful API with comprehensive endpoints
- **Features**: User management, attendance tracking, letter system, admin dashboard
- **Testing**: 96.6% success rate (28/29 tests passing)

### Frontend (Flutter)
- **State Management**: Provider pattern for reactive UI updates
- **HTTP Client**: Dio for robust API communication
- **Storage**: SharedPreferences for local token storage
- **UI**: Material Design with custom theming
- **Architecture**: Clean architecture with separation of concerns

## Integration Layer

### 1. API Configuration (`lib/data/constants/api_constants.dart`)
```dart
class ApiConstants {
  // Environment-specific URLs
  static const String developmentUrl = 'http://localhost:3000/api';
  static const String productionUrl = 'https://your-domain.com/api';
  
  // Comprehensive endpoint definitions
  static const AuthEndpoints auth = AuthEndpoints();
  static const AttendanceEndpoints attendance = AttendanceEndpoints();
  static const LetterEndpoints letters = LetterEndpoints();
  static const UserEndpoints users = UserEndpoints();
}
```

### 2. Data Models
- **User Model**: Complete user representation with role-based helpers
- **Attendance Model**: Attendance tracking with location and statistics
- **Letter Model**: Letter management with attachments and responses
- **API Response**: Standardized response handling with error management

### 3. HTTP Service Layer (`lib/data/services/api_service.dart`)
- **Centralized HTTP client** with Dio configuration
- **Automatic token management** and injection
- **Request/Response interceptors** for logging and error handling
- **Generic CRUD operations** with type safety
- **File upload support** for attachments

### 4. Authentication Service (`lib/data/services/auth_service.dart`)
- **Login/Logout** with automatic token storage
- **User registration** and profile management
- **Password reset** and email verification
- **Token refresh** and validation
- **Role-based access control**

### 5. State Management (`lib/data/providers/`)
- **AuthProvider**: Authentication state and user management
- **AttendanceProvider**: Attendance tracking and statistics
- **Real-time updates** with Provider notifications
- **Error handling** and loading states

## Key Features Implemented

### 🔐 Authentication
- Secure JWT-based login/logout
- Role-based access control (Admin, HR, Manager, Employee)
- Password reset and email verification
- Automatic token refresh
- Persistent authentication state

### 📊 Attendance Management
- GPS-based check-in/check-out
- Real-time attendance tracking
- Working hours calculation
- Late arrival detection
- Attendance statistics and reports
- Photo verification support

### 📝 Letter System
- Letter composition and sending
- Template-based letters
- Response tracking and deadlines
- File attachments
- Letter archiving and search
- Priority and status management

### 👥 User Management
- User creation and profile management
- Department and role assignments
- User search and filtering
- Bulk operations
- Activity tracking

## API Endpoints Integration

### Authentication
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `GET /auth/profile` - Get current user
- `PUT /auth/profile` - Update profile
- `POST /auth/forgot-password` - Password reset request
- `POST /auth/reset-password` - Reset password

### Attendance
- `POST /attendance/check-in` - Check-in with location
- `PUT /attendance/check-out/:id` - Check-out
- `GET /attendance/current` - Current attendance status
- `GET /attendance/list` - Attendance history
- `GET /attendance/statistics` - Attendance statistics

### Letters
- `POST /letters/send` - Send new letter
- `GET /letters/received` - Received letters
- `GET /letters/sent` - Sent letters
- `PUT /letters/mark-read/:id` - Mark as read
- `POST /letters/reply/:id` - Reply to letter

### Users (Admin)
- `GET /users/list` - List all users
- `POST /users/create` - Create new user
- `PUT /users/:id` - Update user
- `DELETE /users/:id` - Delete user
- `GET /users/statistics` - User statistics

## Security Implementation

### Frontend Security
- Secure token storage using SharedPreferences
- Automatic token injection in requests
- Token validation and refresh
- Input validation and sanitization
- Error message sanitization

### Backend Security
- JWT token authentication
- Role-based middleware
- Input validation with Joi
- Rate limiting
- CORS configuration
- Firebase security rules

## Configuration

### Environment Setup
1. **Backend Configuration**:
   ```bash
   cd backend
   npm install
   # Configure Firebase credentials
   npm start
   ```

2. **Frontend Configuration**:
   ```bash
   cd frontend
   flutter pub get
   # Update API_URL in api_constants.dart
   flutter run
   ```

### API URL Configuration
Update the API URL in `lib/data/constants/api_constants.dart`:
```dart
static String get baseUrl {
  // Change this for different environments
  return developmentUrl; // or productionUrl
}
```

## Testing

### Backend Tests
- 96.6% success rate (28/29 tests passing)
- Comprehensive API endpoint testing
- Authentication and authorization tests
- Database operation tests

### Frontend Tests
- Unit tests for models and services
- Widget tests for UI components
- Integration tests for API communication
- Provider state management tests

Run tests:
```bash
# Backend
cd backend && npm test

# Frontend
cd frontend && flutter test
```

## Usage Examples

### Login Implementation
```dart
// Using AuthProvider
final authProvider = context.read<AuthProvider>();
final success = await authProvider.login(
  email: 'user@example.com',
  password: 'password123',
);

if (success) {
  // Navigate to dashboard based on role
  final user = authProvider.currentUser;
  // Handle navigation...
}
```

### Attendance Check-in
```dart
// Using AttendanceProvider
final attendanceProvider = context.read<AttendanceProvider>();
final success = await attendanceProvider.checkIn(
  latitude: -6.2088,
  longitude: 106.8456,
  notes: 'On time arrival',
);

if (success) {
  // Update UI
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Checked in successfully')),
  );
}
```

## Error Handling

### API Error Responses
All API responses follow a consistent format:
```json
{
  "success": false,
  "message": "User-friendly error message",
  "error": "Technical error details",
  "data": null
}
```

### Frontend Error Handling
- Automatic error display in UI
- Network error detection
- Token expiration handling
- Retry mechanisms for failed requests

## Performance Optimizations

### Frontend
- Lazy loading of data
- Pagination for large lists
- Image caching for avatars
- Debounced search inputs
- Optimistic UI updates

### Backend
- Database query optimization
- Response caching
- File upload optimization
- Rate limiting
- Connection pooling

## Future Enhancements

### Planned Features
1. **Real-time Notifications**: Push notifications for letters and attendance
2. **Offline Support**: Local data caching for offline operation
3. **Biometric Authentication**: Fingerprint/face recognition
4. **Advanced Analytics**: Detailed reporting and analytics
5. **Multi-language Support**: Internationalization
6. **Mobile-specific Features**: Camera integration, geofencing

### Technical Improvements
1. **GraphQL Integration**: More efficient data fetching
2. **WebSocket Support**: Real-time updates
3. **Advanced Caching**: Redis integration
4. **Microservices Architecture**: Service decomposition
5. **CI/CD Pipeline**: Automated testing and deployment

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure backend server is running on correct port
   - Check API URL configuration
   - Verify network connectivity

2. **Authentication Errors**
   - Check token expiration
   - Verify JWT secret configuration
   - Clear local storage and re-login

3. **CORS Issues**
   - Configure CORS in backend
   - Check allowed origins
   - Verify request headers

### Debug Tips
- Enable request/response logging in Dio interceptors
- Use Flutter Inspector for widget debugging
- Monitor Firebase console for backend logs
- Use Postman for API testing

## Support

For technical support or questions about the integration:
- Check the comprehensive test suite for API examples
- Review the provider implementations for state management patterns
- Consult the service layer for API communication patterns
- Reference the model classes for data structure definitions

The integration provides a robust foundation for the BPR Absence system with room for future enhancements and scalability.