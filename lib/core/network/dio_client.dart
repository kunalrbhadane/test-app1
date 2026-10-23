import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

typedef SessionExpiredCallback = void Function();

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  static SessionExpiredCallback? onSessionExpired;

  late final Dio dio;
  final StorageService _storageService = StorageService();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    // Add Auth & Cookie Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            options.headers['Cookie'] = 'userAuth=$token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // Check for set-cookie header to capture userAuth token
          _extractAndSaveCookieToken(response);
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          final path = error.requestOptions.path.toLowerCase();
          final isAuthEndpoint = path.contains('/auth/login') ||
              path.contains('/auth/logout') ||
              path.contains('/auth/register');

          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            await _storageService.clearAll();
            onSessionExpired?.call();
          }
          return handler.next(error);
        },
      ),
    );

    // Add PrettyDioLogger for development logs
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  void _extractAndSaveCookieToken(Response response) {
    try {
      final setCookieHeaders = response.headers['set-cookie'] ??
          response.headers['Set-Cookie'];
      if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
        for (final cookieStr in setCookieHeaders) {
          final parts = cookieStr.split(';');
          for (final part in parts) {
            final trimmed = part.trim();
            final lower = trimmed.toLowerCase();
            if (lower.startsWith('userauth=')) {
              final token = trimmed.substring('userauth='.length);
              if (token.isNotEmpty) {
                _storageService.saveToken(token);
              }
            }
          }
        }
      }

      // Also check if token or userAuth is inside response data
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('token') && data['token'] is String) {
          _storageService.saveToken(data['token']);
        } else if (data.containsKey('userAuth') && data['userAuth'] is String) {
          _storageService.saveToken(data['userAuth']);
        }
      }
    } catch (_) {}
  }
}
