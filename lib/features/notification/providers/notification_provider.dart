import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/notification_model.dart';
import '../services/notification_api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationApiService _apiService = NotificationApiService();
  final StorageService _storageService = StorageService();

  List<NotificationItemModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationItemModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications({
    String? userId,
    String? companyId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Resolve userId if not supplied
      String resolvedUserId = userId ?? '';
      if (resolvedUserId.isEmpty) {
        final userData = await _storageService.getUserData();
        if (userData != null) {
          resolvedUserId = userData['_id']?.toString() ??
              userData['id']?.toString() ??
              userData['user']?['_id']?.toString() ??
              '';
        }
      }

      // If user is not logged in or userId is not available, do not call API
      if (resolvedUserId.isEmpty) {
        _isLoading = false;
        _notifications = [];
        notifyListeners();
        return;
      }

      // 2. Resolve companyId if not supplied
      String? resolvedCompanyId = companyId;
      if (resolvedCompanyId == null || resolvedCompanyId.isEmpty) {
        resolvedCompanyId = await _storageService.getCompanyId();
      }

      final items = await _apiService.getNotifications(
        userId: resolvedUserId,
        companyId: resolvedCompanyId,
      );

      _notifications = items;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      String error = e.toString();
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _errorMessage = error;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
