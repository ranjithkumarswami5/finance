import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/services/storage_service.dart';
import 'package:finance_management_app/services/mock_api_service.dart';
import 'package:finance_management_app/services/real_api_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final StorageService _storage = StorageService();

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    try {
      _dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Additional options for better null safety
        validateStatus: (status) => status != null && status < 500,
        // Ensure responseType is set to prevent null response data
        responseType: ResponseType.json,
      ));

      _dio.interceptors.addAll([
        _AuthInterceptor(_storage),
        _LoggingInterceptor(),
        _ErrorInterceptor(),
      ]);
    } catch (e) {
      print('Error initializing Dio: $e');
      // Fallback initialization
      _dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
    }
  }

  // Generic GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      // Ensure queryParameters is not null
      final safeQueryParameters = queryParameters ?? {};
      final response = await _dio.get(path, queryParameters: safeQueryParameters);
      return response;
    } catch (e) {
      return await _handleApiError(e, 'GET', path, queryParameters: queryParameters);
    }
  }

  // Generic POST request
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      // Ensure data is not null for POST requests
      final requestData = data ?? {};
      final safeQueryParameters = queryParameters ?? {};
      final response = await _dio.post(path, data: requestData, queryParameters: safeQueryParameters);
      return response;
    } catch (e) {
      return await _handleApiError(e, 'POST', path, data: data, queryParameters: queryParameters);
    }
  }

  // Generic PUT request
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      // Ensure data is not null for PUT requests
      final requestData = data ?? {};
      final safeQueryParameters = queryParameters ?? {};
      final response = await _dio.put(path, data: requestData, queryParameters: safeQueryParameters);
      return response;
    } catch (e) {
      return await _handleApiError(e, 'PUT', path, data: data, queryParameters: queryParameters);
    }
  }

  // Generic DELETE request
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      // Ensure queryParameters is not null
      final safeQueryParameters = queryParameters ?? {};
      final response = await _dio.delete(path, queryParameters: safeQueryParameters);
      return response;
    } catch (e) {
      return await _handleApiError(e, 'DELETE', path, queryParameters: queryParameters);
    }
  }

  // Multipart request for file uploads
  Future<Response> uploadFile(String path, File file, {String fieldName = 'file'}) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
      });
      final response = await _dio.post(path, data: formData);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

// Authentication interceptor
class _AuthInterceptor extends Interceptor {
  final StorageService _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // If there's an error getting the token, continue without it
      print('Error getting auth token: $e');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          try {
            // Attempt to refresh token
            final response = await Dio().post(
              '${ApiConstants.baseUrl}${ApiConstants.refreshTokenEndpoint}',
              data: {'refreshToken': refreshToken},
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

            if (response.statusCode == 200 && response.data != null) {
              final responseData = response.data as Map<String, dynamic>;
              final newToken = responseData['token'] as String?;
              if (newToken != null && newToken.isNotEmpty) {
                await _storage.saveToken(newToken);

                // Retry the original request with new token
                err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final retryResponse = await Dio().fetch(err.requestOptions);
                handler.resolve(retryResponse);
                return;
              }
            }
          } catch (refreshError) {
            // Refresh failed, logout user
            print('Token refresh failed: $refreshError');
            await _storage.clearAll();
          }
        }
      } catch (storageError) {
        print('Storage error during token refresh: $storageError');
      }
    }
    handler.next(err);
  }
}

// Logging interceptor
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('API Request: ${options.method} ${options.uri}');
    if (options.data != null) {
      try {
        print('Request Data: ${jsonEncode(options.data)}');
      } catch (e) {
        print('Request Data: ${options.data} (could not encode as JSON)');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('API Response: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('API Error: ${err.response?.statusCode} ${err.requestOptions.uri}');
    if (err.response?.data != null) {
      try {
        print('Error Data: ${jsonEncode(err.response?.data)}');
      } catch (e) {
        print('Error Data: ${err.response?.data} (could not encode as JSON)');
      }
    }
    handler.next(err);
  }
}

// Error interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An unexpected error occurred';

    try {
      if (err.response?.data != null) {
        final responseData = err.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? responseData['error'] ?? errorMessage;
        } else if (responseData is String && responseData.isNotEmpty) {
          errorMessage = responseData;
        }
      } else if (err.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (err.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server is not responding. Please try again later.';
      } else if (err.type == DioExceptionType.connectionError) {
        errorMessage = 'Unable to connect to server. Please check your connection.';
      } else if (err.message != null && err.message!.isNotEmpty) {
        errorMessage = err.message!;
      }
    } catch (e) {
      // If there's any error in error handling, use a generic message
      errorMessage = 'An unexpected error occurred';
    }

    // Create a custom error response
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );

    handler.next(customError);
  }
}

