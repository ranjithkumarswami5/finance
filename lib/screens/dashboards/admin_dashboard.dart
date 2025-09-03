import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:finance_management_app/providers/auth_provider.dart';
import 'package:finance_management_app/providers/theme_provider.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/utils/routes.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Mock data for admin dashboard
  final List<Map<String, dynamic>> _staffPerformance = [
    {
      'staffId': 1,
      'staffName': 'Alice Johnson',
      'todayCollections': 25000.0,
      'monthlyTarget': 200000.0,
      'monthlyCollected': 145000.0,
      'pendingApprovals': 3,
      'status': 'ON_TRACK',
    },
    {
      'staffId': 2,
      'staffName': 'Bob Wilson',
      'todayCollections': 18000.0,
      'monthlyTarget': 150000.0,
      'monthlyCollected': 98000.0,
      'pendingApprovals': 5,
      'status': 'BEHIND',
    },
    {
      'staffId': 3,
      'staffName': 'Carol Davis',
      'todayCollections': 32000.0,
      'monthlyTarget': 180000.0,
      'monthlyCollected': 165000.0,
      'pendingApprovals': 2,
      'status': 'EXCELLENT',
    },
  ];

  final List<Map<String, dynamic>> _pendingApprovals = [
    {
      'id': 1,
      'type': 'TRANSACTION',
      'staffName': 'Alice Johnson',
      'customerName': 'John Doe',
      'amount': 50000.0,
      'description': 'New loan application',
      'submittedAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 2,
      'type': 'COLLECTION',
      'staffName': 'Bob Wilson',
      'customerName': 'Jane Smith',
      'amount': 15000.0,
      'description': 'Early loan settlement',
      'submittedAt': DateTime.now().subtract(const Duration(hours: 4)),
    },
  ];

  final Map<String, dynamic> _departmentStats = {
    'totalCollections': 287000.0,
    'monthlyTarget': 530000.0,
    'activeStaff': 8,
    'pendingApprovals': 10,
    'overdueCollections': 15000.0,
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => _toggleTheme(themeProvider),
                tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _viewNotifications,
          ),
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

            // Department Overview
            _buildDepartmentOverview(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Staff Performance
            _buildStaffPerformance(),
            const SizedBox(height: 24),

            // Pending Approvals
            _buildPendingApprovals(),
            const SizedBox(height: 24),

            // Recent Reports
            _buildRecentReports(),
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
            accountName: Text(authProvider.currentUser?.fullName ?? 'Admin'),
            accountEmail: Text(authProvider.currentUser?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.admin_panel_settings, color: Colors.white),
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
            title: const Text('All Transactions'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.transactions);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Staff'),
            onTap: () {
              Navigator.pop(context);
              _manageStaff();
            },
          ),
          ListTile(
            leading: const Icon(Icons.approval),
            title: const Text('Pending Approvals'),
            onTap: () {
              Navigator.pop(context);
              _viewPendingApprovals();
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Department Reports'),
            onTap: () {
              Navigator.pop(context);
              _viewReports();
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
          '$greeting, ${user?.fullName ?? 'Admin'}!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Department performance overview',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentOverview() {
    final progress = _departmentStats['totalCollections'] / _departmentStats['monthlyTarget'];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Collections',
                    '₹${_departmentStats['totalCollections'].toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Active Staff',
                    '${_departmentStats['activeStaff']}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Pending Approvals',
                    '${_departmentStats['pendingApprovals']}',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Overdue Amount',
                    '₹${_departmentStats['overdueCollections'].toStringAsFixed(0)}',
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Monthly Progress',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.8 ? Colors.green : progress >= 0.6 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toInt()}% of monthly target',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Approve Transactions',
                Icons.approval,
                Colors.green,
                _viewPendingApprovals,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'View Reports',
                Icons.bar_chart,
                Colors.blue,
                _viewReports,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Manage Staff',
                Icons.people,
                Colors.purple,
                _manageStaff,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Add Staff',
                Icons.person_add,
                Colors.orange,
                _addNewStaff,
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

  Widget _buildStaffPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Staff Performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _viewDetailedPerformance,
              child: const Text('View Details'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _staffPerformance.length,
          itemBuilder: (context, index) {
            final staff = _staffPerformance[index];
            final progress = staff['monthlyCollected'] / staff['monthlyTarget'];

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          staff['staffName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(staff['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            staff['status'].replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getStatusColor(staff['status']),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today: ₹${staff['todayCollections'].toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pending Approvals: ${staff['pendingApprovals']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircularProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 0.8 ? Colors.green : progress >= 0.6 ? Colors.orange : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${staff['monthlyCollected'].toStringAsFixed(0)} / ₹${staff['monthlyTarget'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPendingApprovals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Approvals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _viewPendingApprovals,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pendingApprovals.length,
          itemBuilder: (context, index) {
            final approval = _pendingApprovals[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: approval['type'] == 'TRANSACTION' ? Colors.blue : Colors.green,
                  child: Icon(
                    approval['type'] == 'TRANSACTION' ? Icons.account_balance : Icons.payment,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text('${approval['customerName']} - ${approval['type']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(approval['description']),
                    Text(
                      'By ${approval['staffName']} • ${_formatDateTime(approval['submittedAt'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '₹${approval['amount'].toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                onTap: () => _reviewApproval(approval),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reports',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.description, color: Colors.white, size: 20),
                ),
                title: Text(_getReportTitle(index)),
                subtitle: Text(_getReportSubtitle(index)),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadReport(index),
                ),
                onTap: () => _viewReport(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EXCELLENT':
        return Colors.green;
      case 'ON_TRACK':
        return Colors.blue;
      case 'BEHIND':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getReportTitle(int index) {
    final titles = [
      'Daily Collection Report',
      'Staff Performance Report',
      'Monthly Department Summary',
    ];
    return titles[index % titles.length];
  }

  String _getReportSubtitle(int index) {
    final subtitles = [
      'Generated today at 6:00 PM',
      'Weekly performance analysis',
      'March 2024 department overview',
    ];
    return subtitles[index % subtitles.length];
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

  void _viewNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature - Coming Soon!')),
    );
  }

  void _manageStaff() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage Staff feature - Coming Soon!')),
    );
  }

  void _viewPendingApprovals() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pending Approvals feature - Coming Soon!')),
    );
  }

  void _viewReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reports feature - Coming Soon!')),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature - Coming Soon!')),
    );
  }

  void _addNewStaff() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Staff feature - Coming Soon!')),
    );
  }

  void _viewDetailedPerformance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detailed Performance feature - Coming Soon!')),
    );
  }

  void _reviewApproval(Map<String, dynamic> approval) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reviewing approval for ${approval['customerName']}')),
    );
  }

  void _downloadReport(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading report...')),
    );
  }

  void _viewReport(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${_getReportTitle(index)}')),
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