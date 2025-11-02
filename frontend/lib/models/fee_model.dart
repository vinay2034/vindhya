import 'package:equatable/equatable.dart';

class FeeModel extends Equatable {
  final String id;
  final String studentId;
  final String academicYear;
  final String feeType;
  final double amount;
  final DateTime dueDate;
  final String status; // paid, pending, overdue, partial
  final double paidAmount;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? transactionId;
  final String? receiptNumber;
  final double discount;
  final double lateFee;
  final String? remarks;
  
  const FeeModel({
    required this.id,
    required this.studentId,
    required this.academicYear,
    required this.feeType,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidAmount = 0,
    this.paymentDate,
    this.paymentMethod,
    this.transactionId,
    this.receiptNumber,
    this.discount = 0,
    this.lateFee = 0,
    this.remarks,
  });
  
  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      id: json['_id'] ?? json['id'] ?? '',
      studentId: json['studentId'] is String
          ? json['studentId']
          : json['studentId']?['_id'] ?? '',
      academicYear: json['academicYear'] ?? '',
      feeType: json['feeType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'] ?? 'pending',
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      receiptNumber: json['receiptNumber'],
      discount: (json['discount'] ?? 0).toDouble(),
      lateFee: (json['lateFee'] ?? 0).toDouble(),
      remarks: json['remarks'],
    );
  }
  
  double get totalAmount => amount - discount + lateFee;
  double get remainingAmount => totalAmount - paidAmount;
  bool get isOverdue => status == 'overdue' || (status == 'pending' && DateTime.now().isAfter(dueDate));
  
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'academicYear': academicYear,
      'feeType': feeType,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'paidAmount': paidAmount,
      'paymentDate': paymentDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'discount': discount,
      'lateFee': lateFee,
      'remarks': remarks,
    };
  }
  
  @override
  List<Object?> get props => [
    id, studentId, academicYear, feeType, amount, dueDate, status,
    paidAmount, paymentDate, paymentMethod, transactionId, receiptNumber,
    discount, lateFee, remarks
  ];
}
