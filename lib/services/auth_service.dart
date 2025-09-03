import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:finance_management_app/config/constants.dart';
import 'package:finance_management_app/models/user.dart';
import 'package:finance_management_app/services/api_service.dart';
import 'package:finance_management_app/services/storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Login method
  Future<User> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Extract tokens
        final token = data['token'];
        final refreshToken = data['refreshToken'];

        // Extract user data
        final userData = data['user'];
        final user = User.fromJson(userData);

        // Save to storage
        await _storageService.saveToken(token);
        if (refreshToken != null) {
          await _storageService.saveRefreshToken(refreshToken);
        }
        await _storageService.saveUserData(user);

        return user;
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Invalid username or password');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Account is disabled or access denied');
        } else {
          throw Exception('Login failed: ${e.message}');
        }
      } else {
        throw Exception('Login failed: ${e.toString()}');
      }
    }
  }

  // Register new user (for Super Admin and Admin roles)
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? department,
    String? phone,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.registerEndpoint,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
          'department': department,
          'phone': phone,
        },
      );

      if (response.statusCode == 201) {
        final userData = response.data;
        return User.fromJson(userData);
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          throw Exception('Username or email already exists');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Insufficient permissions to create user');
        } else {
          throw Exception('Registration failed: ${e.message}');
        }
      } else {
        throw Exception('Registration failed: ${e.toString()}');
      }
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      // Call logout endpoint if needed
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Ignore logout endpoint errors
    } finally {
      // Clear local storage
      await _storageService.clearAll();
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return await _storageService.getUserData();
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _storageService.isLoggedIn();
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newToken = data['token'];
        final newRefreshToken = data['refreshToken'];

        await _storageService.saveToken(newToken);
        if (newRefreshToken != null) {
          await _storageService.saveRefreshToken(newRefreshToken);
        }

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? department,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.userProfileEndpoint,
        data: {
          if (fullName != null) 'fullName': fullName,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (department != null) 'department': department,
        },
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        final updatedUser = User.fromJson(userData);
        await _storageService.saveUserData(updatedUser);
        return updatedUser;
      } else {
        throw Exception('Profile update failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Profile update failed: ${e.message}');
      } else {
        throw Exception('Profile update failed: ${e.toString()}');
      }
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _apiService.put(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Password change failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Current password is incorrect');
        } else {
          throw Exception('Password change failed: ${e.message}');
        }
      } else {
        throw Exception('Password change failed: ${e.toString()}');
      }
    }
  }

  // Check if user has specific permission
  Future<bool> hasPermission(String permission) async {
    final user = await getCurrentUser();
    if (user == null) return false;

    switch (permission) {
      case 'manage_users':
        return user.canManageUsers;
      case 'approve_transactions':
        return user.canApproveTransactions;
      case 'view_all_reports':
        return user.canViewAllReports;
      case 'manage_interest_rates':
        return user.canManageInterestRates;
      default:
        return false;
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    final user = await getCurrentUser();
    return user?.role;
  }
}