// App Routes Configuration
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';

  // Transaction routes
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/:id';
  static const String addTransaction = '/transactions/add';
  static const String editTransaction = '/transactions/:id/edit';

  // Customer routes
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String addCustomer = '/customers/add';
  static const String editCustomer = '/customers/:id/edit';

  // Collection routes
  static const String collections = '/collections';
  static const String collectionDetail = '/collections/:id';
  static const String addCollection = '/collections/add';

  // User management routes (Admin only)
  static const String users = '/users';
  static const String userDetail = '/users/:id';
  static const String addUser = '/users/add';
  static const String editUser = '/users/:id/edit';

  // Reports routes
  static const String reports = '/reports';
  static const String dailyReport = '/reports/daily';
  static const String weeklyReport = '/reports/weekly';
  static const String monthlyReport = '/reports/monthly';

  // Settings routes
  static const String settings = '/settings';
  static const String interestRates = '/settings/interest-rates';
  static const String transactionCategories = '/settings/categories';

  // Role-based dashboard routes
  static const String staffDashboard = '/staff-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String superAdminDashboard = '/super-admin-dashboard';

  // Helper methods
  static String transactionDetailPath(String id) => '/transactions/$id';
  static String editTransactionPath(String id) => '/transactions/$id/edit';
  static String customerDetailPath(String id) => '/customers/$id';
  static String editCustomerPath(String id) => '/customers/$id/edit';
  static String userDetailPath(String id) => '/users/$id';
  static String editUserPath(String id) => '/users/$id/edit';
  static String collectionDetailPath(String id) => '/collections/$id';
}