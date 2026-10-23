import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/storage_service.dart';
import '../../home/models/bill_model.dart';
import '../models/available_product_model.dart';
import '../models/billing_model.dart';

class PaymentCollectionsSummary {
  final double totalDue;
  final double totalCollection;
  final int count;
  final List<BillModel> invoices;

  const PaymentCollectionsSummary({
    required this.totalDue,
    required this.totalCollection,
    required this.count,
    required this.invoices,
  });

  const PaymentCollectionsSummary.empty()
      : totalDue = 0.0,
        totalCollection = 0.0,
        count = 0,
        invoices = const [];
}

class BillingApiService {
  final DioClient _dioClient = DioClient();
  final StorageService _storageService = StorageService();

  /// Fetches bills from the API with optional [companyId], [mode], [customerType], and [period] filters.
  /// If [companyId] is not provided, uses the stored company ID.
  /// Use [customerType] = 'walk_in' to fetch walk-in customer invoices.
  /// Use [period] = 'today' to fetch today's invoices.
  Future<List<BillModel>> fetchBills({
    String? companyId,
    String? mode,
    String? customerType,
    String? period,
    String? paymentStatus,
    String? customerId,
  }) async {
    try {
      // Resolve company ID
      String? resolvedCompanyId = companyId;
      if (resolvedCompanyId == null || resolvedCompanyId.isEmpty) {
        resolvedCompanyId = await _storageService.getCompanyId();
        if (resolvedCompanyId == null || resolvedCompanyId.isEmpty) {
          final userData = await _storageService.getUserData();
          if (userData != null) {
            final comp = userData['company'];
            if (comp is Map<String, dynamic>) {
              resolvedCompanyId =
                  comp['_id']?.toString() ?? comp['id']?.toString();
            } else if (comp is String) {
              resolvedCompanyId = comp;
            }

            if ((resolvedCompanyId == null || resolvedCompanyId.isEmpty) &&
                userData['companies'] is List) {
              final comps = userData['companies'] as List;
              if (comps.isNotEmpty) {
                final first = comps.first;
                if (first is Map<String, dynamic>) {
                  resolvedCompanyId =
                      first['_id']?.toString() ?? first['id']?.toString();
                } else if (first is String) {
                  resolvedCompanyId = first;
                }
              }
            }
          }
        }
      }

      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (resolvedCompanyId != null && resolvedCompanyId.isNotEmpty) {
        queryParams['company'] = resolvedCompanyId;
      }
      if (mode != null && mode.isNotEmpty) {
        queryParams['mode'] = mode;
      }
      if (customerType != null && customerType.isNotEmpty) {
        queryParams['customerType'] = customerType;
      }
      if (period != null && period.isNotEmpty) {
        queryParams['period'] = period;
      }
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams['paymentStatus'] = paymentStatus;
      }
      if (customerId != null && customerId.isNotEmpty) {
        queryParams['customer'] = customerId;
      }

      final response = await _dioClient.dio.get(
        ApiEndpoints.billing,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> rawList;
        if (data is List) {
          rawList = data;
        } else if (data is Map<String, dynamic>) {
          if (data['invoices'] is List) {
            rawList = data['invoices'] as List;
          } else if (data['data'] is List) {
            rawList = data['data'] as List;
          } else {
            return [];
          }
        } else {
          return [];
        }

        return rawList
            .map((item) =>
                BillModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load bills (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  /// Fetches payment collections summary from `GET /api/billing/?company={company}&paymentStatus={paymentStatus}`.
  /// Returns [PaymentCollectionsSummary] containing totals and invoices.
  Future<PaymentCollectionsSummary> fetchPaymentCollectionsSummary({
    String? companyId,
    String paymentStatus = 'partially',
    String? customerId,
  }) async {
    try {
      String? resolvedCompanyId = companyId;
      if (resolvedCompanyId == null || resolvedCompanyId.isEmpty) {
        resolvedCompanyId = await _storageService.getCompanyId();
        if (resolvedCompanyId == null || resolvedCompanyId.isEmpty) {
          final userData = await _storageService.getUserData();
          if (userData != null) {
            final comp = userData['company'];
            if (comp is Map<String, dynamic>) {
              resolvedCompanyId =
                  comp['_id']?.toString() ?? comp['id']?.toString();
            } else if (comp is String) {
              resolvedCompanyId = comp;
            }
          }
        }
      }

      final Map<String, dynamic> queryParams = {};
      if (resolvedCompanyId != null && resolvedCompanyId.isNotEmpty) {
        queryParams['company'] = resolvedCompanyId;
      }
      if (paymentStatus.isNotEmpty) {
        queryParams['paymentStatus'] = paymentStatus;
      }
      if (customerId != null && customerId.isNotEmpty) {
        queryParams['customer'] = customerId;
      }

      final response = await _dioClient.dio.get(
        ApiEndpoints.billing,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          final double totalDue =
              (data['totalDue'] as num?)?.toDouble() ?? 0.0;
          final double totalCollection =
              (data['totalCollection'] as num?)?.toDouble() ?? 0.0;
          final int count = (data['count'] as num?)?.toInt() ?? 0;
          List<BillModel> invoices = [];

          if (data['invoices'] is List) {
            invoices = (data['invoices'] as List)
                .whereType<Map<String, dynamic>>()
                .map((item) => BillModel.fromJson(item))
                .toList();
          } else if (data['data'] is List) {
            invoices = (data['data'] as List)
                .whereType<Map<String, dynamic>>()
                .map((item) => BillModel.fromJson(item))
                .toList();
          }

          return PaymentCollectionsSummary(
            totalDue: totalDue,
            totalCollection: totalCollection,
            count: count,
            invoices: invoices,
          );
        } else if (data is List) {
          final invoices = data
              .whereType<Map<String, dynamic>>()
              .map((item) => BillModel.fromJson(item))
              .toList();
          final totalDue = invoices.fold(0.0, (s, i) => s + i.dueAmount);
          final totalCollection = invoices.fold(0.0, (s, i) => s + i.amountPaid);
          return PaymentCollectionsSummary(
            totalDue: totalDue,
            totalCollection: totalCollection,
            count: invoices.length,
            invoices: invoices,
          );
        }
        return const PaymentCollectionsSummary.empty();
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load payment collections (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const PaymentCollectionsSummary.empty();
      }
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }


  /// Legacy method: fetches raw BillingModel list (no query params).
  Future<List<BillingModel>> getBills() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.billing);

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is List) {
          return data
              .map((item) =>
                  BillingModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((item) =>
                  BillingModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load billing history (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  Future<BillingModel> createBill(BillingModel bill) async {
    try {
      final payload = bill.toJson();
      final response = await _dioClient.dio.post(
        ApiEndpoints.billing,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') &&
              data['data'] is Map<String, dynamic>) {
            return BillingModel.fromJson(
                data['data'] as Map<String, dynamic>);
          }
          return BillingModel.fromJson(data);
        }
        throw Exception('Unexpected response format from server');
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to create bill (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  /// Fetches available products from `/api/billing/available`.
  Future<List<AvailableProductModel>> fetchAvailableProducts({
    String? companyId,
  }) async {
    try {
      String? resolvedCompanyId = companyId;
      if (resolvedCompanyId == null || resolvedCompanyId.isEmpty) {
        resolvedCompanyId = await _storageService.getCompanyId();
      }

      final Map<String, dynamic> queryParams = {};
      if (resolvedCompanyId != null && resolvedCompanyId.isNotEmpty) {
        queryParams['company'] = resolvedCompanyId;
      }

      final response = await _dioClient.dio.get(
        ApiEndpoints.billingAvailable,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> rawList;
        if (data is List) {
          rawList = data;
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          rawList = data['data'] as List;
        } else {
          return [];
        }

        return rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => AvailableProductModel.fromJson(item))
            .toList();
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to load available products (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      // 404 with "No Bottle Available" means 0 products in stock for this company
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  /// Records a partial/full payment on an existing bill via
  /// `PATCH /api/billing/{billId}/payment`.
  ///
  /// Returns the updated [BillModel] from the API response.
  Future<BillModel> recordPayment({
    required String billId,
    required String companyId,
    required double amountPaid,
  }) async {
    try {
      // Resolve company ID if not provided
      String resolvedCompanyId = companyId;
      if (resolvedCompanyId.isEmpty) {
        resolvedCompanyId = await _storageService.getCompanyId() ?? '';
      }

      final response = await _dioClient.dio.patch(
        ApiEndpoints.billingPayment(billId),
        data: {
          'company': resolvedCompanyId,
          'amountPaid': amountPaid,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') &&
              data['data'] is Map<String, dynamic>) {
            return BillModel.fromJson(
                data['data'] as Map<String, dynamic>);
          }
          return BillModel.fromJson(data);
        }
        throw Exception('Unexpected response format from server');
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to record payment (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  /// Returns products for an existing invoice via `POST /api/billing/return`.
  Future<Map<String, dynamic>> returnProducts({
    required String companyId,
    required String invoiceNo,
    required List<Map<String, dynamic>> lines,
  }) async {
    try {
      String resolvedCompanyId = companyId;
      if (resolvedCompanyId.isEmpty) {
        resolvedCompanyId = await _storageService.getCompanyId() ?? '';
      }

      final response = await _dioClient.dio.post(
        ApiEndpoints.billingReturn,
        data: {
          'company': resolvedCompanyId,
          'invoiceNo': invoiceNo,
          'lines': lines,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
        return {'message': 'Products returned successfully'};
      } else {
        throw Exception(
          response.data?['message'] ??
              'Failed to return products (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }
}
