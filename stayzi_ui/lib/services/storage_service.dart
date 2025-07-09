import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_model.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _baseUrlKey = 'api_base_url';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // ========== TOKEN MANAGEMENT ==========

  Future<void> saveToken(Token token) async {
    await _initPrefs();
    await _prefs!.setString(_tokenKey, json.encode(token.toJson()));
    await _prefs!.setBool(_isLoggedInKey, true);
  }

  Future<Token?> getToken() async {
    await _initPrefs();
    final tokenString = _prefs!.getString(_tokenKey);
    if (tokenString != null) {
      try {
        final tokenJson = json.decode(tokenString);
        return Token.fromJson(tokenJson);
      } catch (e) {
        print('Error parsing token: $e');
        return null;
      }
    }
    return null;
  }

  Future<String?> getAccessToken() async {
    final token = await getToken();
    return token?.accessToken;
  }

  Future<void> clearToken() async {
    await _initPrefs();
    await _prefs!.remove(_tokenKey);
    await _prefs!.setBool(_isLoggedInKey, false);
  }

  // ========== USER MANAGEMENT ==========

  Future<void> saveUser(User user) async {
    await _initPrefs();
    await _prefs!.setString(_userKey, json.encode(user.toJson()));
  }

  Future<User?> getUser() async {
    await _initPrefs();
    final userString = _prefs!.getString(_userKey);
    if (userString != null) {
      try {
        final userJson = json.decode(userString);
        return User.fromJson(userJson);
      } catch (e) {
        print('Error parsing user: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> clearUser() async {
    await _initPrefs();
    await _prefs!.remove(_userKey);
  }

  // ========== LOGIN STATUS ==========

  Future<bool> isLoggedIn() async {
    await _initPrefs();
    return _prefs!.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await _initPrefs();
    await _prefs!.setBool(_isLoggedInKey, value);
  }

  // ========== API BASE URL ==========

  Future<void> saveBaseUrl(String baseUrl) async {
    await _initPrefs();
    await _prefs!.setString(_baseUrlKey, baseUrl);
  }

  Future<String?> getBaseUrl() async {
    await _initPrefs();
    return _prefs!.getString(_baseUrlKey);
  }

  // ========== CLEAR ALL DATA ==========

  Future<void> clearAllData() async {
    await _initPrefs();
    await _prefs!.clear();
  }

  // ========== LOGOUT ==========

  Future<void> logout() async {
    await clearToken();
    await clearUser();
    await setLoggedIn(false);
  }
}
