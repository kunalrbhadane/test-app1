import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final DioClient _dioClient = DioClient();
  String? _lastToken;

  
  static const List<String> defaultEventTypes = [
    'loan.emi.due',
    'maintenance.due',
    'maintenance.proof.submitted',
    'maintenance.approved',
    'maintenance.rejected',
    'task.assigned',
    'task.rescheduled',
    'task.completed',
    'task.due.reminder',
  ];

  Future<Map<String, dynamic>> subscribe({
    required String userId,
    required String companyId,
    required String role,
    required String token,
    String channel = 'app_push',
    List<String>? eventTypes,
  }) async {
    try {
      final payload = {
        'userId': userId,
        'companyId': companyId,
        'role': role,
        'channel': channel,
        'eventTypes': eventTypes ?? defaultEventTypes,
        'target': {
          'token': token,
        },
      };

      final response = await _dioClient.dio.post(
        ApiEndpoints.subscribe,
        data: payload,
      );

      if (response.data is Map<String, dynamic>) {
        debugPrint('Push notification subscription successful: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      debugPrint('Subscribe API Dio error: ${e.response?.data ?? e.message}');
      if (e.response?.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }
      rethrow;
    } catch (e) {
      debugPrint('Subscribe API general error: $e');
      rethrow;
    }
  }

  /// Initializes FCM permissions, gets token and subscribes to backend
  Future<void> initAndSubscribe({
    required String userId,
    required String companyId,
    required String role,
    String channel = 'app_push',
    List<String>? eventTypes,
  }) async {
    try {
      final messaging = FirebaseMessaging.instance;

      // 1. Request notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM Authorization Status: ${settings.authorizationStatus}');

      // 2. Fetch FCM Token
      String? token;
      try {
        token = await messaging.getToken();
      } catch (e) {
        debugPrint('Error getting FCM token: $e');
      }

      if (token != null && token.isNotEmpty) {
        _lastToken = token;
        debugPrint('Fetched FCM Token: $token');
        await subscribe(
          userId: userId,
          companyId: companyId,
          role: role,
          token: token,
          channel: channel,
          eventTypes: eventTypes,
        );
      }

      // 3. Listen to token refresh
      messaging.onTokenRefresh.listen((newToken) {
        if (newToken != _lastToken) {
          _lastToken = newToken;
          debugPrint('FCM Token refreshed: $newToken');
          subscribe(
            userId: userId,
            companyId: companyId,
            role: role,
            token: newToken,
            channel: channel,
            eventTypes: eventTypes,
          );
        }
      });
    } catch (e) {
      debugPrint('NotificationService initAndSubscribe failed: $e');
    }
  }
}
