import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:finance_management_app/providers/auth_provider.dart';
import 'package:finance_management_app/providers/theme_provider.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/utils/routes.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  // Mock data for staff dashboard
  final List<Map<String, dynamic>> _assignedCollections = [
    {
      'id': 1,
      'customerName': 'John Doe',
      'amount': 5000.0,
      'dueDate': DateTime.now().add(const Duration(days: 2)),
      'status': 'PENDING',
      'description': 'Monthly loan payment',
    },
    {
      'id': 2,
      'customerName': 'Jane Smith',
      'amount': 7500.0,
      'dueDate': DateTime.now().add(const Duration(days: 5)),
      'status': 'PENDING',
      'description': 'Business loan installment',
    },
    {
      'id': 3,
      'customerName': 'Bob Johnson',
      'amount': 3200.0,
      'dueDate': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'OVERDUE',
      'description': 'Personal loan payment',
    },
  ];

  final Map<String, dynamic> _performanceData = {
    'todayCollections': 12500.0,
    'monthlyTarget': 150000.0,
    'monthlyCollected': 87500.0,
    'completedTasks': 23,
    'pendingTasks': 7,
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundStart,
        elevation: 0,
        title: Text(
          'Staff',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.textSecondary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => _toggleTheme(themeProvider),
                tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(user),
              const SizedBox(height: 32),

              // Balance Cards at Top
              _buildBalanceCards(),
              const SizedBox(height: 32),

              // Main Action Buttons
              _buildMainActionButtons(),
              const SizedBox(height: 32),


              // Performance Overview
              _buildPerformanceOverview(),
              const SizedBox(height: 32),

              // Assigned Collections
              _buildAssignedCollections(),
              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(authProvider.currentUser?.fullName ?? 'Staff'),
            accountEmail: Text(authProvider.currentUser?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('My Transactions'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.transactions);
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Record Collection'),
            onTap: () {
              Navigator.pop(context);
              _recordCollection();
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('My Performance'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Performance Report feature - Coming Soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature - Coming Soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(user) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, ${user?.fullName ?? 'Staff'}!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s your collection overview',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCards() {
    return Row(
      children: [
        Expanded(
          child: _buildGradientCard(
            title: 'Today\'s Collections',
            amount: '₹${_performanceData['todayCollections'].toStringAsFixed(0)}',
            gradient: LinearGradient(
              colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
            ),
            icon: Icons.today,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGradientCard(
            title: 'Monthly Target',
            amount: '₹${_performanceData['monthlyTarget'].toStringAsFixed(0)}',
            gradient: LinearGradient(
              colors: [AppColors.secondaryGradientStart, AppColors.secondaryGradientEnd],
            ),
            icon: Icons.flag,
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildMainActionButton(
            'Pay Amount',
            Icons.payment,
            AppColors.accentPositive,
            _recordCollection,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMainActionButton(
            'New Loan',
            Icons.add_circle,
            AppColors.primaryGradientStart,
            _submitNewTransaction,
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        ),
        elevation: 8,
        shadowColor: color.withOpacity(0.3),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradientCard({
    required String title,
    required String amount,
    required LinearGradient gradient,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: UIConstants.transitionDuration,
      height: 120,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary.withOpacity(0.8),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    final progress = _performanceData['monthlyCollected'] / _performanceData['monthlyTarget'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Monthly Collected',
                  '₹${_performanceData['monthlyCollected'].toStringAsFixed(0)}',
                  Icons.trending_up,
                  AppColors.accentPositive,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Target Progress',
                  '${(progress * 100).toInt()}%',
                  Icons.flag,
                  AppColors.secondaryGradientStart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundEnd,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.cardBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 0.8 ? AppColors.accentPositive : progress >= 0.6 ? AppColors.primaryGradientStart : AppColors.accentNegative,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '₹${_performanceData['monthlyCollected'].toStringAsFixed(0)} / ₹${_performanceData['monthlyTarget'].toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundEnd,
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAssignedCollections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Assigned Collections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryGradientStart,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _assignedCollections.length,
          itemBuilder: (context, index) {
            final collection = _assignedCollections[index];
            return AnimatedContainer(
              duration: UIConstants.transitionDuration,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(collection['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(collection['status']),
                    color: _getStatusColor(collection['status']),
                    size: 24,
                  ),
                ),
                title: Text(
                  collection['customerName'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      collection['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${_formatDate(collection['dueDate'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: collection['status'] == 'OVERDUE' ? AppColors.accentNegative : AppColors.textMuted,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '₹${collection['amount'].toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentPositive,
                    fontFamily: 'Inter',
                  ),
                ),
                onTap: () => _viewCollectionDetails(collection),
              ),
            );
          },
        ),
      ],
    );
  }


  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.primaryGradientStart;
      case 'OVERDUE':
        return AppColors.accentNegative;
      case 'COMPLETED':
        return AppColors.accentPositive;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'OVERDUE':
        return Icons.warning;
      case 'COMPLETED':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }


  void _recordCollection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildPaymentDialog();
      },
    );
  }

  void _submitNewTransaction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildNewLoanDialog();
      },
    );
  }

  Widget _buildPaymentDialog() {
    final TextEditingController serialController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    Map<String, dynamic>? customerDetails;
    String selectedPaymentMode = 'Cash';

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(
            'Record Payment',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search by Serial Number',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: serialController,
                  decoration: InputDecoration(
                    hintText: 'Enter serial number (e.g., TXN001)',
                    prefixIcon: Icon(Icons.search, color: AppColors.primaryGradientStart),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryGradientStart, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundEnd,
                  ),
                  onChanged: (value) {
                    // Search logic would go here
                    if (value.isNotEmpty && value.toUpperCase() == 'TXN001') {
                      // Mock customer data
                      setState(() {
                        customerDetails = {
                          'serialNumber': value.toUpperCase(),
                          'customerName': 'రాము కుమార్ / Ramu Kumar',
                          'phone': '+91 9876543210',
                          'loanAmount': 50000.0,
                          'paidAmount': 25000.0,
                          'remainingAmount': 25000.0,
                          'dueDate': '2024-01-15',
                          'loanType': 'వ్యక్తిగత ఋణం / Personal Loan',
                        };
                      });
                    } else if (value.isNotEmpty && value.toUpperCase() == 'TXN002') {
                      setState(() {
                        customerDetails = {
                          'serialNumber': value.toUpperCase(),
                          'customerName': 'సీతా దేవి / Sita Devi',
                          'phone': '+91 9876543211',
                          'loanAmount': 75000.0,
                          'paidAmount': 30000.0,
                          'remainingAmount': 45000.0,
                          'dueDate': '2024-01-20',
                          'loanType': 'వ్యాపార ఋణం / Business Loan',
                        };
                      });
                    } else {
                      setState(() {
                        customerDetails = null;
                      });
                    }
                  },
                ),
                if (customerDetails != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundEnd,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.accentPositive, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Customer Found',
                              style: TextStyle(
                                color: AppColors.accentPositive,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Serial Number', customerDetails!['serialNumber']),
                        _buildDetailRow('Customer Name', customerDetails!['customerName']),
                        _buildDetailRow('Phone', customerDetails!['phone']),
                        _buildDetailRow('Loan Type', customerDetails!['loanType']),
                        _buildDetailRow('Total Loan', '₹${customerDetails!['loanAmount'].toStringAsFixed(0)}'),
                        _buildDetailRow('Paid Amount', '₹${customerDetails!['paidAmount'].toStringAsFixed(0)}'),
                        _buildDetailRow('Remaining', '₹${customerDetails!['remainingAmount'].toStringAsFixed(0)}'),
                        _buildDetailRow('Due Date', customerDetails!['dueDate']),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Payment Amount',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount (₹)',
                    prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primaryGradientStart),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryGradientStart, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundEnd,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Payment Mode',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.backgroundEnd,
                  ),
                  child: DropdownButton<String>(
                    value: selectedPaymentMode,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      'Cash',
                      'Online Transfer',
                      'Cheque',
                      'Card Payment',
                      'UPI',
                      'Bank Transfer',
                    ].map((String mode) {
                      return DropdownMenuItem<String>(
                        value: mode,
                        child: Text(
                          mode,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedPaymentMode = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (serialController.text.isNotEmpty && amountController.text.isNotEmpty && customerDetails != null) {
                  // Process payment logic would go here
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Payment of ₹${amountController.text} via $selectedPaymentMode recorded for ${customerDetails!['customerName']}!',
                        style: const TextStyle(fontFamily: 'Inter'),
                      ),
                      backgroundColor: AppColors.accentPositive,
                    ),
                  );
                } else if (customerDetails == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please search for a valid serial number first'),
                      backgroundColor: AppColors.accentNegative,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: AppColors.accentNegative,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGradientStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Record Payment',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewLoanDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController weekController = TextEditingController();
    final TextEditingController loanAmountController = TextEditingController();

    String? aadharFileName;
    String? notepaperFileName;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(
            'New Loan Application',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Information',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),

                // Name Field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter customer full name',
                    prefixIcon: Icon(Icons.person, color: AppColors.primaryGradientStart),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryGradientStart, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundEnd,
                  ),
                ),
                const SizedBox(height: 12),

                // Mobile Number Field
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'Enter 10-digit mobile number',
                    prefixIcon: Icon(Icons.phone, color: AppColors.primaryGradientStart),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryGradientStart, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundEnd,
                  ),
                ),
                const SizedBox(height: 12),

                // Address Field
                TextField(
                  controller: addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter complete address',
                    prefixIcon: Icon(Icons.location_on, color: AppColors.primaryGradientStart),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryGradientStart, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundEnd,
                  ),
                ),
                const SizedBox(height: 12),

                // Date and Week Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Application Date',
                          hintText: 'Select date',
                          prefixIcon: Icon(Icons.calendar_today, color: AppColors.primaryGradientStart),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryGradientStart, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundEnd,
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              dateController.text = pickedDate.toString().split(' ')[0];
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: weekController,
                        decoration: InputDecoration(
                          labelText: 'Week Number',
                          hintText: 'e.g., 1, 2, 3...',
                          prefixIcon: Icon(Icons.calendar_view_week, color: AppColors.primaryGradientStart),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryGradientStart, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundEnd,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Loan Amount Field
                TextField(
                  controller: loanAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Loan Amount',
                    hintText: 'Enter loan amount (₹)',
                    prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primaryGradientStart),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryGradientStart, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundEnd,
                  ),
                ),
                const SizedBox(height: 16),

                // Document Upload Section
                Text(
                  'Document Upload',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),

                // Aadhar Upload
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundEnd,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.file_upload, color: AppColors.primaryGradientStart),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aadhar Card',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                            if (aadharFileName != null)
                              Text(
                                aadharFileName!,
                                style: TextStyle(
                                  color: AppColors.accentPositive,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Mock file upload
                          setState(() {
                            aadharFileName = 'aadhar_card.jpg';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGradientStart,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Upload',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Notepaper Upload
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundEnd,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.file_upload, color: AppColors.primaryGradientStart),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notepaper',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                            if (notepaperFileName != null)
                              Text(
                                notepaperFileName!,
                                style: TextStyle(
                                  color: AppColors.accentPositive,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Mock file upload
                          setState(() {
                            notepaperFileName = 'loan_notepaper.pdf';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGradientStart,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Upload',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    mobileController.text.isNotEmpty &&
                    addressController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    weekController.text.isNotEmpty &&
                    loanAmountController.text.isNotEmpty) {
                  // Process loan application logic would go here
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Loan application for ${nameController.text} submitted successfully!',
                        style: const TextStyle(fontFamily: 'Inter'),
                      ),
                      backgroundColor: AppColors.accentPositive,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: AppColors.accentNegative,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGradientStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit Application',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  void _viewCollectionDetails(Map<String, dynamic> collection) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${collection['customerName']}')),
    );
  }

  void _toggleTheme(ThemeProvider themeProvider) {
    themeProvider.toggleTheme();
    Fluttertoast.showToast(
      msg: themeProvider.isDarkMode ? 'Switched to Light Mode' : 'Switched to Dark Mode',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black87,
      textColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
                context.go(AppRoutes.login);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}