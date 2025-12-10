import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String _authTokenKey = 'authToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }
}
