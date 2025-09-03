import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management_app/models/transaction.dart';
import 'package:finance_management_app/providers/auth_provider.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/utils/routes.dart';
import 'package:finance_management_app/widgets/loading_button.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mock data for now - in real app, this would come from API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      setState(() {
        _transactions = [
          Transaction(
            id: 1,
            transactionNumber: 'TXN001',
            customerId: 1,
            categoryId: 1,
            amount: 50000.0,
            description: 'Business loan disbursement',
            transactionDate: DateTime.now().subtract(const Duration(days: 5)),
            dueDate: DateTime.now().add(const Duration(days: 25)),
            status: AppConstants.statusCompleted,
            interestRateId: 1,
            createdBy: 1,
            customerName: 'John Doe',
            categoryName: 'Loan',
            interestRate: 12.5,
          ),
          Transaction(
            id: 2,
            transactionNumber: 'TXN002',
            customerId: 2,
            categoryId: 2,
            amount: 25000.0,
            description: 'Personal loan',
            transactionDate: DateTime.now().subtract(const Duration(days: 2)),
            dueDate: DateTime.now().add(const Duration(days: 28)),
            status: AppConstants.statusPending,
            interestRateId: 1,
            createdBy: 2,
            customerName: 'Jane Smith',
            categoryName: 'Loan',
            interestRate: 12.5,
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions';
        _isLoading = false;
      });
    }
  }

  List<Transaction> get _filteredTransactions {
    if (_selectedFilter == 'ALL') return _transactions;
    return _transactions.where((t) => t.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFilter == 'ALL',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFilter = 'ALL');
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _selectedFilter == AppConstants.statusPending,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFilter = AppConstants.statusPending);
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _selectedFilter == AppConstants.statusCompleted,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFilter = AppConstants.statusCompleted);
                    }
                  },
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _filteredTransactions.isEmpty
                        ? _buildEmptyView()
                        : _buildTransactionsList(),
          ),
        ],
      ),
      floatingActionButton: authProvider.canApproveTransactions
          ? FloatingActionButton(
              onPressed: _addNewTransaction,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTransactions,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
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
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new transaction',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(transaction.status),
              child: Icon(
                _getStatusIcon(transaction.status),
                color: Colors.white,
              ),
            ),
            title: Text(
              transaction.transactionNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.customerName ?? 'Unknown Customer'),
                Text(
                  '₹${transaction.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                Text(
                  transaction.description ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(transaction.transactionDate),
                  style: const TextStyle(fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.status.toLowerCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(transaction.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => _viewTransactionDetails(transaction),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return Colors.green;
      case AppConstants.statusPending:
        return Colors.orange;
      case AppConstants.statusOverdue:
        return Colors.red;
      case AppConstants.statusCancelled:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return Icons.check_circle;
      case AppConstants.statusPending:
        return Icons.schedule;
      case AppConstants.statusOverdue:
        return Icons.warning;
      case AppConstants.statusCancelled:
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Transactions'),
              leading: Radio<String>(
                value: 'ALL',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Pending'),
              leading: Radio<String>(
                value: AppConstants.statusPending,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Completed'),
              leading: Radio<String>(
                value: AppConstants.statusCompleted,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Overdue'),
              leading: Radio<String>(
                value: AppConstants.statusOverdue,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addNewTransaction() {
    // TODO: Navigate to add transaction screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add transaction feature coming soon!')),
    );
  }

  void _viewTransactionDetails(Transaction transaction) {
    // TODO: Navigate to transaction details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${transaction.transactionNumber}')),
    );
  }
}