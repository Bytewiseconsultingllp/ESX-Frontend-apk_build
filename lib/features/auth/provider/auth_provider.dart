import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:esx/core/services/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esx/features/profile/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final String _authUrl = '$authUrl';
  final String _userUrl = '$userUrl';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  User? _user;
  User? get user => _user;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void _setUser(User? userData) {
    _user = userData;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final userId = prefs.getString('userId');

      if (accessToken != null && userId != null) {
        _setAuthenticated(true);
        final userDataString = prefs.getString('userData');
        if (userDataString != null) {
          final userMap = jsonDecode(userDataString) as Map<String, dynamic>;
          final user = User.fromJson(userMap);
          _setUser(user);
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Auto-login check failed: $e');
      return false;
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.post(
        Uri.parse('$_authUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 ||
          data['success'] == true ||
          data['status'] == 'success') {
        _setLoading(false);
        return true;
      } else {
        _setError(data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      _setError('Network error: $e');
    }

    _setLoading(false);
    return false;
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    _setLoading(true);
    _setError(null);
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.post(
        Uri.parse('$_userUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      );

      final data = jsonDecode(response.body);
      debugPrint('Verify OTP response: $data');

      if (response.statusCode == 200 && data['status'] == 'success') {
        try {
          prefs.setString('phoneNumber', phoneNumber);
          final user = await _saveUserData(data);

          _setLoading(false);
          return {
            'success': true,
            'isNewUser': user.isNewUser,
            'user': user,
          };
        } catch (e) {
          debugPrint('Error saving user data: $e');
          _setError('Something went wrong while saving user data.');
          _setLoading(false);
          return {'success': false, 'error': 'Failed to save user data.'};
        }
      } else {
        String errorMessage = data['message'] ?? 'Failed to verify OTP';
        if (response.statusCode == 400) {
          errorMessage = 'Invalid OTP. Please try again.';
        } else if (response.statusCode == 401) {
          errorMessage = 'OTP expired. Please request a new one.';
        } else if (response.statusCode == 429) {
          errorMessage = 'Too many attempts. Please try again later.';
        }
        _setError(errorMessage);
        _setLoading(false);
        return {'success': false, 'error': errorMessage};
      }
    } catch (e, stack) {
      debugPrint('Exception in verifyOtp: $e');
      debugPrint('Stack trace: $stack');

      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<User> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // Add detailed logging to debug the issue
    debugPrint('Raw data received: $data');
    debugPrint('Data type: ${data.runtimeType}');

    // Extract user data with proper type checking
    final userMapRaw = data['user'];
    debugPrint('User data raw: $userMapRaw');
    debugPrint('User data type: ${userMapRaw.runtimeType}');

    final userMap = Map<String, dynamic>.from(data['user']);

// Optional: handle alternate ID key (if needed)
    if (userMap.containsKey('*id')) {
      userMap['_id'] = userMap['*id'];
      userMap.remove('*id');
    }

    debugPrint('Processed user map: $userMap');

    // Create user object
    final user = User.fromJson(userMap);

    // Validate required fields
    if (user.accessToken.isEmpty ||
        user.refreshToken.isEmpty ||
        user.id.isEmpty) {
      throw Exception(
          'Missing required user data: accessToken=${user.accessToken.isEmpty}, refreshToken=${user.refreshToken.isEmpty}, id=${user.id.isEmpty}');
    }

    // Save to SharedPreferences
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);
    await prefs.setString('userId', user.id);
    await prefs.setString('userData', jsonEncode(user.toJson()));

    _setAuthenticated(true);
    _setUser(user);

    return user;
  }

  Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String role,
    required String address,
  }) async {
    _setLoading(true);
    _setError(null);

    final url = Uri.parse('$_userUrl/update-profile');
    try {
      final accessToken = await getAccessToken();

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "phoneNumber": phoneNumber,
          "email": email,
          "role": role,
          "address": address,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || data['status'] == 'success') {
        await _saveUserData(data);
        _setLoading(false);
        return true;
      } else {
        _setError(data['error'] ?? data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _setError('Network error: $e');
    }

    _setLoading(false);
    return false;
  }

  Future<bool> logoutUser() async {
    _setLoading(true);
    _setError(null);
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString('userId') == null) {
      _setError("User ID not found in storage.");
      _setLoading(false);
      return true;
    }

    await _clearUserData();
    _setLoading(false);
    return true;
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _setAuthenticated(false);
    _setUser(null);
    _setError(null);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  String? get currentUserId => _user?.id;
  String? get currentUserEmail => _user?.email;
  String get currentUserDisplayName => _user?.displayName ?? 'Guest User';
  bool get isProfileComplete => _user?.isProfileComplete ?? false;
  bool get isNewUser => _user?.isNewUser ?? true;
  String get userRole => _user?.role ?? 'user';

  void updateUser(User updatedUser) {
    _setUser(updatedUser);
  }

  Future<void> refreshUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');

      if (userDataString != null) {
        final userMap = jsonDecode(userDataString) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        _setUser(user);
      }
    } catch (e) {
      debugPrint('Error refreshing user from storage: $e');
    }
  }
}
