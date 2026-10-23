import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../models/customer_model.dart';

class CustomerApiService {
  final DioClient _dioClient = DioClient();

  Future<List<CustomerModel>> getCustomers() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.customers);

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is List) {
          return data
              .map((item) => CustomerModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => CustomerModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load customers (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  Future<CustomerModel> createCustomer({
    required String companyId,
    required String customerId,
    required String name,
    String? contactPerson,
    String? mobile,
    String? gstNo,
    String? address,
    String? city,
    double creditLimit = 0.0,
    double openingBalance = 0.0,
    double? outstandingBalance,
  }) async {
    try {
      final payload = <String, dynamic>{
        'company': companyId,
        'customerId': customerId,
        'name': name,
        if (contactPerson != null && contactPerson.isNotEmpty)
          'contactPerson': contactPerson,
        if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
        if (gstNo != null && gstNo.isNotEmpty) 'gstNo': gstNo,
        if (address != null && address.isNotEmpty) 'address': address,
        if (city != null && city.isNotEmpty) 'city': city,
        'creditLimit': creditLimit,
        'openingBalance': openingBalance,
        'outstandingBalance': outstandingBalance ?? openingBalance,
      };

      final response = await _dioClient.dio.post(
        ApiEndpoints.customers,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            return CustomerModel.fromJson(data['data'] as Map<String, dynamic>);
          }
          return CustomerModel.fromJson(data);
        }
        throw Exception('Unexpected response format from server');
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to create customer (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }
}
