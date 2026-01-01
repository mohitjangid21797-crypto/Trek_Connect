import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Local Storage Service for storing user/company names and profile image
class LocalStorage {
  static const String _userNameKey = 'userName';
  static const String _companyNameKey = 'company_name';
  static const String _companyPhoneKey = 'business_phone';
  static const String _profileImagePathKey = 'profileImagePath';
  static const String _userMobileKey = 'userMobile';
  static const String _userEmailKey = 'userEmail';
  static const String _userAddressKey = 'userAddress';
  static const String _treksKey = 'treks';
  static const String _bookingsKey = 'bookings';

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

  // Save company phone
  static Future<void> saveCompanyPhone(String companyPhone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyPhoneKey, companyPhone);
  }

  // Get company phone
  static Future<String?> getCompanyPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyPhoneKey);
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

  // Save bookings list
  static Future<void> saveBookings(List<Map<String, dynamic>> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = jsonEncode(bookings);
    await prefs.setString(_bookingsKey, bookingsJson);
  }

  // Get bookings list
  static Future<List<Map<String, dynamic>>> getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getString(_bookingsKey);
    if (bookingsJson != null) {
      final List<dynamic> decoded = jsonDecode(bookingsJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
  }

  // Add a new booking
  static Future<void> addBooking(Map<String, dynamic> booking) async {
    final bookings = await getBookings();
    bookings.add(booking);
    await saveBookings(bookings);
  }
}
