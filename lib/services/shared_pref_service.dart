import 'package:concessoapp/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class SharedPrefService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save user login data
  static Future<void> saveUserData(UserModel user) async {
    await _prefs?.setBool(AppConstants.IS_LOGGED_IN, true);
    await _prefs?.setString(AppConstants.USER_ID, user.id);
    await _prefs?.setString(AppConstants.USER_NAME, user.name);
    await _prefs?.setString(AppConstants.USER_EMAIL, user.email);
    await _prefs?.setString(AppConstants.USER_ROLE, user.role);
    await _prefs?.setString(AppConstants.USER_PHONE, user.phone);
    if (user.institutionId != null) {
      await _prefs?.setString(AppConstants.INSTITUTION_ID, user.institutionId!);
    }
    await _prefs?.setBool(AppConstants.IS_VERIFIED, user.isVerified);
    await _prefs?.setInt(AppConstants.LOGIN_TIMESTAMP, DateTime.now().millisecondsSinceEpoch);
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _prefs?.getBool(AppConstants.IS_LOGGED_IN) ?? false;
  }

  // Get user role
  static String getUserRole() {
    return _prefs?.getString(AppConstants.USER_ROLE) ?? '';
  }

  // Get user id
  static String getUserId() {
    return _prefs?.getString(AppConstants.USER_ID) ?? '';
  }

  // Get user name
  static String getUserName() {
    return _prefs?.getString(AppConstants.USER_NAME) ?? '';
  }

  // Get user email
  static String getUserEmail() {
    return _prefs?.getString(AppConstants.USER_EMAIL) ?? '';
  }

  // Get stored user data
  static UserModel? getStoredUser() {
    if (!isLoggedIn()) return null;

    return UserModel(
      id: getUserId(),
      name: getUserName(),
      email: getUserEmail(),
      phone: _prefs?.getString(AppConstants.USER_PHONE) ?? '',
      role: getUserRole(),
      institutionId: _prefs?.getString(AppConstants.INSTITUTION_ID),
      isVerified: _prefs?.getBool(AppConstants.IS_VERIFIED) ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          _prefs?.getInt(AppConstants.LOGIN_TIMESTAMP) ?? DateTime.now().millisecondsSinceEpoch
      ),
    );
  }

  // Clear all user data (logout)
  static Future<void> clearUserData() async {
    await _prefs?.clear();
  }
}
