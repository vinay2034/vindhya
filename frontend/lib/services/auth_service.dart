import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  
  AuthService(this._apiService);
  
  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _apiService.handleError(e);
    }
  }
  
  // Register (Admin only in production)
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String role,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'email': email,
          'password': password,
          'role': role,
          'profile': {
            'name': name,
            'phone': phone,
          },
        },
      );
      
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _apiService.handleError(e);
    }
  }
  
  // Get current user profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.profile);
      return UserModel.fromJson(response.data['data']['user']);
    } catch (e) {
      throw _apiService.handleError(e);
    }
  }
  
  // Update profile
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    String? avatar,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConfig.updateProfile,
        data: {
          'profile': {
            'name': name,
            'phone': phone,
            if (avatar != null) 'avatar': avatar,
            if (address != null) 'address': address,
            if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
            if (gender != null) 'gender': gender,
          },
        },
      );
      
      return UserModel.fromJson(response.data['data']['user']);
    } catch (e) {
      throw _apiService.handleError(e);
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logout);
    } catch (e) {
      throw _apiService.handleError(e);
    }
  }
}
