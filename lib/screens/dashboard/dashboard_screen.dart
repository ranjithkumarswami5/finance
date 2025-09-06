import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management_app/providers/auth_provider.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/utils/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(user),
            const SizedBox(height: 24),

            // Quick Stats Cards
            _buildStatsGrid(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(context, authProvider),
            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivity(),
          ],
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
            accountName: Text(authProvider.currentUser?.fullName ?? 'User'),
            accountEmail: Text(authProvider.currentUser?.email ?? ''),
            currentAccountPicture: GestureDetector(
              onTap: _navigateToProfile,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  (authProvider.currentUser?.fullName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            onDetailsPressed: _navigateToProfile,
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          if (authProvider.canManageUsers) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              onTap: () {
                Navigator.pop(context);
                _navigateToUsers();
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Transactions'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.transactions);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Customers'),
            onTap: () {
              Navigator.pop(context);
              _navigateToCustomers();
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Collections'),
            onTap: () {
              Navigator.pop(context);
              _navigateToCollections();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              _viewReports();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _navigateToSettings();
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
          '$greeting, ${user?.fullName ?? 'User'}!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s your finance overview',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Transactions',
          '₹2,45,000',
          Icons.account_balance_wallet,
          Colors.blue,
        ),
        _buildStatCard(
          'Today\'s Collections',
          '₹45,000',
          Icons.payment,
          Colors.green,
        ),
        _buildStatCard(
          'Pending Amount',
          '₹1,20,000',
          Icons.pending,
          Colors.orange,
        ),
        _buildStatCard(
          'Overdue',
          '₹25,000',
          Icons.warning,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Add Transaction',
                Icons.add,
                Colors.blue,
                () => _addTransaction(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Record Collection',
                Icons.payment,
                Colors.green,
                () => _recordCollection(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (authProvider.canManageUsers)
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Add User',
                  Icons.person_add,
                  Colors.purple,
                  () => _addUser(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'View Reports',
                  Icons.bar_chart,
                  Colors.orange,
                  () => _viewReports(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity list
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5, // Mock data
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActivityColor(index),
                  child: Icon(
                    _getActivityIcon(index),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(_getActivityTitle(index)),
                subtitle: Text(_getActivitySubtitle(index)),
                trailing: Text(
                  _getActivityAmount(index),
                  style: TextStyle(
                    color: _getActivityAmountColor(index),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getActivityColor(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];
    return colors[index % colors.length];
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      Icons.payment,
      Icons.account_balance_wallet,
      Icons.warning,
      Icons.check_circle,
      Icons.person,
    ];
    return icons[index % icons.length];
  }

  String _getActivityTitle(int index) {
    final titles = [
      'Payment Received',
      'Transaction Added',
      'Overdue Notice',
      'Transaction Approved',
      'New Customer',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(int index) {
    final subtitles = [
      'From John Doe',
      'Loan disbursement',
      'Payment reminder sent',
      'Transaction #12345',
      'Customer registered',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getActivityAmount(int index) {
    final amounts = ['₹5,000', '₹25,000', '-', '-', '-'];
    return amounts[index % amounts.length];
  }

  Color _getActivityAmountColor(int index) {
    return index == 0 || index == 1 ? Colors.green : Colors.grey;
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

  void _addTransaction() {
    // Navigate to add transaction screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Transaction feature - Coming Soon!')),
    );
  }

  void _recordCollection() {
    // Navigate to record collection screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record Collection feature - Coming Soon!')),
    );
  }

  void _addUser() {
    // Navigate to add user screen (Admin only)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add User feature - Coming Soon!')),
    );
  }

  void _viewReports() {
    // Navigate to reports screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reports feature - Coming Soon!')),
    );
  }

  void _navigateToCustomers() {
    // Navigate to customers screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customers feature - Coming Soon!')),
    );
  }

  void _navigateToCollections() {
    // Navigate to collections screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Collections feature - Coming Soon!')),
    );
  }

  void _navigateToUsers() {
    // Navigate to users screen (Admin only)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User Management feature - Coming Soon!')),
    );
  }

  void _navigateToSettings() {
    // Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature - Coming Soon!')),
    );
  }

  void _navigateToProfile() {
    // Navigate to profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile feature - Coming Soon!')),
    );
  }
}