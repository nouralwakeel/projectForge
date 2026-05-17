import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();

  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;
  RxString errorMessage = ''.obs;
  RxList<MajorModel> majors = <MajorModel>[].obs;
  RxnInt selectedMajor = RxnInt();
  RxBool isLoadingMajors = false.obs;
  RxString majorsError = ''.obs;

  Future<void> loadMajors() async {
    isLoadingMajors.value = true;
    majorsError.value = '';
    try {
      final res = await _apiService.get(ApiConfig.majors);
      if (res.data['success'] == true) {
        final data = res.data['data'];
        if (data is List) {
          majors.assignAll(
            data.map((e) => MajorModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
          );
        }
      } else {
        majorsError.value = 'فشل تحميل التخصصات';
      }
    } catch (e) {
      debugPrint('loadMajors error: $e');
      majorsError.value = 'تعذر الاتصال بالخادم';
      majors.clear();
    } finally {
      isLoadingMajors.value = false;
    }
  }

  String _routeForUser(UserModel? user) {
    if (user == null) return AppRoutes.login;
    if (user.role == 'admin') return AppRoutes.adminDashboard;
    if (user.skills == null || user.skills!.isEmpty) return AppRoutes.survey;
    return AppRoutes.home;
  }

  Future<bool> login(String email, String password) async {
    errorMessage.value = '';

    if (email.isEmpty) {
      errorMessage.value = 'الرجاء إدخال البريد الإلكتروني';
      return false;
    }
    if (!_isValidEmail(email)) {
      errorMessage.value = 'صيغة البريد الإلكتروني غير صحيحة';
      return false;
    }
    if (password.isEmpty) {
      errorMessage.value = 'الرجاء إدخال كلمة المرور';
      return false;
    }

    isLoading.value = true;
    final error = await _authService.login(email, password);
    isLoading.value = false;
    if (error == null) {
      final user = _authService.currentUser.value;
      Get.offAllNamed(_routeForUser(user));
      return true;
    }
    errorMessage.value = error;
    return false;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  Future<bool> register(Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = '';
    final error = await _authService.register(data);
    isLoading.value = false;
    if (error == null) {
      Get.offAllNamed(AppRoutes.survey);
      return true;
    }
    errorMessage.value = error;
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
