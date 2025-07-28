import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/payment_service.dart';
import 'services/user_service.dart';
import 'services/websocket_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/add_payment_screen.dart';
import 'screens/users_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),

        ChangeNotifierProxyProvider<AuthService, PaymentService>(
          create: (_) => PaymentService(),
          update: (_, authService, paymentService) {
            paymentService ??= PaymentService();
            paymentService.updateAuthService(authService);
            return paymentService;
          },
        ),

        ChangeNotifierProxyProvider<AuthService, UserService>(
          create: (_) => UserService(),
          update: (_, authService, userService) {
            userService ??= UserService();
            userService.updateAuthService(authService);
            return userService;
          },
        ),

        // ✅ WebSocketService connects/disconnects based on AuthService
        ChangeNotifierProxyProvider<AuthService, WebSocketService>(
          create: (_) => WebSocketService(),
          update: (_, authService, wsService) {
            wsService ??= WebSocketService();

            // Automatically connect/disconnect based on auth status
            if (authService.isAuthenticated) {
              wsService.connect(); // 🔌 Connect on login
            } else {
              wsService.disconnect(); // ❌ Disconnect on logout
            }

            return wsService;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Payment Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/transactions': (context) => const TransactionsScreen(),
          '/add-payment': (context) => const AddPaymentScreen(),
          '/users': (context) => const UsersScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        if (authService.isAuthenticated) {
          return const MainNavigation();
        }

        return const LoginScreen();
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    AddPaymentScreen(),
    UsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_card),
            label: 'Add Payment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
      ),
    );
  }
}
