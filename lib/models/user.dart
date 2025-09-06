import 'package:finance_management_app/config/constants.dart';

class User {
  final int? id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String? department;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? createdBy;
  final String? phone;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.department,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'] ?? json['full_name'],
      role: json['role'],
      department: json['department'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'] ?? json['created_by'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'role': role,
      'department': department,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'phone': phone,
    };
  }

  // Helper methods
  bool get isSuperAdmin => role == AppConstants.roleSuperAdmin;
  bool get isAdmin => role == AppConstants.roleAdmin;
  bool get isStaff => role == AppConstants.roleStaff;

  bool get canManageUsers => isSuperAdmin || isAdmin;
  bool get canApproveTransactions => isSuperAdmin || isAdmin;
  bool get canViewAllReports => isSuperAdmin || isAdmin;
  bool get canManageInterestRates => isSuperAdmin;

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? role,
    String? department,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdBy,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      phone: phone ?? this.phone,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}