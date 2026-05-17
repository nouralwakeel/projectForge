import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isInitialized = false.obs;

  Future<void> checkLogin() async {
    if (isInitialized.value) return;
    try {
      final loggedIn = await _storage.isLoggedIn();
      if (loggedIn) {
        try {
          final response = await _api.get(ApiConfig.me);
          if (response.data['success'] == true) {
            currentUser.value = UserModel.fromJson(response.data['data']);
            isLoggedIn.value = true;
          }
        } catch (_) {
          await _storage.clearAll();
        }
      }
    } catch (_) {
      await _storage.clearAll();
    }
    isInitialized.value = true;
  }

  /// Returns null on success, or an Arabic error message on failure.
  Future<String?> register(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiConfig.register, data: data);
      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];
        await _storage.saveToken(token);
        await _storage.saveUserData(jsonEncode(user));
        currentUser.value = UserModel.fromJson(user);
        isLoggedIn.value = true;
        return null;
      }
      return response.data['message'] as String? ?? 'فشل في إنشاء الحساب';
    } on DioException catch (e) {
      return _extractDioError(e);
    } catch (_) {
      return 'حدث خطأ غير متوقع';
    }
  }

  /// Returns null on success, or an Arabic error message on failure.
  Future<String?> login(String email, String password) async {
    try {
      final response = await _api.post(ApiConfig.login, data: {
        'email': email,
        'password': password,
      });
      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];
        await _storage.saveToken(token);
        await _storage.saveUserData(jsonEncode(user));
        currentUser.value = UserModel.fromJson(user);
        isLoggedIn.value = true;
        return null;
      }
      return response.data['message'] as String? ?? 'بيانات الدخول غير صحيحة';
    } on DioException catch (e) {
      return _extractDioError(e);
    } catch (_) {
      return 'حدث خطأ غير متوقع';
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout);
    } catch (_) {}
    await _storage.clearAll();
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }

  Future<void> refreshProfile() async {
    try {
      final response = await _api.get(ApiConfig.me);
      if (response.data['success'] == true) {
        currentUser.value = UserModel.fromJson(response.data['data']);
        await _storage.saveUserData(jsonEncode(response.data['data']));
      }
    } catch (_) {}
  }

  /// Extracts a human-readable Arabic message from a Dio error.
  /// For 422 validation errors, joins all field messages into one string.
  String _extractDioError(DioException e) {
    final response = e.response;

    if (response != null) {
      final body = response.data;
      if (body is Map) {
        // Collect field-level validation messages (422 shape)
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final lines = <String>[];
          errors.forEach((field, messages) {
            if (messages is List && messages.isNotEmpty) {
              lines.add('• ${messages.first}');
            }
          });
          if (lines.isNotEmpty) return lines.join('\n');
        }

        // Fall back to top-level message
        final msg = body['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }

      switch (response.statusCode) {
        case 401:
          return 'بيانات الدخول غير صحيحة';
        case 403:
          return 'ليس لديك صلاحية لهذا الإجراء';
        case 404:
          return 'المورد المطلوب غير موجود';
        case 500:
          return 'خطأ في الخادم، يرجى المحاولة لاحقاً';
        default:
          return 'خطأ من الخادم (${response.statusCode})';
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال، تحقق من الشبكة';
      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالخادم، تحقق من العنوان والشبكة';
      default:
        return 'حدث خطأ في الاتصال';
    }
  }
}
