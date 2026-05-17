import 'dart:convert';
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

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiConfig.register, data: data);
      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        final user = response.data['data']['user'];
        await _storage.saveToken(token);
        await _storage.saveUserData(jsonEncode(user));
        currentUser.value = UserModel.fromJson(user);
        isLoggedIn.value = true;
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
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
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e);
      return false;
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

  void _handleError(dynamic e) {
    if (e.toString().contains('401')) {
      Get.snackbar('خطأ', 'بيانات الدخول غير صحيحة');
    } else if (e.toString().contains('422')) {
      Get.snackbar('خطأ في البيانات', 'تحقق من المدخلات وحاول مرة أخرى');
    } else {
      Get.snackbar('خطأ', 'حدث خطأ في الاتصال');
    }
  }
}
