import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/providers/auth_provider.dart';
import 'package:finance_management_app/providers/theme_provider.dart';
import 'package:finance_management_app/screens/auth/login_screen.dart';
import 'package:finance_management_app/screens/dashboard/dashboard_screen.dart';
import 'package:finance_management_app/screens/splash_screen.dart';
import 'package:finance_management_app/screens/transactions/transactions_screen.dart';
import 'package:finance_management_app/screens/dashboards/staff_dashboard.dart';
import 'package:finance_management_app/screens/dashboards/admin_dashboard.dart';
import 'package:finance_management_app/screens/dashboards/super_admin_dashboard.dart';
import 'package:finance_management_app/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final authProvider = AuthProvider();
  final themeProvider = ThemeProvider();

  // Initialize app state
  await authProvider.initialize();
  await themeProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const FinanceApp(),
    ),
  );
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeProvider.themeMode,
          routerConfig: _buildRouter(authProvider),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        brightness: Brightness.light,
        primary: AppColors.primaryPurple,
        secondary: AppColors.secondaryTeal,
        tertiary: AppColors.accentPink,
      ),
      scaffoldBackgroundColor: AppColors.lightBgStart,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.lightBgStart,
        foregroundColor: AppColors.textPrimaryLight,
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: UIConstants.elevation,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
        ),
        color: AppColors.cardLight,
        shadowColor: AppColors.primaryPurple.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadius),
          ),
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primaryPurple.withOpacity(0.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.primaryPurple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: AppColors.textSecondaryLight),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
        bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        brightness: Brightness.dark,
        primary: AppColors.primaryPurple,
        secondary: AppColors.secondaryTeal,
        tertiary: AppColors.accentPink,
        surface: AppColors.cardDark,
      ),
      scaffoldBackgroundColor: AppColors.darkBgStart,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkBgStart,
        foregroundColor: AppColors.textPrimaryDark,
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: UIConstants.elevation,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
        ),
        color: AppColors.cardDark,
        shadowColor: AppColors.primaryPurple.withOpacity(0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadius),
          ),
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primaryPurple.withOpacity(0.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.primaryPurple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: AppColors.textSecondaryDark),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
      ),
    );
  }

  GoRouter _buildRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isSplash = state.matchedLocation == AppRoutes.splash;
        final isLogin = state.matchedLocation == AppRoutes.login;
        final isDashboard = state.matchedLocation == AppRoutes.dashboard;

        // Show splash screen first
        if (!authProvider.isInitialized) {
          return AppRoutes.splash;
        }

        // Redirect to login if not authenticated
        if (!isAuthenticated && !isLogin && !isSplash) {
          return AppRoutes.login;
        }

        // Redirect authenticated users to their role-specific dashboard
        if (isAuthenticated && (isLogin || isDashboard)) {
          final userRole = authProvider.currentUser?.role;
          switch (userRole) {
            case AppConstants.roleSuperAdmin:
              return AppRoutes.superAdminDashboard;
            case AppConstants.roleAdmin:
              return AppRoutes.adminDashboard;
            case AppConstants.roleStaff:
              return AppRoutes.staffDashboard;
            default:
              return AppRoutes.dashboard; // Fallback
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.transactions,
          builder: (context, state) => const TransactionsScreen(),
        ),
        GoRoute(
          path: AppRoutes.staffDashboard,
          builder: (context, state) => const StaffDashboard(),
        ),
        GoRoute(
          path: AppRoutes.adminDashboard,
          builder: (context, state) => const AdminDashboard(),
        ),
        GoRoute(
          path: AppRoutes.superAdminDashboard,
          builder: (context, state) => const SuperAdminDashboard(),
        ),
        // Add more routes as needed
      ],
    );
  }
}
