import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settings = Get.find<SettingsService>();
  final ApiService _api = Get.find<ApiService>();

  final ipController = TextEditingController();
  final portController = TextEditingController();

  final isTestingApi = false.obs;
  final isTestingDb = false.obs;
  final apiTestResult = Rxn<String>();
  final dbTestResult = Rxn<String>();
  final apiTestSuccess = false.obs;
  final dbTestSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    ipController.text = _settings.apiIp.value;
    portController.text = _settings.apiPort.value;
  }

  @override
  void onClose() {
    ipController.dispose();
    portController.dispose();
    super.onClose();
  }

  void saveSettings() {
    final ip = ipController.text.trim();
    final port = portController.text.trim();
    _settings.saveSettings(ip, port);
    _api.updateBaseUrl(_settings.getBaseUrl());
    Get.snackbar(
      'تم الحفظ',
      'تم حفظ الإعدادات بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> testApiConnection() async {
    isTestingApi.value = true;
    apiTestResult.value = null;
    apiTestSuccess.value = false;

    try {
      final dio = Dio(BaseOptions(
        baseUrl: _settings.getBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.get(ApiConfig.majors);
      if (response.statusCode == 200) {
        apiTestSuccess.value = true;
        apiTestResult.value = 'تم الاتصال بنجاح بـ API (${response.statusCode})';
      } else {
        apiTestSuccess.value = false;
        apiTestResult.value = 'استجابة غير متوقعة: ${response.statusCode}';
      }
    } on DioException catch (e) {
      apiTestSuccess.value = false;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        apiTestResult.value = 'فشل الاتصال: تعذر الوصول للخادم';
      } else {
        apiTestResult.value = 'خطأ: ${e.message ?? "غير معروف"}';
      }
    } catch (e) {
      apiTestSuccess.value = false;
      apiTestResult.value = 'خطأ غير متوقع: $e';
    } finally {
      isTestingApi.value = false;
    }
  }

  Future<void> testDbConnection() async {
    isTestingDb.value = true;
    dbTestResult.value = null;
    dbTestSuccess.value = false;

    try {
      final dio = Dio(BaseOptions(
        baseUrl: _settings.getBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.get('/health/db');
      final data = response.data;
      if (data['success'] == true) {
        dbTestSuccess.value = true;
        final driver = data['data']?['driver'] ?? '';
        final database = data['data']?['database'] ?? '';
        dbTestResult.value = 'اتصال ناجح بقاعدة البيانات ($driver: $database)';
      } else {
        dbTestSuccess.value = false;
        dbTestResult.value = data['message'] ?? 'فشل الاتصال بقاعدة البيانات';
      }
    } on DioException catch (e) {
      dbTestSuccess.value = false;
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('error')) {
          dbTestResult.value = 'فشل: ${data['error']}';
        } else {
          dbTestResult.value = 'فشل الاتصال بقاعدة البيانات (${e.response?.statusCode})';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        dbTestResult.value = 'فشل الاتصال: تعذر الوصول للخادم';
      } else {
        dbTestResult.value = 'خطأ: ${e.message ?? "غير معروف"}';
      }
    } catch (e) {
      dbTestSuccess.value = false;
      dbTestResult.value = 'خطأ غير متوقع: $e';
    } finally {
      isTestingDb.value = false;
    }
  }
}
