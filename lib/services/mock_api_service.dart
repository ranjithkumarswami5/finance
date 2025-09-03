import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/models/user.dart';
import 'package:finance_management_app/models/transaction.dart';
import 'package:finance_management_app/models/customer.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;

  MockApiService._internal();

  // Mock data storage
  final Map<String, dynamic> _mockUsers = {
    'admin': {
      'id': 1,
      'username': 'admin',
      'email': 'admin@finance.com',
      'fullName': 'Super Administrator',
      'role': AppConstants.roleSuperAdmin,
      'department': 'IT',
      'isActive': true,
      'phone': '+1234567890',
    },
    'manager': {
      'id': 2,
      'username': 'manager',
      'email': 'manager@finance.com',
      'fullName': 'Branch Manager',
      'role': AppConstants.roleAdmin,
      'department': 'Operations',
      'isActive': true,
      'phone': '+1234567891',
    },
    'staff': {
      'id': 3,
      'username': 'staff',
      'email': 'staff@finance.com',
      'fullName': 'Staff Member',
      'role': AppConstants.roleStaff,
      'department': 'Collections',
      'isActive': true,
      'phone': '+1234567892',
    },
  };

  final List<Map<String, dynamic>> _mockTransactions = [
    {
      'id': 1,
      'transactionNumber': 'TXN001',
      'customerId': 1,
      'categoryId': 1,
      'amount': 50000.0,
      'description': 'Business loan disbursement',
      'transactionDate': '2024-01-15',
      'dueDate': '2024-07-15',
      'status': AppConstants.statusCompleted,
      'interestRateId': 1,
      'createdBy': 1,
      'customerName': 'John Doe',
      'categoryName': 'Loan',
      'interestRate': 12.5,
    },
    {
      'id': 2,
      'transactionNumber': 'TXN002',
      'customerId': 2,
      'categoryId': 2,
      'amount': 25000.0,
      'description': 'Personal loan',
      'transactionDate': '2024-01-20',
      'dueDate': '2024-07-20',
      'status': AppConstants.statusPending,
      'interestRateId': 1,
      'createdBy': 2,
      'customerName': 'Jane Smith',
      'categoryName': 'Loan',
      'interestRate': 12.5,
    },
  ];

  final List<Map<String, dynamic>> _mockCustomers = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+1234567890',
      'address': '123 Main St, City, State',
      'customerType': AppConstants.customerIndividual,
      'creditLimit': 100000.0,
      'isActive': true,
      'createdBy': 1,
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'phone': '+1234567891',
      'address': '456 Oak Ave, City, State',
      'customerType': AppConstants.customerIndividual,
      'creditLimit': 50000.0,
      'isActive': true,
      'createdBy': 2,
    },
  ];

  // Mock authentication
  Future<Response> mockLogin(String? username, String? password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Validate input parameters
    if (username == null || username.isEmpty || password == null || password.isEmpty) {
      return Response(
        requestOptions: RequestOptions(path: ApiConstants.loginEndpoint),
        statusCode: 400,
        data: {'message': 'Username and password are required'},
      );
    }

    if (_mockUsers.containsKey(username)) {
      final userData = _mockUsers[username]!;
      final mockPassword = '${username}123'; // Simple mock password logic

      if (password == mockPassword) {
        final token = _generateMockToken(userData);
        final refreshToken = _generateMockRefreshToken(userData);

        return Response(
          requestOptions: RequestOptions(path: ApiConstants.loginEndpoint),
          statusCode: 200,
          data: {
            'token': token,
            'refreshToken': refreshToken,
            'user': userData,
          },
        );
      }
    }

    return Response(
      requestOptions: RequestOptions(path: ApiConstants.loginEndpoint),
      statusCode: 401,
      data: {'message': 'Invalid username or password'},
    );
  }

  Future<Response> mockRefreshToken(String? refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validate refresh token
    if (refreshToken == null || refreshToken.isEmpty) {
      return Response(
        requestOptions: RequestOptions(path: ApiConstants.refreshTokenEndpoint),
        statusCode: 400,
        data: {'message': 'Refresh token is required'},
      );
    }

    // Simple mock refresh token validation
    if (refreshToken.startsWith('refresh_')) {
      final parts = refreshToken.split('_');
      if (parts.length >= 2) {
        final userId = int.tryParse(parts[1]) ?? 1;
        final userData = _mockUsers.values.firstWhere(
          (user) => user['id'] == userId,
          orElse: () => _mockUsers['admin']!,
        );

        final newToken = _generateMockToken(userData);
        final newRefreshToken = _generateMockRefreshToken(userData);

        return Response(
          requestOptions: RequestOptions(path: ApiConstants.refreshTokenEndpoint),
          statusCode: 200,
          data: {
            'token': newToken,
            'refreshToken': newRefreshToken,
          },
        );
      }
    }

    return Response(
      requestOptions: RequestOptions(path: ApiConstants.refreshTokenEndpoint),
      statusCode: 401,
      data: {'message': 'Invalid refresh token'},
    );
  }

  // Mock transactions
  Future<Response> mockGetTransactions({int page = 0, int size = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final startIndex = page * size;
    final endIndex = (startIndex + size).clamp(0, _mockTransactions.length);
    final transactions = _mockTransactions.sublist(startIndex, endIndex);

    return Response(
      requestOptions: RequestOptions(path: ApiConstants.transactionsEndpoint),
      statusCode: 200,
      data: {
        'content': transactions,
        'totalElements': _mockTransactions.length,
        'totalPages': (_mockTransactions.length / size).ceil(),
        'size': size,
        'number': page,
        'first': page == 0,
        'last': endIndex >= _mockTransactions.length,
      },
    );
  }

  Future<Response> mockGetTransaction(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final transaction = _mockTransactions.firstWhere(
        (t) => t['id'] == id,
      );

      return Response(
        requestOptions: RequestOptions(path: '${ApiConstants.transactionsEndpoint}/$id'),
        statusCode: 200,
        data: transaction,
      );
    } catch (e) {
      return Response(
        requestOptions: RequestOptions(path: '${ApiConstants.transactionsEndpoint}/$id'),
        statusCode: 404,
        data: {'message': 'Transaction not found'},
      );
    }
  }

  // Mock customers
  Future<Response> mockGetCustomers({int page = 0, int size = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final startIndex = page * size;
    final endIndex = (startIndex + size).clamp(0, _mockCustomers.length);
    final customers = _mockCustomers.sublist(startIndex, endIndex);

    return Response(
      requestOptions: RequestOptions(path: ApiConstants.customersEndpoint),
      statusCode: 200,
      data: {
        'content': customers,
        'totalElements': _mockCustomers.length,
        'totalPages': (_mockCustomers.length / size).ceil(),
        'size': size,
        'number': page,
        'first': page == 0,
        'last': endIndex >= _mockCustomers.length,
      },
    );
  }

  // Mock dashboard data
  Future<Response> mockGetDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return Response(
      requestOptions: RequestOptions(path: ApiConstants.dashboardEndpoint),
      statusCode: 200,
      data: {
        'totalTransactions': _mockTransactions.length,
        'totalAmount': _mockTransactions.fold<double>(0, (sum, t) => sum + (t['amount'] as double)),
        'pendingCollections': 45000.0,
        'overdueAmount': 25000.0,
        'todayCollections': 15000.0,
        'weeklyCollections': 85000.0,
        'monthlyCollections': 325000.0,
        'recentTransactions': _mockTransactions.take(5),
      },
    );
  }

  // Helper methods
  String _generateMockToken(Map<String, dynamic> userData) {
    final payload = {
      'userId': userData['id'],
      'username': userData['username'],
      'role': userData['role'],
      'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    };

    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final encodedHeader = base64Url.encode(utf8.encode(jsonEncode(header)));
    final encodedPayload = base64Url.encode(utf8.encode(jsonEncode(payload)));

    return '$encodedHeader.$encodedPayload.mock_signature';
  }

  String _generateMockRefreshToken(Map<String, dynamic> userData) {
    return 'refresh_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Check if should use mock API
  static Future<bool> shouldUseMock() async {
    // Try to connect to real backend first, fallback to mock if unavailable
    final backendAvailable = await isBackendAvailable();
    return !backendAvailable; // Use mock when backend is not available
  }

  // Test backend connectivity
  static Future<bool> isBackendAvailable() async {
    try {
      final response = await Dio().get(
        '${ApiConstants.springBootUrl}/actuator/health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}