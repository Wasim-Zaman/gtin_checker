import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';

class SharedPreferencesService {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User data management
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString(_userKey, userJson);
  }

  User? getUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs.remove(_userKey);
  }

  // Login state management
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await Future.wait([
      removeToken(),
      removeUser(),
      _prefs.remove(_isLoggedInKey),
    ]);
  }
}
