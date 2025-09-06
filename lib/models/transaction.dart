import 'package:finance_management_app/config/constants.dart';

class Transaction {
  final int? id;
  final String transactionNumber;
  final int? customerId;
  final int? categoryId;
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final DateTime? dueDate;
  final String status;
  final int? interestRateId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? createdBy;
  final int? approvedBy;
  final DateTime? approvedAt;

  // Related objects (populated from API)
  final String? customerName;
  final String? categoryName;
  final double? interestRate;

  Transaction({
    this.id,
    required this.transactionNumber,
    this.customerId,
    this.categoryId,
    required this.amount,
    this.description,
    required this.transactionDate,
    this.dueDate,
    this.status = AppConstants.statusPending,
    this.interestRateId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.approvedBy,
    this.approvedAt,
    this.customerName,
    this.categoryName,
    this.interestRate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      transactionNumber: json['transactionNumber'] ?? json['transaction_number'],
      customerId: json['customerId'] ?? json['customer_id'],
      categoryId: json['categoryId'] ?? json['category_id'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      transactionDate: DateTime.parse(json['transactionDate'] ?? json['transaction_date']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: json['status'] ?? AppConstants.statusPending,
      interestRateId: json['interestRateId'] ?? json['interest_rate_id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'] ?? json['created_by'],
      approvedBy: json['approvedBy'] ?? json['approved_by'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      customerName: json['customerName'] ?? json['customer_name'],
      categoryName: json['categoryName'] ?? json['category_name'],
      interestRate: (json['interestRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionNumber': transactionNumber,
      'customerId': customerId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'interestRateId': interestRateId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  // Helper methods
  bool get isPending => status == AppConstants.statusPending;
  bool get isCompleted => status == AppConstants.statusCompleted;
  bool get isOverdue => status == AppConstants.statusOverdue;
  bool get isCancelled => status == AppConstants.statusCancelled;

  bool get isOverdueCheck {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && !isCompleted && !isCancelled;
  }

  int get daysOverdue {
    if (dueDate == null || !isOverdueCheck) return 0;
    return DateTime.now().difference(dueDate!).inDays;
  }

  Transaction copyWith({
    int? id,
    String? transactionNumber,
    int? customerId,
    int? categoryId,
    double? amount,
    String? description,
    DateTime? transactionDate,
    DateTime? dueDate,
    String? status,
    int? interestRateId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdBy,
    int? approvedBy,
    DateTime? approvedAt,
    String? customerName,
    String? categoryName,
    double? interestRate,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      customerId: customerId ?? this.customerId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      interestRateId: interestRateId ?? this.interestRateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      customerName: customerName ?? this.customerName,
      categoryName: categoryName ?? this.categoryName,
      interestRate: interestRate ?? this.interestRate,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, number: $transactionNumber, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}