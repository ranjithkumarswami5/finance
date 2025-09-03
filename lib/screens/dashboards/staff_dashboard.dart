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
          'Staff Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(user),
              const SizedBox(height: 32),

              // Balance Cards at Top
              _buildBalanceCards(),
              const SizedBox(height: 32),

              // Quick Actions (Horizontal Scrollable)
              _buildQuickActions(),
              const SizedBox(height: 32),

              // Performance Overview
              _buildPerformanceOverview(),
              const SizedBox(height: 32),

              // Assigned Collections
              _buildAssignedCollections(),
              const SizedBox(height: 32),

              // Recent Activity
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
              _viewPerformance();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _openSettings();
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionCard(
                'Record Collection',
                Icons.payment,
                AppColors.accentPositive,
                _recordCollection,
              ),
              const SizedBox(width: 16),
              _buildActionCard(
                'Submit Transaction',
                Icons.add_circle,
                AppColors.primaryGradientStart,
                _submitNewTransaction,
              ),
              const SizedBox(width: 16),
              _buildActionCard(
                'View Performance',
                Icons.bar_chart,
                AppColors.secondaryGradientStart,
                _viewPerformance,
              ),
              const SizedBox(width: 16),
              _buildActionCard(
                'Settings',
                Icons.settings,
                AppColors.textSecondary,
                _openSettings,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return AnimatedContainer(
      duration: UIConstants.transitionDuration,
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.account_balance, 'Transactions', false),
          _buildNavItem(Icons.payment, 'Collections', false),
          _buildNavItem(Icons.bar_chart, 'Reports', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        // Handle navigation
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryGradientStart : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryGradientStart : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(
              color: AppColors.cardBorder,
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGradientStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    index % 2 == 0 ? Icons.payment : Icons.add_circle,
                    color: AppColors.primaryGradientStart,
                    size: 20,
                  ),
                ),
                title: Text(
                  _getActivityTitle(index),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                subtitle: Text(
                  _getActivitySubtitle(index),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
                trailing: Text(
                  _getActivityAmount(index),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentPositive,
                    fontFamily: 'Inter',
                  ),
                ),
              );
            },
          ),
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

  String _getActivityTitle(int index) {
    final titles = [
      'Collection Recorded',
      'Transaction Submitted',
      'Payment Received',
      'New Assignment',
      'Task Completed',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(int index) {
    final subtitles = [
      'From John Doe - ₹5,000',
      'Loan application submitted',
      'Monthly installment received',
      'New collection assigned',
      'Daily target achieved',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getActivityAmount(int index) {
    final amounts = ['₹5,000', '₹12,500', '₹8,000', '-', '₹15,000'];
    return amounts[index % amounts.length];
  }

  void _recordCollection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record Collection feature - Coming Soon!')),
    );
  }

  void _submitNewTransaction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submit Transaction feature - Coming Soon!')),
    );
  }

  void _viewPerformance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Performance Report feature - Coming Soon!')),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature - Coming Soon!')),
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