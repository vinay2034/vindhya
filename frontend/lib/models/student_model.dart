import 'package:equatable/equatable.dart';

class StudentModel extends Equatable {
  final String id;
  final String name;
  final String rollNumber;
  final String admissionNumber;
  final String parentId;
  final String classId;
  final DateTime dateOfBirth;
  final String gender;
  final String? bloodGroup;
  final String? address;
  final String? avatar;
  final EmergencyContact? emergencyContact;
  final bool isActive;
  
  const StudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.admissionNumber,
    required this.parentId,
    required this.classId,
    required this.dateOfBirth,
    required this.gender,
    this.bloodGroup,
    this.address,
    this.avatar,
    this.emergencyContact,
    this.isActive = true,
  });
  
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      admissionNumber: json['admissionNumber'] ?? '',
      parentId: json['parentId'] is String 
          ? json['parentId'] 
          : json['parentId']?['_id'] ?? '',
      classId: json['classId'] is String 
          ? json['classId'] 
          : json['classId']?['_id'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'] ?? '',
      bloodGroup: json['bloodGroup'],
      address: json['address'],
      avatar: json['avatar'],
      emergencyContact: json['emergencyContact'] != null
          ? EmergencyContact.fromJson(json['emergencyContact'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
      'admissionNumber': admissionNumber,
      'parentId': parentId,
      'classId': classId,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'address': address,
      'avatar': avatar,
      'emergencyContact': emergencyContact?.toJson(),
      'isActive': isActive,
    };
  }
  
  @override
  List<Object?> get props => [
    id, name, rollNumber, admissionNumber, parentId, classId,
    dateOfBirth, gender, bloodGroup, address, avatar, emergencyContact, isActive
  ];
}

class EmergencyContact extends Equatable {
  final String name;
  final String phone;
  final String relation;
  
  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });
  
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relation: json['relation'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relation': relation,
    };
  }
  
  @override
  List<Object> get props => [name, phone, relation];
}
