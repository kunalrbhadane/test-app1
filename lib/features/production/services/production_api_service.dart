import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../models/production_batch_model.dart';

class ProductionApiService {
  final DioClient _dioClient = DioClient();

  /// Fetch unique batches from `/api/production/unique/batch?company=<companyId>&q=<query>`
  Future<List<ProductionBatchModel>> getUniqueBatches({
    required String companyId,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'company': companyId,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      };

      final response = await _dioClient.dio.get(
        ApiEndpoints.productionUniqueBatch,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is List) {
          return data
              .map((item) =>
                  ProductionBatchModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            return (data['data'] as List)
                .map((item) => ProductionBatchModel.fromJson(
                    item as Map<String, dynamic>))
                .toList();
          } else if (data['result'] is List) {
            return (data['result'] as List)
                .map((item) => ProductionBatchModel.fromJson(
                    item as Map<String, dynamic>))
                .toList();
          }
        }
        return [];
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load batches (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }
}
