import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String role;
  final Profile profile;
  final bool isActive;
  final DateTime? createdAt;
  
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.profile,
    this.isActive = true,
    this.createdAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profile: Profile.fromJson(json['profile'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'profile': profile.toJson(),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
  
  @override
  List<Object?> get props => [id, email, role, profile, isActive, createdAt];
}

class Profile extends Equatable {
  final String name;
  final String phone;
  final String? avatar;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  
  const Profile({
    required this.name,
    required this.phone,
    this.avatar,
    this.address,
    this.dateOfBirth,
    this.gender,
  });
  
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      gender: json['gender'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
    };
  }
  
  @override
  List<Object?> get props => [name, phone, avatar, address, dateOfBirth, gender];
}

class AuthResponse extends Equatable {
  final UserModel user;
  final String token;
  final String refreshToken;
  
  const AuthResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AuthResponse(
      user: UserModel.fromJson(data['user']),
      token: data['token'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
    );
  }
  
  @override
  List<Object> get props => [user, token, refreshToken];
}
