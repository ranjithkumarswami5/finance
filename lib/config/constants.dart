// Configuration constants for Finance Management App

import 'package:flutter/material.dart';

class ApiConstants {
  static const String baseUrl = 'http://157.254.189.56:8080/api'; // Spring Boot server
  static const String springBootUrl = 'http://157.254.189.56:8080'; // Spring Boot base URL

  // Database connection (for reference)
  static const String dbUrl = 'jdbc:postgresql://157.254.189.56:5050/finance';
  static const String dbUsername = 'postgres';
  static const String dbPassword = 'Ranjith@123';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';

  // User management endpoints
  static const String usersEndpoint = '/users';
  static const String userProfileEndpoint = '/users/profile';

  // Transaction endpoints
  static const String transactionsEndpoint = '/transactions';
  static const String transactionCategoriesEndpoint = '/transaction-categories';

  // Collection endpoints
  static const String collectionsEndpoint = '/collections';
  static const String dailyCollectionsEndpoint = '/collections/daily';

  // Interest endpoints
  static const String interestRatesEndpoint = '/interest-rates';
  static const String interestCalculationsEndpoint = '/interest-calculations';

  // Customer endpoints
  static const String customersEndpoint = '/customers';

  // Report endpoints
  static const String reportsEndpoint = '/reports';
  static const String dashboardEndpoint = '/reports/dashboard';

  // Audit endpoints
  static const String auditLogsEndpoint = '/audit-logs';
}

class AppConstants {
  static const String appName = 'Finance Manager';
  static const String appVersion = '1.0.0';

  // User roles
  static const String roleSuperAdmin = 'SUPER_ADMIN';
  static const String roleAdmin = 'ADMIN';
  static const String roleStaff = 'STAFF';

  // Transaction statuses
  static const String statusPending = 'PENDING';
  static const String statusCompleted = 'COMPLETED';
  static const String statusOverdue = 'OVERDUE';
  static const String statusCancelled = 'CANCELLED';

  // Payment methods
  static const String paymentCash = 'CASH';
  static const String paymentBankTransfer = 'BANK_TRANSFER';
  static const String paymentCheque = 'CHEQUE';
  static const String paymentUpi = 'UPI';
  static const String paymentCard = 'CARD';

  // Transaction types
  static const String typeIncome = 'INCOME';
  static const String typeExpense = 'EXPENSE';
  static const String typeInvestment = 'INVESTMENT';

  // Customer types
  static const String customerIndividual = 'INDIVIDUAL';
  static const String customerBusiness = 'BUSINESS';
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userData = 'user_data';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String lastSync = 'last_sync';
}

class ValidationConstants {
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const double maxAmount = 999999999.99;
  static const double minAmount = 0.01;
}

class UIConstants {
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double cardBorderRadius = 24.0; // Rounded cards for modern look
  static const double borderRadius = 12.0; // General border radius
  static const double elevation = 4.0; // Subtle shadows
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration transitionDuration = Duration(milliseconds: 200);
}

class AppColors {
  // Background colors - Deep charcoal theme
  static const Color backgroundStart = Color(0xFF121212); // Deep charcoal
  static const Color backgroundEnd = Color(0xFF1E1E1E); // Slightly lighter charcoal

  // Primary gradient - Vibrant warm pink to orange
  static const Color primaryGradientStart = Color(0xFFFF6B6B); // Warm pink
  static const Color primaryGradientEnd = Color(0xFFFF8E53); // Orange

  // Secondary gradient - Blue to purple
  static const Color secondaryGradientStart = Color(0xFF4FACFE); // Blue
  static const Color secondaryGradientEnd = Color(0xFF00F2FE); // Cyan

  // Accent colors
  static const Color accentPositive = Color(0xFF32E875); // Bright green for positive values
  static const Color accentNegative = Color(0xFFFF4D4D); // Red for negative values

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB0B0B0); // Light gray
  static const Color textMuted = Color(0xFF808080); // Medium gray

  // Card colors
  static const Color cardBackground = Color(0xFF2A2A2A); // Dark card background
  static const Color cardBorder = Color(0xFF404040); // Subtle border

  // Legacy colors for backward compatibility
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color secondaryTeal = Color(0xFF14B8A6);
  static const Color accentPink = Color(0xFFF472B6);
  static const Color darkBgStart = Color(0xFF0F172A);
  static const Color darkBgEnd = Color(0xFF1E293B);
  static const Color lightBgStart = Color(0xFFF8FAFC);
  static const Color lightBgEnd = Color(0xFFE2E8F0);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
}

class DateConstants {
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';
}