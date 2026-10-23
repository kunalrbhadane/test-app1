import 'package:dio/dio.dart';

class ApiErrorHandler {
  /// Converts any exception or [DioException] into a user-friendly, readable message.
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      // 1. If backend returned a structured error response, extract message
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;
        final message = data['message'] ?? data['error'] ?? data['msg'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }

      // 2. Map DioExceptionType to human-friendly messages
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. The server took too long to respond. Please check your internet connection and try again.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to the server. Please check your internet connection and try again.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Session expired. Please log in again.';
          } else if (statusCode == 403) {
            return 'You do not have permission to access this resource.';
          } else if (statusCode == 404) {
            return 'The requested resource was not found.';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Server is temporarily unavailable. Please try again in a few moments.';
          }
          return 'Request failed with status: $statusCode. Please try again.';
        case DioExceptionType.cancel:
          return 'The request was cancelled.';
        case DioExceptionType.badCertificate:
          return 'Security certificate validation failed. Please contact support.';
        case DioExceptionType.unknown:
        default:
          final msg = error.message;
          if (msg != null &&
              !msg.toLowerCase().contains('requestoptions') &&
              !msg.toLowerCase().contains('0:00:')) {
            return msg;
          }
          return 'Network connection error. Please check your internet connection and try again.';
      }
    }

    String errStr = error.toString();
    if (errStr.startsWith('Exception: ')) {
      errStr = errStr.substring('Exception: '.length);
    }
    if (errStr.contains('0:00:') || errStr.contains('RequestOptions') || errStr.contains('connectTimeout')) {
      return 'Connection timed out. The server took too long to respond. Please try again.';
    }
    return errStr.isNotEmpty ? errStr : 'An unexpected error occurred. Please try again.';
  }
}
