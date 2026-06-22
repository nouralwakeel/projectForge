import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AdvisorDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  RxMap<String, dynamic> stats = <String, dynamic>{}.obs;
  RxList<dynamic> projects = [].obs;
  RxList<dynamic> teamRequests = [].obs;
  RxBool isLoadingRequests = false.obs;
  RxString requestsFilter = 'pending'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    fetchTeamRequests();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _apiService.get(ApiConfig.advisorDashboard);
      if (response.data['success'] == true) {
        final data = response.data['data'];
        stats.value = Map<String, dynamic>.from(data['stats'] ?? {});
        projects.value = data['projects'] ?? [];
      }
    } catch (e) {
      errorMessage.value = 'فشل في تحميل البيانات';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTeamRequests() async {
    isLoadingRequests.value = true;
    try {
      final response = await _apiService.get(
        ApiConfig.advisorTeamRequests,
        queryParameters: {'status': requestsFilter.value},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'];
        teamRequests.value = data is List ? data : (data['data'] ?? []);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل طلبات الفرق');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> approveTeam(int teamId) async {
    try {
      final response = await _apiService.put('${ApiConfig.advisorTeamRequests}/$teamId/approve');
      if (response.data['success'] == true) {
        Get.snackbar('نجاح', 'تم قبول الفريق بنجاح');
        fetchTeamRequests();
        fetchDashboardData();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في قبول الفريق');
    }
  }

  Future<void> rejectTeam(int teamId, {required String reason}) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.advisorTeamRequests}/$teamId/reject',
        data: {'rejection_reason': reason},
      );
      if (response.data['success'] == true) {
        Get.snackbar('نجاح', 'تم رفض الفريق');
        fetchTeamRequests();
        fetchDashboardData();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في رفض الفريق');
    }
  }

  void setRequestsFilter(String status) {
    requestsFilter.value = status;
    fetchTeamRequests();
  }
}
