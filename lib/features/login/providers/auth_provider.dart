import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../login_ui/login.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();
  final StorageService _storageService = StorageService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isHandlingExpiry = false;

  AuthProvider() {
    DioClient.onSessionExpired = () {
      handleSessionExpired();
    };
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthStatus() async {
    try {
      final token = await _storageService.getToken();
      final userData = await _storageService.getUserData();

      if (userData != null) {
        _currentUser = UserModel.fromJson(userData, token: token);
        if (_currentUser != null && _currentUser!.id.isNotEmpty) {
          final companyId = _currentUser!.company?.id ??
              await _storageService.getCompanyId() ??
              '';
          NotificationService().initAndSubscribe(
            userId: _currentUser!.id,
            companyId: companyId,
            role: _currentUser!.role.isNotEmpty ? _currentUser!.role : 'accountant',
          );
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String mobile,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _apiService.login(
        mobile: mobile,
        password: password,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();

      if (user.id.isNotEmpty) {
        final companyId =
            user.company?.id ?? await _storageService.getCompanyId() ?? '';
        NotificationService().initAndSubscribe(
          userId: user.id,
          companyId: companyId,
          role: user.role.isNotEmpty ? user.role : 'accountant',
        );
      }

      return true;
    } catch (e) {
      _isLoading = false;
      String error = e.toString();
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  Future<void> handleSessionExpired() async {
    if (_isHandlingExpiry) return;
    _isHandlingExpiry = true;

    try {
      await _storageService.clearAll();
      _currentUser = null;
      _errorMessage = 'Session expired. Please log in again.';
      notifyListeners();

      final navState = AppConfig.navigatorKey.currentState;
      if (navState != null) {
        navState.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error redirecting on session expired: $e');
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isHandlingExpiry = false;
      });
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();

      final navState = AppConfig.navigatorKey.currentState;
      if (navState != null) {
        navState.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

