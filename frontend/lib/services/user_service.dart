import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';

class UserService extends ChangeNotifier {
  static const String baseUrl = 'https://payment-dashboard-backend-kti6.onrender.com//api';
  
  AuthService? _authService;
  List<User> _users = [];
  bool _isLoading = false;

  UserService({AuthService? authService}) : _authService = authService;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  // Method to inject AuthService dependency
  void updateAuthService(AuthService authService) {
    _authService = authService;
    debugPrint('UserService: AuthService updated. Is authenticated: ${authService.isAuthenticated}');
  }

  // Helper method to get auth headers safely
  Map<String, String>? get _safeAuthHeaders {
    if (_authService == null) {
      debugPrint('UserService: AuthService not available');
      return null;
    }
    if (!_authService!.isAuthenticated) {
      debugPrint('UserService: User not authenticated');
      return null;
    }
    return _authService!.authHeaders;
  }

  Future<List<User>> getUsers() async {
    _setLoading(true);
    try {
      final headers = _safeAuthHeaders;
      if (headers == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        debugPrint('Unauthorized - clearing auth data');
        await _authService?.logout();
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        _users = usersJson.map((json) => User.fromJson(json)).toList();
        notifyListeners();
        return _users;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<User> getUser(String id) async {
    try {
      final headers = _safeAuthHeaders;
      if (headers == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        debugPrint('Unauthorized - clearing auth data');
        await _authService?.logout();
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      debugPrint('Error loading user details: $e');
      rethrow;
    }
  }

  Future<User> createUser({
    required String username,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final headers = _safeAuthHeaders;
      if (headers == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: headers,
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': role.name,
        }),
      );

      if (response.statusCode == 401) {
        debugPrint('Unauthorized - clearing auth data');
        await _authService?.logout();
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode == 201) {
        final user = User.fromJson(json.decode(response.body));
        _users.add(user);
        notifyListeners();
        return user;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create user');
      }
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  Future<User> updateUser(
    String id, {
    String? username,
    String? email,
    String? password,
    UserRole? role,
    bool? isActive,
  }) async {
    try {
      final headers = _safeAuthHeaders;
      if (headers == null) {
        throw Exception('Authentication required');
      }

      final Map<String, dynamic> updateData = {};
      if (username != null) updateData['username'] = username;
      if (email != null) updateData['email'] = email;
      if (password != null) updateData['password'] = password;
      if (role != null) updateData['role'] = role.name;
      if (isActive != null) updateData['isActive'] = isActive;

      final response = await http.patch(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
        body: json.encode(updateData),
      );

      if (response.statusCode == 401) {
        debugPrint('Unauthorized - clearing auth data');
        await _authService?.logout();
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode == 200) {
        final user = User.fromJson(json.decode(response.body));
        final index = _users.indexWhere((u) => u.id == id);
        if (index != -1) {
          _users[index] = user;
          notifyListeners();
        }
        return user;
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final headers = _safeAuthHeaders;
      if (headers == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        debugPrint('Unauthorized - clearing auth data');
        await _authService?.logout();
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode == 200) {
        _users.removeWhere((user) => user.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear data when user logs out
  void clearData() {
    _users.clear();
    _isLoading = false;
    notifyListeners();
    debugPrint('UserService: Data cleared');
  }
}