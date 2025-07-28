import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/payment_service.dart';
import '../models/payment.dart';
import '../widgets/payment_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  PaymentStatus? _selectedStatus;
  PaymentMethod? _selectedMethod;
  DateTimeRange? _selectedDateRange;
  
  int _currentPage = 1;
  bool _isLoadingMore = false;
  List<Payment> _allPayments = [];
  int _totalPayments = 0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMorePayments();
    }
  }

  Future<void> _loadPayments({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _allPayments.clear();
    }

    if (!mounted) return;
    
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    
    try {
      final response = await paymentService.getPayments(
        page: _currentPage,
        limit: 10,
        status: _selectedStatus,
        method: _selectedMethod,
        startDate: _selectedDateRange?.start.toIso8601String(),
        endDate: _selectedDateRange?.end.toIso8601String(),
      );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _allPayments = response.payments;
        } else {
          _allPayments.addAll(response.payments);
        }
        _totalPayments = response.total;
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading payments'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMorePayments() async {
    if (_isLoadingMore || _allPayments.length >= _totalPayments) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _loadPayments();

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<PaymentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...PaymentStatus.values.map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...PaymentMethod.values.map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(method.name.replaceAll('_', ' ').toUpperCase()),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    _selectedMethod = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date Range'),
                subtitle: Text(
                  _selectedDateRange == null
                      ? 'All dates'
                      : '${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}',
                ),
                trailing: const Icon(Icons.date_range),
                onTap: () async {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                    initialDateRange: _selectedDateRange,
                  );
                  if (dateRange != null) {
                    setDialogState(() {
                      _selectedDateRange = dateRange;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedMethod = null;
                _selectedDateRange = null;
              });
              Navigator.of(context).pop();
              _loadPayments(refresh: true);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadPayments(refresh: true);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', '\$${payment.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Status', payment.statusDisplayName),
            _buildDetailRow('Method', payment.methodDisplayName),
            _buildDetailRow('Receiver', payment.receiver),
            if (payment.description != null)
              _buildDetailRow('Description', payment.description!),
            if (payment.transactionId != null)
              _buildDetailRow('Transaction ID', payment.transactionId!),
            if (payment.failureReason != null)
              _buildDetailRow('Failure Reason', payment.failureReason!),
            _buildDetailRow(
              'Created',
              DateFormat('MMM dd, yyyy • HH:mm:ss').format(payment.createdAt),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'export') {
                try {
                  final paymentService = Provider.of<PaymentService>(context, listen: false);
                  await paymentService.exportPaymentsCsv();
                  
                  if (!mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export completed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPayments(refresh: true),
        child: Consumer<PaymentService>(
          builder: (context, paymentService, child) {
            if (paymentService.isLoading && _allPayments.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_allPayments.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: _allPayments.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _allPayments.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final payment = _allPayments[index];
                return PaymentCard(
                  payment: payment,
                  onTap: () => _showPaymentDetails(payment),
                );
              },
            );
          },
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
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transactions will appear here once they are created.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}