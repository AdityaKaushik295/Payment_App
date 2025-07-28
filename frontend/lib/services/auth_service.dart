import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/login_response.dart';

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'https://payment-dashboard-backend-kti6.onrender.com//api';
  static const String tokenKey = 'auth_token';

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null && _isInitialized;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      await _loadTokenFromStorage();
      if (_token != null) {
        await _validateAndLoadProfile();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      await _clearAuthData();
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(tokenKey);
      debugPrint('Token loaded from storage: ${_token != null ? 'YES' : 'NO'}');
      if (_token != null) {
        debugPrint('Token length: ${_token!.length}');
        debugPrint('Token starts with: ${_token!.substring(0, 20)}...');
      }
    } catch (e) {
      debugPrint('Error loading token from storage: $e');
      _token = null;
    }
  }

  Future<void> _validateAndLoadProfile() async {
    if (_token == null) return;

    try {
      debugPrint('Validating token and loading profile...');
      debugPrint('Using token: ${_token!.substring(0, 50)}...');
      
      final headers = authHeaders;
      debugPrint('Profile request headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
      );

      debugPrint('Profile response status: ${response.statusCode}');
      debugPrint('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUser = User.fromJson(userData);
        debugPrint('User profile loaded successfully: ${_currentUser?.username}');
        notifyListeners();
      } else {
        debugPrint('Profile validation failed. Status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        await _clearAuthData();
      }
    } catch (e) {
      debugPrint('Error validating token/loading profile: $e');
      await _clearAuthData();
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      debugPrint('Attempting login for user: $username');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      if (response.statusCode == 201) {
        final loginResponse = LoginResponse.fromJson(json.decode(response.body));
        _token = loginResponse.access_token;
        _currentUser = loginResponse.user;

        // Debug the received token
        debugPrint('Received token length: ${_token!.length}');
        debugPrint('Token structure check - starts with: ${_token!.substring(0, 20)}');
        debugPrint('Full token: $_token');

        // Save token to persistent storage
        await _saveTokenToStorage(_token!);

        debugPrint('Login successful. Token saved. User: ${_currentUser?.username}');
        notifyListeners();
        return true;
      } else {
        debugPrint('Login failed with status: ${response.statusCode}');
        final errorBody = response.body;
        debugPrint('Error response: $errorBody');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
      debugPrint('Token saved to storage successfully');
    } catch (e) {
      debugPrint('Error saving token to storage: $e');
    }
  }

  Future<void> logout() async {
    debugPrint('Logging out user...');
    await _clearAuthData();
    notifyListeners();
  }

  Future<void> _clearAuthData() async {
    _token = null;
    _currentUser = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      debugPrint('Auth data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Map<String, String> get authHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      final bearerToken = 'Bearer $_token';
      headers['Authorization'] = bearerToken;
      debugPrint('Auth headers created with full Authorization: $bearerToken');
      debugPrint('Header length: ${bearerToken.length}');
    } else {
      debugPrint('Warning: Creating auth headers without token');
    }
    
    return headers;
  }

  // Method to refresh token if needed
  Future<bool> refreshAuthIfNeeded() async {
    if (!isAuthenticated) return false;
    
    try {
      await _validateAndLoadProfile();
      return isAuthenticated;
    } catch (e) {
      debugPrint('Error refreshing auth: $e');
      return false;
    }
  }

  // Method to decode and inspect JWT token
  void debugToken() {
    if (_token == null) {
      debugPrint('No token to debug');
      return;
    }

    try {
      // JWT tokens have 3 parts separated by dots
      final parts = _token!.split('.');
      debugPrint('Token parts count: ${parts.length}');
      
      if (parts.length == 3) {
        // Decode the payload (second part)
        final payload = parts[1];
        // Add padding if needed for base64 decoding
        final normalizedPayload = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalizedPayload));
        debugPrint('Token payload: $decoded');
        
        final payloadJson = json.decode(decoded);
        final exp = payloadJson['exp'];
        final iat = payloadJson['iat'];
        
        if (exp != null) {
          final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          final now = DateTime.now();
          debugPrint('Token expires at: $expDate');
          debugPrint('Current time: $now');
          debugPrint('Token is expired: ${now.isAfter(expDate)}');
          debugPrint('Time until expiry: ${expDate.difference(now).inMinutes} minutes');
        }
        
        if (iat != null) {
          final iatDate = DateTime.fromMillisecondsSinceEpoch(iat * 1000);
          debugPrint('Token issued at: $iatDate');
        }
      }
    } catch (e) {
      debugPrint('Error decoding token: $e');
    }
  }
}