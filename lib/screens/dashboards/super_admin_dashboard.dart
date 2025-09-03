import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:finance_management_app/providers/auth_provider.dart';
import 'package:finance_management_app/providers/theme_provider.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/utils/routes.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  // Mock data for super admin dashboard
  final List<Map<String, dynamic>> _adminPerformance = [
    {
      'adminId': 1,
      'adminName': 'Sarah Manager',
      'department': 'Collections',
      'totalCollections': 450000.0,
      'monthlyTarget': 500000.0,
      'staffCount': 5,
      'pendingApprovals': 8,
      'status': 'EXCELLENT',
    },
    {
      'adminId': 2,
      'adminName': 'Mike Supervisor',
      'department': 'Loans',
      'totalCollections': 380000.0,
      'monthlyTarget': 450000.0,
      'staffCount': 4,
      'pendingApprovals': 12,
      'status': 'GOOD',
    },
    {
      'adminId': 3,
      'adminName': 'Lisa Coordinator',
      'department': 'Operations',
      'totalCollections': 320000.0,
      'monthlyTarget': 400000.0,
      'staffCount': 3,
      'pendingApprovals': 6,
      'status': 'NEEDS_ATTENTION',
    },
  ];

  final List<Map<String, dynamic>> _systemAlerts = [
    {
      'id': 1,
      'type': 'CRITICAL',
      'title': 'High Overdue Amount',
      'message': 'Department A has ₹50,000 overdue collections',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      'id': 2,
      'type': 'WARNING',
      'title': 'Staff Performance',
      'message': '3 staff members below monthly target',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 3,
      'type': 'INFO',
      'title': 'New User Registration',
      'message': '5 new staff members registered today',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
    },
  ];

  final Map<String, dynamic> _organizationStats = {
    'totalCollections': 1250000.0,
    'monthlyTarget': 1500000.0,
    'totalAdmins': 3,
    'totalStaff': 12,
    'activeUsers': 15,
    'pendingApprovals': 26,
    'overdueAmount': 75000.0,
    'systemHealth': 98.5,
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
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
            icon: const Icon(Icons.notifications_active),
            onPressed: _viewSystemAlerts,
          ),
          IconButton(
            icon: const Icon(Icons.settings_system_daydream),
            onPressed: _systemSettings,
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

            // System Alerts
            _buildSystemAlerts(),
            const SizedBox(height: 24),

            // Organization Overview
            _buildOrganizationOverview(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Admin Performance
            _buildAdminPerformance(),
            const SizedBox(height: 24),

            // System Health
            _buildSystemHealth(),
            const SizedBox(height: 24),

            // Organization Reports
            _buildOrganizationReports(),
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
            accountName: Text(authProvider.currentUser?.fullName ?? 'Super Admin'),
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
            title: const Text('User Management'),
            onTap: () {
              Navigator.pop(context);
              _manageUsers();
            },
          ),
          ListTile(
            leading: const Icon(Icons.approval),
            title: const Text('All Approvals'),
            onTap: () {
              Navigator.pop(context);
              _viewAllApprovals();
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Organization Reports'),
            onTap: () {
              Navigator.pop(context);
              _viewOrganizationReports();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('System Settings'),
            onTap: () {
              Navigator.pop(context);
              _systemSettings();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Audit Logs'),
            onTap: () {
              Navigator.pop(context);
              _viewAuditLogs();
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
          '$greeting, ${user?.fullName ?? 'Super Admin'}!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Complete organization oversight',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'System Alerts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _viewSystemAlerts,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _systemAlerts.length,
            itemBuilder: (context, index) {
              final alert = _systemAlerts[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  color: _getAlertColor(alert['type']),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getAlertIcon(alert['type']),
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              alert['type'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          alert['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert['message'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationOverview() {
    final progress = _organizationStats['totalCollections'] / _organizationStats['monthlyTarget'];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organization Overview',
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
                    '₹${_organizationStats['totalCollections'].toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Active Users',
                    '${_organizationStats['activeUsers']}',
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
                    '${_organizationStats['pendingApprovals']}',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'System Health',
                    '${_organizationStats['systemHealth']}%',
                    Icons.health_and_safety,
                    Colors.purple,
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
                'Manage Users',
                Icons.people,
                Colors.blue,
                _manageUsers,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'System Settings',
                Icons.settings,
                Colors.purple,
                _systemSettings,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'View Reports',
                Icons.bar_chart,
                Colors.green,
                _viewOrganizationReports,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Audit Logs',
                Icons.security,
                Colors.red,
                _viewAuditLogs,
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

  Widget _buildAdminPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Admin Performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _viewDetailedAdminPerformance,
              child: const Text('View Details'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _adminPerformance.length,
          itemBuilder: (context, index) {
            final admin = _adminPerformance[index];
            final progress = admin['totalCollections'] / admin['monthlyTarget'];

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              admin['adminName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              admin['department'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(admin['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            admin['status'].replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getStatusColor(admin['status']),
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
                                '₹${admin['totalCollections'].toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Staff: ${admin['staffCount']} • Pending: ${admin['pendingApprovals']}',
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
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSystemHealth() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Health',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    'Server Status',
                    'Online',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthMetric(
                    'Database',
                    'Healthy',
                    Icons.storage,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    'API Response',
                    '< 200ms',
                    Icons.speed,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthMetric(
                    'Uptime',
                    '99.9%',
                    Icons.access_time,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organization Reports',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.description, color: Colors.white, size: 20),
                ),
                title: Text(_getOrgReportTitle(index)),
                subtitle: Text(_getOrgReportSubtitle(index)),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadOrgReport(index),
                ),
                onTap: () => _viewOrgReport(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'CRITICAL':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      case 'INFO':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'CRITICAL':
        return Icons.error;
      case 'WARNING':
        return Icons.warning;
      case 'INFO':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EXCELLENT':
        return Colors.green;
      case 'GOOD':
        return Colors.blue;
      case 'NEEDS_ATTENTION':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getOrgReportTitle(int index) {
    final titles = [
      'Organization-wide Collection Report',
      'Department Performance Analysis',
      'Monthly Financial Summary',
      'Staff Productivity Report',
    ];
    return titles[index % titles.length];
  }

  String _getOrgReportSubtitle(int index) {
    final subtitles = [
      'Complete organization overview - March 2024',
      'Cross-department performance comparison',
      'Financial metrics and KPIs summary',
      'Staff efficiency and target achievement',
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

  void _viewSystemAlerts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System Alerts feature - Coming Soon!')),
    );
  }

  void _manageUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User Management feature - Coming Soon!')),
    );
  }

  void _viewAllApprovals() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All Approvals feature - Coming Soon!')),
    );
  }

  void _viewOrganizationReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Organization Reports feature - Coming Soon!')),
    );
  }

  void _systemSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System Settings feature - Coming Soon!')),
    );
  }

  void _viewAuditLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audit Logs feature - Coming Soon!')),
    );
  }

  void _viewDetailedAdminPerformance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detailed Admin Performance feature - Coming Soon!')),
    );
  }

  void _downloadOrgReport(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading organization report...')),
    );
  }

  void _viewOrgReport(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${_getOrgReportTitle(index)}')),
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