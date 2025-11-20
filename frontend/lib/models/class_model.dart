import 'package:equatable/equatable.dart';

class ClassModel extends Equatable {
  final String id;
  final String className;
  final String section;
  final String? classTeacher;
  final List<String> subjects;
  final int capacity;
  final String academicYear;
  final String? room;
  final bool isActive;
  
  const ClassModel({
    required this.id,
    required this.className,
    required this.section,
    this.classTeacher,
    this.subjects = const [],
    required this.capacity,
    required this.academicYear,
    this.room,
    this.isActive = true,
  });
  
  String get fullClassName => '$className - $section';
  
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['_id'] ?? json['id'] ?? '',
      className: json['className'] ?? '',
      section: json['section'] ?? '',
      classTeacher: json['classTeacher'] is String
          ? json['classTeacher']
          : json['classTeacher']?['_id'],
      subjects: json['subjects'] is List
          ? List<String>.from((json['subjects'] as List).map((s) {
              return s is String ? s : s['_id'] ?? '';
            }))
          : [],
      capacity: json['capacity'] ?? 40,
      academicYear: json['academicYear'] ?? '',
      room: json['room'],
      isActive: json['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'section': section,
      'classTeacher': classTeacher,
      'subjects': subjects,
      'capacity': capacity,
      'academicYear': academicYear,
      'room': room,
      'isActive': isActive,
    };
  }
  
  @override
  List<Object?> get props => [
    id, className, section, classTeacher, subjects,
    capacity, academicYear, room, isActive
  ];
}
