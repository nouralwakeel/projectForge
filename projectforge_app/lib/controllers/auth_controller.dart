import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();

  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;
  RxString errorMessage = ''.obs;
  RxList<MajorModel> majors = <MajorModel>[].obs;
  RxnInt selectedMajor = RxnInt();

  @override
  void onInit() {
    super.onInit();
    ever(_authService.isLoggedIn, (val) {
      isLoggedIn.value = val;
    });
    isLoggedIn.value = _authService.isLoggedIn.value;
    loadMajors();
  }

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

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    final success = await _authService.login(email, password);
    isLoading.value = false;
    if (success) {
      final user = _authService.currentUser.value;
      if (user != null && (user.skills == null || user.skills!.isEmpty)) {
        Get.offAllNamed('/survey');
      } else {
        Get.offAllNamed('/home');
      }
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
      Get.offAllNamed('/survey');
    } else {
      errorMessage.value = 'فشل في إنشاء الحساب';
    }
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
