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

  Future<void> loadMajors() async {
    try {
      final res = await _apiService.get(ApiConfig.majors);
      if (res.data['success'] == true) {
        majors.value = (res.data['data'] as List).map((e) => MajorModel.fromJson(e)).toList();
      }
    } catch (e) {
      majors.clear();
    }
  }

  String _routeForUser(UserModel? user) {
    if (user == null) return AppRoutes.login;
    if (user.role == 'admin') return AppRoutes.adminDashboard;
    if (user.skills == null || user.skills!.isEmpty) return AppRoutes.survey;
    return AppRoutes.home;
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    final success = await _authService.login(email, password);
    isLoading.value = false;
    if (success) {
      final user = _authService.currentUser.value;
      Get.offAllNamed(_routeForUser(user));
    } else {
      errorMessage.value = 'بيانات الدخول غير صحيحة';
    }
    return success;
  }

  Future<bool> register(Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = '';
    final success = await _authService.register(data);
    isLoading.value = false;
    if (success) {
      Get.offAllNamed(AppRoutes.survey);
    } else {
      errorMessage.value = 'فشل في إنشاء الحساب';
    }
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
