import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static final PreferenceService instance = PreferenceService._init();
  PreferenceService._init();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'logged_in_username';

  // --- Auth Session ---
  Future<void> setLoginSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }
}
