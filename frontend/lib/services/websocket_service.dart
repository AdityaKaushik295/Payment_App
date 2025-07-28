// services/websocket_service.dart
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/payment.dart';
import '../models/dashboard_stats.dart';

class WebSocketService extends ChangeNotifier {
  static const String serverUrl = 'https://payment-dashboard-backend-kti6.onrender.com'; // ⚠️ Use IP if testing on physical device

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Function(Payment)? onPaymentUpdate;
  Function(DashboardStats)? onStatsUpdate;

  void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('🟢 Connected to WebSocket');
      _isConnected = true;
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      print('🔴 Disconnected from WebSocket');
      _isConnected = false;
      notifyListeners();
    });

    _socket!.onConnectError((error) {
      print('⚠️ WebSocket connection error: $error');
      _isConnected = false;
      notifyListeners();
    });

    // ✅ Listen to backend events
    _socket!.on('paymentUpdate', (data) {
      try {
        final payment = Payment.fromJson(Map<String, dynamic>.from(data));
        onPaymentUpdate?.call(payment);
      } catch (e) {
        print('❌ Error parsing payment update: $e');
      }
    });

    _socket!.on('paymentStats', (data) {
      try {
        final stats = DashboardStats.fromJson(Map<String, dynamic>.from(data));
        onStatsUpdate?.call(stats);
      } catch (e) {
        print('❌ Error parsing stats update: $e');
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
