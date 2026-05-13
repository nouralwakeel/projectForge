import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';

class ProjectController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  RxList<ProjectModel> projects = <ProjectModel>[].obs;
  Rx<ProjectModel?> selectedProject = Rx<ProjectModel?>(null);
  RxBool isLoading = false.obs;
  RxString error = ''.obs;
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }
    isLoading.value = true;
    error.value = '';
    try {
      final response = await _api.get(ApiConfig.projects, queryParameters: {
        'page': currentPage.value,
      });
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final list = data['data'] as List;
        final newProjects = list.map((e) => ProjectModel.fromJson(e)).toList();
        if (refresh) {
          projects.value = newProjects;
        } else {
          projects.addAll(newProjects);
        }
        hasMore.value = data['current_page'] < data['last_page'];
      }
    } catch (e) {
      error.value = 'فشل في تحميل المشاريع';
    }
    isLoading.value = false;
  }

  Future<void> fetchProjectDetail(int id) async {
    isLoading.value = true;
    try {
      final response = await _api.get('${ApiConfig.projects}/$id');
      if (response.data['success'] == true) {
        selectedProject.value = ProjectModel.fromJson(response.data['data']);
      }
    } catch (e) {
      error.value = 'فشل في تحميل تفاصيل المشروع';
    }
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;
    currentPage.value++;
    await fetchProjects();
  }
}
