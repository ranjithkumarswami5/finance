import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/models/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  late FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  StorageService._internal() {
    _secureStorage = const FlutterSecureStorage();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Authentication tokens
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: StorageKeys.token, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageKeys.refreshToken);
  }

  // User data
  Future<void> saveUserData(User user) async {
    await _secureStorage.write(
      key: StorageKeys.userData,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<User?> getUserData() async {
    final userData = await _secureStorage.read(key: StorageKeys.userData);
    if (userData != null) {
      try {
        return User.fromJson(jsonDecode(userData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // App preferences
  Future<void> saveThemeMode(String themeMode) async {
    await _initPrefs();
    await _prefs!.setString(StorageKeys.themeMode, themeMode);
  }

  Future<String?> getThemeMode() async {
    await _initPrefs();
    return _prefs!.getString(StorageKeys.themeMode);
  }

  Future<void> saveLanguage(String language) async {
    await _initPrefs();
    await _prefs!.setString(StorageKeys.language, language);
  }

  Future<String?> getLanguage() async {
    await _initPrefs();
    return _prefs!.getString(StorageKeys.language);
  }

  Future<void> saveLastSync(DateTime lastSync) async {
    await _initPrefs();
    await _prefs!.setString(StorageKeys.lastSync, lastSync.toIso8601String());
  }

  Future<DateTime?> getLastSync() async {
    await _initPrefs();
    final lastSyncStr = _prefs!.getString(StorageKeys.lastSync);
    if (lastSyncStr != null) {
      try {
        return DateTime.parse(lastSyncStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Generic storage methods
  Future<void> saveString(String key, String value) async {
    await _initPrefs();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await _initPrefs();
    return _prefs!.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _initPrefs();
    await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await _initPrefs();
    return _prefs!.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _initPrefs();
    await _prefs!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await _initPrefs();
    return _prefs!.getInt(key);
  }

  Future<void> saveDouble(String key, double value) async {
    await _initPrefs();
    await _prefs!.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    await _initPrefs();
    return _prefs!.getDouble(key);
  }

  // Clear methods
  Future<void> clearToken() async {
    await _secureStorage.delete(key: StorageKeys.token);
  }

  Future<void> clearRefreshToken() async {
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  Future<void> clearUserData() async {
    await _secureStorage.delete(key: StorageKeys.userData);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _initPrefs();
    await _prefs!.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userData = await getUserData();
    return token != null && userData != null;
  }

  // Get all stored keys (for debugging)
  Future<Set<String>> getAllKeys() async {
    await _initPrefs();
    return _prefs!.getKeys();
  }
}