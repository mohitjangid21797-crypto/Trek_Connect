import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Local Storage Service for storing user/company names and profile image
class LocalStorage {
  static const String _userNameKey = 'userName';
  static const String _companyNameKey = 'companyName';
  static const String _profileImagePathKey = 'profileImagePath';
  static const String _userMobileKey = 'userMobile';
  static const String _userEmailKey = 'userEmail';
  static const String _userAddressKey = 'userAddress';
  static const String _treksKey = 'treks';

  // Save user name
  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Save company name
  static Future<void> saveCompanyName(String companyName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyNameKey, companyName);
  }

  // Get company name
  static Future<String?> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyNameKey);
  }

  // Save profile image path
  static Future<void> saveProfileImagePath(String profileImagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImagePathKey, profileImagePath);
  }

  // Get profile image path
  static Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImagePathKey);
  }

  // Save user mobile
  static Future<void> saveUserMobile(String userMobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userMobileKey, userMobile);
  }

  // Get user mobile
  static Future<String?> getUserMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userMobileKey);
  }

  // Save user email
  static Future<void> saveUserEmail(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, userEmail);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Save user address
  static Future<void> saveUserAddress(String userAddress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userAddressKey, userAddress);
  }

  // Get user address
  static Future<String?> getUserAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userAddressKey);
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Save treks list
  static Future<void> saveTreks(List<Map<String, dynamic>> treks) async {
    final prefs = await SharedPreferences.getInstance();
    final treksJson = jsonEncode(treks);
    await prefs.setString(_treksKey, treksJson);
  }

  // Get treks list
  static Future<List<Map<String, dynamic>>> getTreks() async {
    final prefs = await SharedPreferences.getInstance();
    final treksJson = prefs.getString(_treksKey);
    if (treksJson != null) {
      final List<dynamic> decoded = jsonDecode(treksJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
  }
}
