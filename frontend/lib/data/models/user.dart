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
    return User(
      id: json['id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'],
      position: json['position'],
      phone: json['phone'],
      role: json['role'] ?? 'employee',
      status: json['status'] ?? 'active',
      isActive: json['is_active'] ?? false,
      profilePicture: json['profile_picture'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      lastLogin: _parseDateTime(json['last_login']),
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      emergencyPhone: json['emergency_phone'],
      dateOfBirth: _parseDateTime(json['date_of_birth']),
      gender: json['gender'],
      maritalStatus: json['marital_status'],
      nationalId: json['national_id'],
      bankAccount: json['bank_account'],
      bankName: json['bank_name'],
      hireDate: _parseDateTime(json['hire_date']),
      salary: json['salary']?.toDouble(),
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is Map<String, dynamic>) {
        // Handle Firebase Timestamp
        if (dateValue.containsKey('_seconds')) {
          return DateTime.fromMillisecondsSinceEpoch(
            dateValue['_seconds'] * 1000 + (dateValue['_nanoseconds'] ~/ 1000000)
          );
        }
      }
      return null;
    } catch (e) {
      print('Error parsing date: $e');
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

  bool get isAdmin => role == 'admin' || role == 'account_officer';
  bool get isEmployee => role == 'employee';
  
  String get displayRole {
    switch (role) {
      case 'admin':
        return 'Administrator';
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