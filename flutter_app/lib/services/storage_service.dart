import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static Box<dynamic>? _secureBox;
  
  // Initialize storage services
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    _secureBox = await Hive.openBox('secure_storage');
  }
  
  // Token Management
  static Future<void> saveAccessToken(String token) async {
    await _secureBox?.put(AppConstants.accessTokenKey, token);
  }
  
  static Future<void> saveRefreshToken(String token) async {
    await _secureBox?.put(AppConstants.refreshTokenKey, token);
  }
  
  static Future<String?> getAccessToken() async {
    final token = _secureBox?.get(AppConstants.accessTokenKey);
    return token as String?;
  }
  
  static Future<String?> getRefreshToken() async {
    final token = _secureBox?.get(AppConstants.refreshTokenKey);
    return token as String?;
  }
  
  static Future<void> clearTokens() async {
    await _secureBox?.delete(AppConstants.accessTokenKey);
    await _secureBox?.delete(AppConstants.refreshTokenKey);
  }
  
  // User Data Management
  static Future<void> saveUserData(User user) async {
    await _secureBox?.put(AppConstants.userDataKey, user.toJson());
  }
  
  static Future<User?> getUserData() async {
    final data = _secureBox?.get(AppConstants.userDataKey);
    if (data is Map) {
      try {
        return User.fromJson(Map<String, dynamic>.from(data));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  static Future<void> clearUserData() async {
    await _secureBox?.delete(AppConstants.userDataKey);
  }

  // Authentication Status
  static Future<void> setLoggedIn(bool loggedIn) async {
    await _prefs?.setBool('is_logged_in', loggedIn);
  }

  static Future<bool> isLoggedIn() async {
    final isLoggedIn = _prefs?.getBool('is_logged_in') ?? false;
    final token = await getAccessToken();
    // User is logged in if both flag is true and token exists
    return isLoggedIn && token != null && token.isNotEmpty;
  }
  
  // App Settings
  static Future<void> saveThemeMode(String themeMode) async {
    await _prefs?.setString(AppConstants.themeKey, themeMode);
  }
  
  static String? getThemeMode() {
    return _prefs?.getString(AppConstants.themeKey);
  }
  
  static Future<void> saveLanguage(String language) async {
    await _prefs?.setString(AppConstants.languageKey, language);
  }
  
  static String? getLanguage() {
    return _prefs?.getString(AppConstants.languageKey);
  }
  
  static Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs?.setBool(AppConstants.onboardingKey, completed);
  }
  
  static bool isOnboardingCompleted() {
    return _prefs?.getBool(AppConstants.onboardingKey) ?? false;
  }
  
  // Generic Methods for any key-value storage
  static Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }
  
  static String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  static Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }
  
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }
  
  static Future<void> saveInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }
  
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }
  
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }
  
  static Future<void> clear() async {
    await _prefs?.clear();
    await _secureBox?.clear();
  }
}
