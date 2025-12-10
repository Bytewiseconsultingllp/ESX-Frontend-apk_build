import 'dart:convert';
import 'package:esx/features/profile/models/address_model.dart';
import 'package:esx/features/profile/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:esx/core/services/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserProviderState {
  initial,
  loading,
  loaded,
  error,
}

class UserProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;
  List<Address>? _address;
  List<Address>? get address => _address;

  UserProviderState _state = UserProviderState.initial;
  UserProviderState get state => _state;

  String? _error;
  String? get error => _error;

  bool get isLoading => _state == UserProviderState.loading;
  bool get hasUser => _user != null;
  bool get hasError => _state == UserProviderState.error;

  void _setState(UserProviderState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    _setState(UserProviderState.error);
  }

  void _setUser(User? userData) {
    _user = userData;
    _error = null;
    _setState(userData != null
        ? UserProviderState.loaded
        : UserProviderState.initial);
  }

  /// Fetches user profile from the API
  Future<bool> fetchUserProfile() async {
    _setState(UserProviderState.loading);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final phoneNumber = prefs.getString('phoneNumber');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.post(
        Uri.parse('$userUrl/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      debugPrint('Profile URL: ${response.request?.url}');
      debugPrint('Profile Headers: ${response.request?.headers}');

      final data = jsonDecode(response.body);
      debugPrint('Profile Response: $data');

      if (response.statusCode == 200 && data['status'] == 'success') {
        final user = User.fromJson(data['user']);
        _setUser(user);

        // Update stored tokens if they're different
        await _updateStoredTokens(user);

        return true;
      } else {
        _setError(data['message'] ?? 'Failed to load profile');
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      _setError('Error fetching profile: ${e.toString()}');
      return false;
    }
  }

  /// Updates user profile data
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (_user == null) return false;

    _setState(UserProviderState.loading);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.put(
        Uri.parse('$userUrl/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body);
      debugPrint('Update Profile Response: $data');

      if (response.statusCode == 200 && data['status'] == 'success') {
        final updatedUser = User.fromJson(data['user']);
        _setUser(updatedUser);
        return true;
      } else {
        _setError(data['message'] ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _setError('Error updating profile: ${e.toString()}');
      return false;
    }
  }

  Future<bool> addUserAddress({
    required Address address,
  }) async {
    _setState(UserProviderState.loading);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final userId = prefs.getString('userId');

      if (accessToken == null || userId == null) {
        _setError("Access token or user ID not found");
        return false;
      }

      final url = Uri.parse('$userUrl/add-address');
      final requestBody = {
        'userId': userId,
        'address': address.toJson(),
      };

      debugPrint('Add Address URL: $url');
      debugPrint('Add Address Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      final responseBody = jsonDecode(response.body);
      debugPrint('Add Address Response: $responseBody');

      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        _address ??= [];
        _address!.add(address);
        await fetchUserProfile();
        return true;
      } else {
        _setError(responseBody['message'] ?? 'Failed to add address');
        return false;
      }
    } catch (e) {
      _setError('Error adding address: ${e.toString()}');
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> getUserAddress() async {
    _setState(UserProviderState.loading);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final userId = prefs.getString('userId');

      if (accessToken == null || userId == null) {
        _setError("Access token or user ID not found");
        return false;
      }

      final url = Uri.parse('$userUrl/$userId/addresses');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('Get Address Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        // Update local user object if needed
        await fetchUserProfile();
        return true;
      } else {
        _setError(data['message'] ?? 'Failed to get address');
        return false;
      }
    } catch (e) {
      _setError('Error getting address: ${e.toString()}');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Refreshes user data (for pull-to-refresh)
  Future<bool> refreshUserProfile() async {
    return await fetchUserProfile();
  }

  /// Updates stored access and refresh tokens
  Future<void> _updateStoredTokens(User user) async {
    final prefs = await SharedPreferences.getInstance();

    if (user.accessToken.isNotEmpty) {
      await prefs.setString('accessToken', user.accessToken);
    }

    if (user.refreshToken.isNotEmpty) {
      await prefs.setString('refreshToken', user.refreshToken);
    }
  }

  /// Clears user data (for logout)
  void clearUser() {
    _user = null;
    _error = null;
    _setState(UserProviderState.initial);
  }

  /// Updates specific user fields locally (for immediate UI updates)
  void updateUserLocally(Map<String, dynamic> updates) {
    if (_user == null) return;

    _user = _user!.copyWith(
      firstName: updates['firstName'] ?? _user!.firstName,
      lastName: updates['lastName'] ?? _user!.lastName,
      email: updates['email'] ?? _user!.email,
      address: updates['address'] ?? _user!.address,
      phoneNumber: updates['phoneNumber'] ?? _user!.phoneNumber,
      isProfileComplete:
          updates['isProfileComplete'] ?? _user!.isProfileComplete,
    );

    notifyListeners();
  }

  /// Checks if user profile is complete
  bool get isProfileComplete {
    if (_user == null) return false;

    return _user!.isProfileComplete &&
        _user!.firstName.isNotEmpty &&
        _user!.lastName.isNotEmpty &&
        _user!.email.isNotEmpty &&
        _user!.address.isNotEmpty;
  }

  /// Gets profile completion percentage
  double get profileCompletionPercentage {
    if (_user == null) return 0.0;

    int completedFields = 0;
    int totalFields = 5;

    if (_user!.firstName.isNotEmpty) completedFields++;
    if (_user!.lastName.isNotEmpty) completedFields++;
    if (_user!.email.isNotEmpty) completedFields++;
    if (_user!.address.isNotEmpty) completedFields++;
    if (_user!.phoneNumber.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }
}
