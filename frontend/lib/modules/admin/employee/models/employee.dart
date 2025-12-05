import 'package:flutter/foundation.dart';

@immutable
class Employee {
  final String? id; // Add user ID for updates
  final String? fullName;
  final String? email;
  final String? password; // biasanya jangan ditampilkan
  final String? role;
  final String? mobileNumber;
  final String? gender; // 'Male' | 'Female'
  final String? placeOfBirth;
  final DateTime? dateOfBirth;

  // Employment
  final String? position;
  final String? contractType; // '3 Months' | '6 Months' | '1 Year'
  final String? division;
  final String? department;
  final String? lastEducation; // 'High School' | 'Diploma' | 'Bachelor' | 'Master'
  final String? nik;

  // Banking
  final String? bank; // 'BCA' | 'BRI' | 'Mandiri' | 'BNI'
  final String? accountHolderName;
  final String? accountNumber;

  // Other
  final String? warningLetterType; // 'SP1' | 'SP2' | 'SP3' | 'None'
  final String? emergencyContact;

  // Work Schedule
  final String? workStartTime; // HH:mm format e.g., '08:00'
  final String? workEndTime; // HH:mm format e.g., '17:00'
  final int? lateThresholdMinutes; // e.g., 15 minutes
  
  // Shift Configuration (for roles with multiple shifts)
  final String? shiftType; // 'Single Shift' | 'Double Shift (Morning/Evening)' | 'Custom Hours'
  final String? shift2StartTime; // HH:mm format for second shift
  final String? shift2EndTime; // HH:mm format for second shift

  const Employee({
    this.id,
    this.fullName,
    this.email,
    this.password,
    this.role,
    this.mobileNumber,
    this.gender,
    this.placeOfBirth,
    this.dateOfBirth,
    this.position,
    this.contractType,
    this.division,
    this.department,
    this.lastEducation,
    this.nik,
    this.bank,
    this.accountHolderName,
    this.accountNumber,
    this.warningLetterType,
    this.emergencyContact,
    this.workStartTime,
    this.workEndTime,
    this.lateThresholdMinutes,
    this.shiftType,
    this.shift2StartTime,
    this.shift2EndTime,
  });

  Employee copyWith({
    String? fullName,
    String? email,
    String? password,
    String? role,
    String? mobileNumber,
    String? gender,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    String? position,
    String? contractType,
    String? division,
    String? department,
    String? lastEducation,
    String? nik,
    String? bank,
    String? accountHolderName,
    String? accountNumber,
    String? warningLetterType,
    String? emergencyContact,
    String? workStartTime,
    String? workEndTime,
    int? lateThresholdMinutes,
    String? shiftType,
    String? shift2StartTime,
    String? shift2EndTime,
  }) {
    return Employee(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      gender: gender ?? this.gender,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      position: position ?? this.position,
      contractType: contractType ?? this.contractType,
      division: division ?? this.division,
      department: department ?? this.department,
      lastEducation: lastEducation ?? this.lastEducation,
      nik: nik ?? this.nik,
      bank: bank ?? this.bank,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      warningLetterType: warningLetterType ?? this.warningLetterType,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      lateThresholdMinutes: lateThresholdMinutes ?? this.lateThresholdMinutes,
      shiftType: shiftType ?? this.shiftType,
      shift2StartTime: shift2StartTime ?? this.shift2StartTime,
      shift2EndTime: shift2EndTime ?? this.shift2EndTime,
    );
  }
}
