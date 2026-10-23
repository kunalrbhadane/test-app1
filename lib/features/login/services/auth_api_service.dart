import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthApiService {
  final DioClient _dioClient = DioClient();
  final StorageService _storageService = StorageService();

  Future<UserModel> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {
          'mobile': mobile.trim(),
          'password': password.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final user = UserModel.fromJson(data);
          // Save user data and company
          await _storageService.saveUserData(data);
          if (user.company != null) {
            await _storageService.saveCompanyId(user.company!.id);
          }
          return user;
        } else {
          throw Exception('Unexpected response format from server');
        }
      } else {
        throw Exception(
          response.data?['message'] ??
              response.data?['error'] ??
              'Login failed. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> logout() async {
    Map<String, dynamic> result = {};
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.logout,
      );

      if (response.data is Map<String, dynamic>) {
        result = response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        result = e.response!.data as Map<String, dynamic>;
      }
    } catch (_) {
      // Ignored to guarantee local session cleanup completes smoothly
    } finally {
      await _storageService.clearAll();
    }
    return result;
  }
}
