import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/payment.dart';
import '../models/payment_list_response.dart';
import '../models/dashboard_stats.dart';
import 'auth_service.dart';

class PaymentService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000/api';

  AuthService? _authService;
  List<Payment> _payments = [];
  DashboardStats? _dashboardStats;
  bool _isLoading = false;

  List<Payment> get payments => _payments;
  DashboardStats? get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;

  // Method to inject AuthService dependency
  void updateAuthService(AuthService authService) {
    _authService = authService;
    debugPrint('PaymentService: AuthService updated. Is authenticated: ${authService.isAuthenticated}, Token exists: ${authService.token != null}');
    
    // Debug the token when auth service is updated
    if (authService.token != null) {
      debugPrint('PaymentService: Token length: ${authService.token!.length}');
      authService.debugToken();
    }
  }

  // Helper method to get auth headers safely with additional validation
  Map<String, String>? get _safeAuthHeaders {
    if (_authService == null) {
      debugPrint('PaymentService: AuthService not available');
      return null;
    }
    if (!_authService!.isAuthenticated) {
      debugPrint('PaymentService: User not authenticated');
      return null;
    }
    if (_authService!.token == null) {
      debugPrint('PaymentService: Token is null');
      return null;
    }
    if (!_authService!.isInitialized) {
      debugPrint('PaymentService: AuthService not initialized');
      return null;
    }
    
    final headers = _authService!.authHeaders;
    debugPrint('PaymentService: Auth headers generated successfully');
    debugPrint('PaymentService: Headers content: $headers');
    return headers;
  }

  // Helper method to handle API responses
  Future<T> _makeAuthenticatedRequest<T>(
    Future<http.Response> Function(Map<String, String> headers) request,
    T Function(Map<String, dynamic> json) parser,
  ) async {
    final headers = _safeAuthHeaders;
    if (headers == null) {
      throw Exception('Authentication required - auth service not ready');
    }

    debugPrint('Making request with headers: $headers');

    try {
      final response = await request(headers);
      debugPrint('API Response: ${response.statusCode} ${response.request?.url}');
      debugPrint('Response headers: ${response.headers}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 401) {
        debugPrint('Unauthorized - clearing auth data');
        
        // Before clearing auth data, let's debug what went wrong
        debugPrint('401 Error Details:');
        debugPrint('Request URL: ${response.request?.url}');
        debugPrint('Request headers sent: ${headers}');
        debugPrint('Response body: ${response.body}');
        
        await _authService?.logout();
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return parser(json.decode(response.body));
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('API request failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Request error: $e');
      rethrow;
    }
  }

  Future<PaymentListResponse> getPayments({
    int page = 1,
    int limit = 10,
    PaymentStatus? status,
    PaymentMethod? method,
    String? startDate,
    String? endDate,
  }) async {
    _setLoading(true);
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status.name;
      if (method != null) queryParams['method'] = method.name;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final uri = Uri.parse('$baseUrl/payments').replace(queryParameters: queryParams);
      debugPrint('Fetching payments: $uri');

      final paymentListResponse = await _makeAuthenticatedRequest<PaymentListResponse>(
        (headers) => http.get(uri, headers: headers),
        (json) => PaymentListResponse.fromJson(json),
      );

      _payments = paymentListResponse.payments;
      notifyListeners();
      return paymentListResponse;
    } catch (e) {
      debugPrint('Error loading payments: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Payment> getPayment(String id) async {
    try {
      debugPrint('Fetching payment details for ID: $id');
      
      return await _makeAuthenticatedRequest<Payment>(
        (headers) => http.get(Uri.parse('$baseUrl/payments/$id'), headers: headers),
        (json) => Payment.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error loading payment details: $e');
      rethrow;
    }
  }

  Future<Payment> createPayment({
    required double amount,
    required PaymentMethod method,
    required PaymentStatus status,
    required String receiver,
    String? description,
    String? failureReason,
  }) async {
    try {
      final requestBody = {
        'amount': amount,
        'method': method.name,
        'status': status.name,
        'receiver': receiver,
        'description': description,
        'failureReason': failureReason,
      };

      debugPrint('Creating payment: $requestBody');

      final payment = await _makeAuthenticatedRequest<Payment>(
        (headers) => http.post(
          Uri.parse('$baseUrl/payments'),
          headers: headers,
          body: json.encode(requestBody),
        ),
        (json) => Payment.fromJson(json),
      );

      // Add new payment to the top of the list
      _payments.insert(0, payment);
      notifyListeners();
      return payment;
    } catch (e) {
      debugPrint('Error creating payment: $e');
      rethrow;
    }
  }

  Future<DashboardStats> getDashboardStats() async {
    _setLoading(true);
    try {
      debugPrint('Fetching dashboard stats...');
      
      // Double-check auth service is ready before making request
      if (_authService == null || !_authService!.isAuthenticated || _authService!.token == null) {
        throw Exception('Authentication not ready for dashboard stats request');
      }

      debugPrint('Auth service ready - making stats request');
      debugPrint('Token available: ${_authService!.token != null}');
      debugPrint('User authenticated: ${_authService!.isAuthenticated}');
      debugPrint('Service initialized: ${_authService!.isInitialized}');

      final stats = await _makeAuthenticatedRequest<DashboardStats>(
        (headers) {
          debugPrint('About to make GET request to: $baseUrl/payments/stats');
          debugPrint('With headers: $headers');
          return http.get(Uri.parse('$baseUrl/payments/stats'), headers: headers);
        },
        (json) => DashboardStats.fromJson(json),
      );

      _dashboardStats = stats;
      notifyListeners();
      debugPrint('Dashboard stats loaded successfully');
      return stats;
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> exportPaymentsCsv() async {
    try {
      debugPrint('Exporting payments to CSV...');

      return await _makeAuthenticatedRequest<String>(
        (headers) => http.get(Uri.parse('$baseUrl/payments/export'), headers: headers),
        (json) => json.toString(), // CSV export returns string, not JSON
      );
    } catch (e) {
      debugPrint('Error exporting payments: $e');
      rethrow;
    }
  }

  // WebSocket update methods
  void updatePaymentFromWebSocket(Payment payment) {
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _payments[index] = payment;
      debugPrint('Updated payment from WebSocket: ${payment.id}');
    } else {
      _payments.insert(0, payment);
      debugPrint('Added new payment from WebSocket: ${payment.id}');
    }
    notifyListeners();
  }

  void updateStatsFromWebSocket(DashboardStats stats) {
    _dashboardStats = stats;
    debugPrint('Updated dashboard stats from WebSocket');
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear data when user logs out
  void clearData() {
    _payments.clear();
    _dashboardStats = null;
    _isLoading = false;
    notifyListeners();
    debugPrint('PaymentService: Data cleared');
  }

  // Method to retry failed requests
  Future<void> retryLastRequest() async {
    if (_authService?.isAuthenticated == true && _authService?.token != null) {
      try {
        await getDashboardStats();
        await getPayments();
      } catch (e) {
        debugPrint('Error retrying requests: $e');
      }
    }
  }
}