import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationApiService {
  final DioClient _dioClient = DioClient();

  
  Future<List<NotificationItemModel>> getNotifications({
    required String userId,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
      };

      if (companyId != null && companyId.isNotEmpty) {
        queryParams['companyId'] = companyId;
      }

      final response = await _dioClient.dio.get(
        ApiEndpoints.notification,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is List) {
          return data
              .map((item) =>
                  NotificationItemModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((item) =>
                  NotificationItemModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load notifications (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }
}
