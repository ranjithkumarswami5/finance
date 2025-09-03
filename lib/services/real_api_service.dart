import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/models/user.dart';
import 'package:finance_management_app/models/transaction.dart';
import 'package:finance_management_app/models/customer.dart';

class RealApiService {
  static final RealApiService _instance = RealApiService._internal();
  factory RealApiService() => _instance;

  late Dio _dio;

  RealApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.springBootUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _RealApiLoggingInterceptor(),
      _RealApiErrorInterceptor(),
    ]);
  }

  // Authentication endpoints
  Future<Response> login(String username, String password) async {
    return await _dio.post(
      '/api/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );
  }

  Future<Response> refreshToken(String refreshToken) async {
    return await _dio.post(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
  }

  Future<Response> logout() async {
    return await _dio.post('/api/auth/logout');
  }

  // User management endpoints
  Future<Response> getUsers({int page = 0, int size = 10}) async {
    return await _dio.get(
      '/api/users',
      queryParameters: {'page': page, 'size': size},
    );
  }

  Future<Response> getUser(int id) async {
    return await _dio.get('/api/users/$id');
  }

  Future<Response> createUser(Map<String, dynamic> userData) async {
    return await _dio.post('/api/users', data: userData);
  }

  Future<Response> updateUser(int id, Map<String, dynamic> userData) async {
    return await _dio.put('/api/users/$id', data: userData);
  }

  Future<Response> deleteUser(int id) async {
    return await _dio.delete('/api/users/$id');
  }

  // Transaction endpoints
  Future<Response> getTransactions({int page = 0, int size = 10, String? status}) async {
    final Map<String, dynamic> queryParams = {'page': page, 'size': size};
    if (status != null) queryParams['status'] = status;

    return await _dio.get(
      '/api/transactions',
      queryParameters: queryParams,
    );
  }

  Future<Response> getTransaction(int id) async {
    return await _dio.get('/api/transactions/$id');
  }

  Future<Response> createTransaction(Map<String, dynamic> transactionData) async {
    return await _dio.post('/api/transactions', data: transactionData);
  }

  Future<Response> updateTransaction(int id, Map<String, dynamic> transactionData) async {
    return await _dio.put('/api/transactions/$id', data: transactionData);
  }

  Future<Response> deleteTransaction(int id) async {
    return await _dio.delete('/api/transactions/$id');
  }

  // Customer endpoints
  Future<Response> getCustomers({int page = 0, int size = 10}) async {
    return await _dio.get(
      '/api/customers',
      queryParameters: {'page': page, 'size': size},
    );
  }

  Future<Response> getCustomer(int id) async {
    return await _dio.get('/api/customers/$id');
  }

  Future<Response> createCustomer(Map<String, dynamic> customerData) async {
    return await _dio.post('/api/customers', data: customerData);
  }

  Future<Response> updateCustomer(int id, Map<String, dynamic> customerData) async {
    return await _dio.put('/api/customers/$id', data: customerData);
  }

  Future<Response> deleteCustomer(int id) async {
    return await _dio.delete('/api/customers/$id');
  }

  // Collection endpoints
  Future<Response> getCollections({int page = 0, int size = 10, String? date}) async {
    final Map<String, dynamic> queryParams = {'page': page, 'size': size};
    if (date != null) queryParams['date'] = date;

    return await _dio.get(
      '/api/collections',
      queryParameters: queryParams,
    );
  }

  Future<Response> createCollection(Map<String, dynamic> collectionData) async {
    return await _dio.post('/api/collections', data: collectionData);
  }

  // Dashboard and reports
  Future<Response> getDashboardData() async {
    return await _dio.get('/api/dashboard');
  }

  Future<Response> getReports(String reportType, {Map<String, dynamic>? params}) async {
    return await _dio.get(
      '/api/reports/$reportType',
      queryParameters: params,
    );
  }

  // Interest rates
  Future<Response> getInterestRates() async {
    return await _dio.get('/api/interest-rates');
  }

  Future<Response> createInterestRate(Map<String, dynamic> rateData) async {
    return await _dio.post('/api/interest-rates', data: rateData);
  }

  Future<Response> updateInterestRate(int id, Map<String, dynamic> rateData) async {
    return await _dio.put('/api/interest-rates/$id', data: rateData);
  }

  // Audit logs
  Future<Response> getAuditLogs({int page = 0, int size = 10}) async {
    return await _dio.get(
      '/api/audit-logs',
      queryParameters: {'page': page, 'size': size},
    );
  }

  // Health check
  Future<Response> healthCheck() async {
    return await _dio.get('/actuator/health');
  }
}

// Logging interceptor for real API
class _RealApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🔗 REAL API Request: ${options.method} ${options.uri}');
    if (options.data != null) {
      try {
        print('📤 Request Data: ${jsonEncode(options.data)}');
      } catch (e) {
        print('📤 Request Data: ${options.data} (could not encode as JSON)');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ REAL API Response: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ REAL API Error: ${err.response?.statusCode} ${err.requestOptions.uri}');
    if (err.response?.data != null) {
      try {
        print('📥 Error Data: ${jsonEncode(err.response?.data)}');
      } catch (e) {
        print('📥 Error Data: ${err.response?.data} (could not encode as JSON)');
      }
    }
    handler.next(err);
  }
}

// Error interceptor for real API
class _RealApiErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'Connection to server failed';

    if (err.response?.data != null) {
      try {
        final responseData = err.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? responseData['error'] ?? errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
      } catch (e) {
        errorMessage = 'Server returned invalid response';
      }
    } else if (err.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timeout - server may be unavailable';
    } else if (err.type == DioExceptionType.connectionError) {
      errorMessage = 'Cannot connect to server - check your internet connection';
    } else if (err.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Server is not responding - please try again later';
    }

    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );

    handler.next(customError);
  }
}