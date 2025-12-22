import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static SharedPreferences? _preferences;

  // Initialize shared preferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Token management (secure storage)
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // User data management (shared preferences)
  static Future<void> saveUser(UserModel user) async {
    if (_preferences == null) await init();
    final userJson = jsonEncode(user.toJson());
    await _preferences?.setString('user_data', userJson);
    await _preferences?.setBool('is_logged_in', true);
  }

  static Future<UserModel?> getUser() async {
    if (_preferences == null) await init();
    final userJson = _preferences?.getString('user_data');
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUser() async {
    if (_preferences == null) await init();
    await _preferences?.remove('user_data');
    await _preferences?.setBool('is_logged_in', false);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await deleteToken();
    await clearUser();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    if (_preferences == null) await init();
    final token = await getToken();
    final isLogged = _preferences?.getBool('is_logged_in') ?? false;
    return token != null && isLogged;
  }
}