// Handle API errors and fallback to mock responses
Future<Response> _handleApiError(
  dynamic error,
  String method,
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
}) async {
  // First, try to use real API if backend is available
  if (error is DioException &&
      (error.type == DioExceptionType.connectionError ||
       error.type == DioExceptionType.connectionTimeout)) {

    try {
      // Check if backend is available
      final isBackendAvailable = await MockApiService.isBackendAvailable();

      if (isBackendAvailable) {
        // Try real API calls
        final realApiService = RealApiService();

        // Route to appropriate real API method based on path and method
        if (path == ApiConstants.loginEndpoint && method == 'POST') {
          if (data != null && data is Map<String, dynamic>) {
            final loginData = data as Map<String, dynamic>;
            final username = loginData['username'] as String?;
            final password = loginData['password'] as String?;
            if (username != null && password != null) {
              return await realApiService.login(username, password);
            }
          }
        }

        if (path == ApiConstants.refreshTokenEndpoint && method == 'POST') {
          if (data != null && data is Map<String, dynamic>) {
            final refreshData = data as Map<String, dynamic>;
            final refreshToken = refreshData['refreshToken'] as String?;
            if (refreshToken != null) {
              return await realApiService.refreshToken(refreshToken);
            }
          }
        }

        if (path == ApiConstants.transactionsEndpoint && method == 'GET') {
          final page = queryParameters?['page'] as int? ?? 0;
          final size = queryParameters?['size'] as int? ?? 10;
          return await realApiService.getTransactions(page: page, size: size);
        }

        if (path.startsWith('${ApiConstants.transactionsEndpoint}/') && method == 'GET') {
          final pathParts = path.split('/');
          if (pathParts.length > 1) {
            final id = int.tryParse(pathParts.last);
            if (id != null) {
              return await realApiService.getTransaction(id);
            }
          }
        }

        if (path == ApiConstants.customersEndpoint && method == 'GET') {
          final page = queryParameters?['page'] as int? ?? 0;
          final size = queryParameters?['size'] as int? ?? 10;
          return await realApiService.getCustomers(page: page, size: size);
        }

        if (path == ApiConstants.dashboardEndpoint && method == 'GET') {
          return await realApiService.getDashboardData();
        }
      }
    } catch (realApiError) {
      print('Real API failed, falling back to mock: $realApiError');
    }

    // Fallback to mock API if real API fails or backend unavailable
    final shouldUseMock = await MockApiService.shouldUseMock();
    if (shouldUseMock) {
      final mockService = MockApiService();

      // Route to appropriate mock method based on path and method
      if (path == ApiConstants.loginEndpoint && method == 'POST') {
        if (data != null && data is Map<String, dynamic>) {
          final loginData = data as Map<String, dynamic>;
          final username = loginData['username'] as String?;
          final password = loginData['password'] as String?;
          if (username != null && password != null) {
            return await mockService.mockLogin(username, password);
          }
        }
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Invalid login data',
        );
      }

      if (path == ApiConstants.refreshTokenEndpoint && method == 'POST') {
        if (data != null && data is Map<String, dynamic>) {
          final refreshData = data as Map<String, dynamic>;
          final refreshToken = refreshData['refreshToken'] as String?;
          if (refreshToken != null) {
            return await mockService.mockRefreshToken(refreshToken);
          }
        }
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Invalid refresh token data',
        );
      }

      if (path == ApiConstants.transactionsEndpoint && method == 'GET') {
        final page = queryParameters?['page'] as int? ?? 0;
        final size = queryParameters?['size'] as int? ?? 10;
        return await mockService.mockGetTransactions(page: page, size: size);
      }

      if (path.startsWith('${ApiConstants.transactionsEndpoint}/') && method == 'GET') {
        final pathParts = path.split('/');
        if (pathParts.length > 1) {
          final id = int.tryParse(pathParts.last);
          if (id != null) {
            return await mockService.mockGetTransaction(id);
          }
        }
      }

      if (path == ApiConstants.customersEndpoint && method == 'GET') {
        final page = queryParameters?['page'] as int? ?? 0;
        final size = queryParameters?['size'] as int? ?? 10;
        return await mockService.mockGetCustomers(page: page, size: size);
      }

      if (path == ApiConstants.dashboardEndpoint && method == 'GET') {
        return await mockService.mockGetDashboardData();
      }
    }
  }

  // If not handled by real or mock API, throw the original error
  throw error;
}