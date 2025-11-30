// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

class UserModel {
  String id;
  String name;
  String email;
  String phone;
  String role;
  String? institutionId;
  bool isVerified;
  DateTime createdAt;

  // Additional fields for students
  String? studentId;
  String? course;
  String? address;

  // Additional fields for institutions
  String? institutionCode;
  String? principalName;
  String? institutionType;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.institutionId,
    required this.isVerified,
    required this.createdAt,
    this.studentId,
    this.course,
    this.address,
    this.institutionCode,
    this.principalName,
    this.institutionType,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? AppConstants.STUDENT,
      institutionId: map['institutionId'],
      isVerified: map['isVerified'] ?? false,
      // Handle both Timestamp and int for createdAt
      createdAt: _parseDateTime(map['createdAt']),
      studentId: map['studentId'],
      course: map['course'],
      address: map['address'],
      institutionCode: map['institutionCode'],
      principalName: map['principalName'],
      institutionType: map['institutionType'],
    );
  }

  // Helper method to handle both Timestamp and int
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    } else if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'institutionId': institutionId,
      'isVerified': isVerified,
      'createdAt': createdAt.millisecondsSinceEpoch, // Always save as int
    };

    // Add role-specific fields
    if (studentId != null) data['studentId'] = studentId;
    if (course != null) data['course'] = course;
    if (address != null) data['address'] = address;
    if (institutionCode != null) data['institutionCode'] = institutionCode;
    if (principalName != null) data['principalName'] = principalName;
    if (institutionType != null) data['institutionType'] = institutionType;

    return data;
  }
}