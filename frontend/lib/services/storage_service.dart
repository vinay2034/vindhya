import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/constants.dart';
import '../models/user_model.dart';

class StorageService {
  late SharedPreferences _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Auth methods
  Future<void> saveAuth(String token, String refreshToken, UserModel user) async {
    await Future.wait([
      _prefs.setString(StorageKeys.token, token),
      _prefs.setString(StorageKeys.refreshToken, refreshToken),
      _prefs.setString(StorageKeys.userId, user.id),
      _prefs.setString(StorageKeys.userRole, user.role),
      _prefs.setString(StorageKeys.userData, jsonEncode(user.toJson())),
      _prefs.setBool(StorageKeys.isLoggedIn, true),
    ]);
  }
  
  Future<String?> getToken() async {
    return _prefs.getString(StorageKeys.token);
  }
  
  Future<String?> getRefreshToken() async {
    return _prefs.getString(StorageKeys.refreshToken);
  }
  
  Future<String?> getUserId() async {
    return _prefs.getString(StorageKeys.userId);
  }
  
  Future<String?> getUserRole() async {
    return _prefs.getString(StorageKeys.userRole);
  }
  
  Future<UserModel?> getUserData() async {
    final userDataString = _prefs.getString(StorageKeys.userData);
    if (userDataString != null) {
      try {
        final userJson = jsonDecode(userDataString);
        return UserModel.fromJson(userJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<bool> isLoggedIn() async {
    return _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }
  
  Future<void> clearAuth() async {
    await Future.wait([
      _prefs.remove(StorageKeys.token),
      _prefs.remove(StorageKeys.refreshToken),
      _prefs.remove(StorageKeys.userId),
      _prefs.remove(StorageKeys.userRole),
      _prefs.remove(StorageKeys.userData),
      _prefs.setBool(StorageKeys.isLoggedIn, false),
    ]);
  }
  
  // Generic storage methods
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }
  
  int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
  
  Future<void> clear() async {
    await _prefs.clear();
  }
}
