import 'package:finance_management_app/config/constants.dart';

class Customer {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String customerType;
  final double creditLimit;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? createdBy;

  Customer({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.customerType = AppConstants.customerIndividual,
    this.creditLimit = 0.0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      customerType: json['customerType'] ?? json['customer_type'] ?? AppConstants.customerIndividual,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'] ?? json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'customerType': customerType,
      'creditLimit': creditLimit,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  // Helper methods
  bool get isIndividual => customerType == AppConstants.customerIndividual;
  bool get isBusiness => customerType == AppConstants.customerBusiness;

  String get displayType {
    switch (customerType) {
      case AppConstants.customerIndividual:
        return 'Individual';
      case AppConstants.customerBusiness:
        return 'Business';
      default:
        return customerType;
    }
  }

  Customer copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? customerType,
    double? creditLimit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdBy,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      customerType: customerType ?? this.customerType,
      creditLimit: creditLimit ?? this.creditLimit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, type: $customerType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}