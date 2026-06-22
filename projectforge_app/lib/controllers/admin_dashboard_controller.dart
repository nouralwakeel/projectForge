import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../app/routes/app_routes.dart';

class AdminDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  RxMap<String, dynamic> stats = <String, dynamic>{}.obs;
  RxList<dynamic> recentUsers = [].obs;
  RxList<dynamic> recentProjects = [].obs;

  // Full project list (with type, teams, academic year/semester) for the
  // projects management screen — richer than the dashboard's recent_projects.
  RxList<dynamic> adminProjects = [].obs;
  RxBool isLoadingProjects = false.obs;
  RxString projectsStatusFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchAdminProjects() async {
    isLoadingProjects.value = true;
    try {
      final params = <String, dynamic>{};
      if (projectsStatusFilter.value != 'all') {
        params['status'] = projectsStatusFilter.value;
      }
      final response = await _apiService.get(ApiConfig.adminProjects,
          queryParameters: params);
      if (response.data['success'] == true) {
        final data = response.data['data'];
        adminProjects.value = data is List ? data : (data['data'] ?? []);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل المشاريع');
    } finally {
      isLoadingProjects.value = false;
    }
  }

  void setProjectsStatusFilter(String status) {
    projectsStatusFilter.value = status;
    fetchAdminProjects();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _apiService.get(ApiConfig.adminDashboard);
      if (response.data['success'] == true) {
        final data = response.data['data'];
        stats.value = Map<String, dynamic>.from(data['stats'] ?? {});
        recentUsers.value = data['recent_users'] ?? [];
        recentProjects.value = data['recent_projects'] ?? [];
      }
    } catch (e) {
      errorMessage.value = 'فشل في تحميل البيانات';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _apiService.delete('${ApiConfig.adminUsers}/$userId');
      recentUsers.removeWhere((u) => u['id'] == userId);
      fetchDashboardData();
      Get.snackbar('نجاح', 'تم حذف المستخدم بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف المستخدم');
    }
  }

  Future<void> deleteProject(int projectId) async {
    try {
      await _apiService.delete('${ApiConfig.adminProjects}/$projectId');
      recentProjects.removeWhere((p) => p['id'] == projectId);
      adminProjects.removeWhere((p) => p['id'] == projectId);
      fetchDashboardData();
      Get.snackbar('نجاح', 'تم حذف المشروع بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف المشروع');
    }
  }

  Future<void> updateProjectStatus(int projectId, String status) async {
    try {
      await _apiService.put('${ApiConfig.adminProjects}/$projectId/status', data: {'status': status});
      fetchDashboardData();
      fetchAdminProjects();
      Get.snackbar('نجاح', 'تم تحديث حالة المشروع');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث حالة المشروع');
    }
  }

  void navigateToUsers() {
    Get.toNamed(AppRoutes.adminUsers);
  }

  void navigateToProjects() {
    Get.toNamed(AppRoutes.adminProjects);
  }

  void navigateToMajors() {
    Get.toNamed(AppRoutes.adminMajors);
  }

  void navigateToSkills() {
    Get.toNamed(AppRoutes.adminSkills);
  }
}