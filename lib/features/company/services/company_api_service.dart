import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../models/company_model.dart';

class CompanyApiService {
  final DioClient _dioClient = DioClient();

  Future<List<CompanyModel>> getCompanies() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.companies);

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is List) {
          return data
              .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load companies (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }
}
