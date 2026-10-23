import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../models/size_master_bottle_model.dart';
import '../models/size_master_model.dart';

class SizeMasterApiService {
  final DioClient _dioClient = DioClient();

  /// Fetch available bottle sizes from /api/size-masters?company=<companyId>
  Future<List<SizeMasterModel>> getSizeMasters({
    required String companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'company': companyId,
      };

      final response = await _dioClient.dio.get(
        ApiEndpoints.sizeMasters,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is List) {
          return data
              .map((item) =>
                  SizeMasterModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            return (data['data'] as List)
                .map((item) => SizeMasterModel.fromJson(
                    item as Map<String, dynamic>))
                .toList();
          } else if (data['result'] is List) {
            return (data['result'] as List)
                .map((item) => SizeMasterModel.fromJson(
                    item as Map<String, dynamic>))
                .toList();
          }
        }
        return [];
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load size masters (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  /// Fetch products from /api/size-masters/get/good/bottels?company=<companyId>&sizeKey=<sizeKey>
  Future<List<SizeMasterBottleModel>> getGoodBottles({
    required String companyId,
    String? sizeKey,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'company': companyId,
        if (sizeKey != null && sizeKey.isNotEmpty) 'sizeKey': sizeKey,
      };

      final response = await _dioClient.dio.get(
        ApiEndpoints.sizeMastersGoodBottles,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['result'] is List) {
            return (data['result'] as List)
                .map((item) =>
                    SizeMasterBottleModel.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (data['data'] is List) {
            return (data['data'] as List)
                .map((item) =>
                    SizeMasterBottleModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        } else if (data is List) {
          return data
              .map((item) =>
                  SizeMasterBottleModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load bottles (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }
}
