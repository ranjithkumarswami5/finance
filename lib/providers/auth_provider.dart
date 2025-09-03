import 'package:flutter/foundation.dart';
import 'package:finance_management_app/models/user.dart';
import 'package:finance_management_app/services/auth_service.dart';
import 'package:finance_management_app/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Helper getters
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStaff => _currentUser?.isStaff ?? false;
  bool get canManageUsers => _currentUser?.canManageUsers ?? false;
  bool get canApproveTransactions => _currentUser?.canApproveTransactions ?? false;
  bool get canViewAllReports => _currentUser?.canViewAllReports ?? false;
  bool get canManageInterestRates => _currentUser?.canManageInterestRates ?? false;

  // Initialize provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _storageService.getUserData();
        _isAuthenticated = true;
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize authentication';
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(username, password);
      _currentUser = user;
      _isAuthenticated = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? department,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        department: department,
        phone: phone,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout failed';
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? department,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        department: department,
      );
      _currentUser = updatedUser;
      await _storageService.saveUserData(updatedUser);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(currentPassword, newPassword);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check permission
  Future<bool> hasPermission(String permission) async {
    return await _authService.hasPermission(permission);
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    try {
      final user = await _storageService.getUserData();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to refresh user data: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get user role
  String? getUserRole() {
    return _currentUser?.role;
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }
}