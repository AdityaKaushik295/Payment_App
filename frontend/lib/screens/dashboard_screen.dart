// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/websocket_service.dart';
import '../models/dashboard_stats.dart';
import '../widgets/stats_card.dart';
import '../widgets/revenue_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hasLoadedData = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    // Use a longer delay to ensure Provider dependencies are fully resolved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _loadDashboardData();
          _setupWebSocketListeners();
        }
      });
    });
  }

  Future<void> _loadDashboardData() async {
    if (_isLoadingData) return; // Prevent multiple simultaneous calls
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    // Wait for auth service to be fully initialized and authenticated
    if (!authService.isAuthenticated || 
        !authService.isInitialized || 
        authService.isLoading ||
        authService.token == null) {
      debugPrint('DashboardScreen: AuthService not ready - isAuth: ${authService.isAuthenticated}, isInit: ${authService.isInitialized}, isLoading: ${authService.isLoading}, hasToken: ${authService.token != null}');
      return;
    }

    // Ensure PaymentService has the current AuthService reference
    paymentService.updateAuthService(authService);
    
    // Additional small delay to ensure the auth service reference is propagated
    await Future.delayed(const Duration(milliseconds: 100));
    
    setState(() {
      _isLoadingData = true;
    });
    
    try {
      debugPrint('DashboardScreen: Loading dashboard data...');
      await paymentService.getDashboardStats();
      setState(() {
        _hasLoadedData = true;
      });
      debugPrint('DashboardScreen: Dashboard data loaded successfully');
    } catch (e) {
      debugPrint('DashboardScreen: Error loading dashboard data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                setState(() {
                  _hasLoadedData = false;
                  _isLoadingData = false;
                });
                _loadDashboardData();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _setupWebSocketListeners() {
    final webSocketService = Provider.of<WebSocketService>(context, listen: false);
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    webSocketService.connect();
    webSocketService.onStatsUpdate = (DashboardStats newStats) {
      paymentService.updateStatsFromWebSocket(newStats);
      if (mounted) {
        setState(() {}); // trigger UI update when new stats come in
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, PaymentService>(
      builder: (context, authService, paymentService, child) {
        // Show loading if auth is not ready
        if (!authService.isInitialized || authService.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              automaticallyImplyLeading: false,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing...'),
                ],
              ),
            ),
          );
        }

        // If not authenticated, this shouldn't happen due to AuthWrapper, but just in case
        if (!authService.isAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              automaticallyImplyLeading: false,
            ),
            body: const Center(
              child: Text('Authentication required'),
            ),
          );
        }

        // Auto-load data when auth is ready and we haven't loaded yet
        if (!_hasLoadedData && !_isLoadingData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadDashboardData();
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            automaticallyImplyLeading: false,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    authService.logout();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(authService.currentUser?.username ?? 'User'),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              // Show loading while data is being fetched
              if ((_isLoadingData || paymentService.isLoading) && paymentService.dashboardStats == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading dashboard data...'),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _hasLoadedData = false;
                    _isLoadingData = false;
                  });
                  await _loadDashboardData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${authService.currentUser?.username ?? 'Admin'}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Here\'s what\'s happening with your payments today.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (paymentService.dashboardStats != null) ...[
                        _buildStatsGrid(paymentService.dashboardStats!),
                        const SizedBox(height: 24),
                        _buildRevenueChart(paymentService.dashboardStats!),
                      ] else
                        _buildEmptyState(),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        StatsCard(
          title: 'Today\'s Transactions',
          value: stats.transactionsToday.toString(),
          icon: Icons.today,
          color: Colors.blue,
        ),
        StatsCard(
          title: 'This Week',
          value: stats.transactionsThisWeek.toString(),
          icon: Icons.date_range,
          color: Colors.green,
        ),
        StatsCard(
          title: 'Today\'s Revenue',
          value: '\$${stats.revenueToday.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.orange,
        ),
        StatsCard(
          title: 'Failed Transactions',
          value: stats.failedTransactions.toString(),
          icon: Icons.error,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildRevenueChart(DashboardStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend (Last 7 Days)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: RevenueChart(revenueData: stats.revenueTrend),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dashboard statistics will appear here once data is loaded.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasLoadedData = false;
                _isLoadingData = false;
              });
              _loadDashboardData();
            },
            child: const Text('Load Data'),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    Provider.of<WebSocketService>(context, listen: false).disconnect();
    super.dispose();
  }
}