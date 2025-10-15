class User {
  final String id;
  final String employeeId;
  final String fullName;
  final String email;
  final String? department;
  final String? position;
  final String? phone;
  final String role;
  final String status;
  final bool isActive;
  final String? profilePicture;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  
  // Additional personal information
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? nationalId;
  final String? bankAccount;
  final String? bankName;
  final DateTime? hireDate;
  final double? salary;

  User({
    required this.id,
    required this.employeeId,
    required this.fullName,
    required this.email,
    this.department,
    this.position,
    this.phone,
    required this.role,
    required this.status,
    required this.isActive,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.nationalId,
    this.bankAccount,
    this.bankName,
    this.hireDate,
    this.salary,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 User.fromJson input data: $json');
      print('🔍 User.fromJson data type: ${json.runtimeType}');
      print('🔍 User.fromJson keys: ${json.keys.toList()}');
      
      // Validate input
      if (json.isEmpty) {
        print('❌ User.fromJson: Empty JSON data');
        throw ArgumentError('Empty JSON data provided to User.fromJson');
      }

      // Safely parse each field with null checks
      String safeStringParse(dynamic value, [String defaultValue = '']) {
        if (value == null) return defaultValue;
        return value.toString();
      }
      
      bool safeBoolParse(dynamic value, [bool defaultValue = false]) {
        if (value == null) return defaultValue;
        if (value is bool) return value;
        if (value is String) return value.toLowerCase() == 'true';
        return defaultValue;
      }
      
      double? safeDoubleParse(dynamic value) {
        if (value == null) return null;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          return parsed;
        }
        return null;
      }

      print('🔍 Parsing user with ID: ${json['id']}');
      print('🔍 User employee_id: ${json['employee_id']}');
      print('🔍 User employeeId: ${json['employeeId']}');

      return User(
        id: safeStringParse(json['id']),
        employeeId: safeStringParse(json['employee_id'] ?? json['employeeId']),
        fullName: safeStringParse(json['full_name'] ?? json['fullName']),
        email: safeStringParse(json['email']),
        department: json['department']?.toString(),
        position: json['position']?.toString(),
        phone: json['phone']?.toString(),
        role: safeStringParse(json['role'], 'employee'),
        status: safeStringParse(json['status'], 'active'),
        isActive: safeBoolParse(json['is_active'] ?? json['isActive'], true),
        profilePicture: json['profile_picture']?.toString(),
        createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
        updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
        lastLogin: _parseDateTime(json['last_login'] ?? json['lastLogin']),
        address: json['address']?.toString(),
        emergencyContact: json['emergency_contact']?.toString(),
        emergencyPhone: json['emergency_phone']?.toString(),
        dateOfBirth: _parseDateTime(json['date_of_birth'] ?? json['dateOfBirth']),
        gender: json['gender']?.toString(),
        maritalStatus: json['marital_status']?.toString(),
        nationalId: json['national_id']?.toString(),
        bankAccount: json['bank_account']?.toString(),
        bankName: json['bank_name']?.toString(),
        hireDate: _parseDateTime(json['hire_date'] ?? json['hireDate']),
        salary: safeDoubleParse(json['salary']),
      );
    } catch (e) {
      print('❌ Error in User.fromJson: $e');
      print('📋 Problematic data: $json');
      rethrow;
    }
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      if (dateValue is String) {
        if (dateValue.isEmpty) return null;
        return DateTime.parse(dateValue);
      } else if (dateValue is Map) {
        final dateMap = dateValue as Map<String, dynamic>;
        // Handle Firebase Timestamp
        if (dateMap.containsKey('_seconds')) {
          final seconds = dateMap['_seconds'];
          final nanoseconds = dateMap['_nanoseconds'] ?? 0;
          if (seconds != null) {
            return DateTime.fromMillisecondsSinceEpoch(
              (seconds as int) * 1000 + ((nanoseconds as int) ~/ 1000000)
            );
          }
        }
        // Handle Firestore Timestamp format
        if (dateMap.containsKey('seconds')) {
          final seconds = dateMap['seconds'];
          final nanoseconds = dateMap['nanoseconds'] ?? 0;
          if (seconds != null) {
            return DateTime.fromMillisecondsSinceEpoch(
              (seconds as int) * 1000 + ((nanoseconds as int) ~/ 1000000)
            );
          }
        }
      } else if (dateValue is num) {
        // Handle timestamp as number
        return DateTime.fromMillisecondsSinceEpoch(dateValue.toInt());
      }
      return null;
    } catch (e) {
      print('⚠️ Error parsing date: $e for value: $dateValue (${dateValue.runtimeType})');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'full_name': fullName,
      'email': email,
      'department': department,
      'position': position,
      'phone': phone,
      'role': role,
      'status': status,
      'is_active': isActive,
      'profile_picture': profilePicture,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'address': address,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'marital_status': maritalStatus,
      'national_id': nationalId,
      'bank_account': bankAccount,
      'bank_name': bankName,
      'hire_date': hireDate?.toIso8601String(),
      'salary': salary,
    };
  }

  User copyWith({
    String? id,
    String? employeeId,
    String? fullName,
    String? email,
    String? department,
    String? position,
    String? phone,
    String? role,
    String? status,
    bool? isActive,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? dateOfBirth,
    String? gender,
    String? maritalStatus,
    String? nationalId,
    String? bankAccount,
    String? bankName,
    DateTime? hireDate,
    double? salary,
  }) {
    return User(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      department: department ?? this.department,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      nationalId: nationalId ?? this.nationalId,
      bankAccount: bankAccount ?? this.bankAccount,
      bankName: bankName ?? this.bankName,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
    );
  }

  bool get isAdmin {
    // Check by role OR by standardized employee ID pattern
    final hasAdminRole = role == 'admin' || role == 'super_admin';
    final hasAdminEmployeeId = employeeId.startsWith('SUP') || employeeId.startsWith('ADM');
    return hasAdminRole || hasAdminEmployeeId;
  }
  
  bool get isSuperAdmin {
    // Check by role OR by SUP employee ID pattern
    return role == 'super_admin' || employeeId.startsWith('SUP');
  }
  bool get isEmployee => role == 'employee';
  
  String get displayRole {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'super_admin':
        return 'Super Administrator';
      case 'account_officer':
        return 'Account Officer';
      case 'security':
        return 'Security';
      case 'office_boy':
        return 'Office Boy';
      default:
        return 'Employee';
    }
  }
  
  // Additional helper methods
  bool get isHR => role == 'hr';
  bool get isManager => role == 'manager';
  
  String get initials {
    final names = fullName.split(' ');
    return names.map((name) => name.isNotEmpty ? name[0].toUpperCase() : '').join('');
  }
}

class LoginResponse {
  final User user;
  final String token;

  LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}