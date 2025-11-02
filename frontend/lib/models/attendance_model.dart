import 'package:equatable/equatable.dart';

class AttendanceModel extends Equatable {
  final String id;
  final String studentId;
  final String classId;
  final DateTime date;
  final String status; // present, absent, half-day, late
  final String? remarks;
  final String markedBy;
  
  const AttendanceModel({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    this.remarks,
    required this.markedBy,
  });
  
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['_id'] ?? json['id'] ?? '',
      studentId: json['studentId'] is String
          ? json['studentId']
          : json['studentId']?['_id'] ?? '',
      classId: json['classId'] is String
          ? json['classId']
          : json['classId']?['_id'] ?? '',
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'present',
      remarks: json['remarks'],
      markedBy: json['markedBy'] is String
          ? json['markedBy']
          : json['markedBy']?['_id'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'classId': classId,
      'date': date.toIso8601String(),
      'status': status,
      'remarks': remarks,
    };
  }
  
  @override
  List<Object?> get props => [id, studentId, classId, date, status, remarks, markedBy];
}

class AttendanceStats extends Equatable {
  final int present;
  final int absent;
  final int halfDay;
  final int late;
  final int total;
  
  const AttendanceStats({
    this.present = 0,
    this.absent = 0,
    this.halfDay = 0,
    this.late = 0,
    this.total = 0,
  });
  
  double get percentage {
    if (total == 0) return 0;
    return (present / total) * 100;
  }
  
  @override
  List<Object> get props => [present, absent, halfDay, late, total];
}
