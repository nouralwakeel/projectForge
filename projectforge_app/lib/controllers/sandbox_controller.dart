import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/sandbox_model.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';

class SandboxController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  Rx<SandboxModel?> sandbox = Rx<SandboxModel?>(null);
  Rx<ProjectModel?> project = Rx<ProjectModel?>(null);
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  // AI-generated to-do checklist + live risk percentage.
  RxList<dynamic> todos = [].obs;
  RxInt riskPercentage = 0.obs;
  RxBool aiGenerated = false.obs;
  RxBool isLoadingTodos = false.obs;

  Future<void> fetchSandbox(int projectId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await _api.get(ApiConfig.projectSandbox(projectId));
      if (response.data['success'] == true) {
        sandbox.value = SandboxModel.fromJson(response.data['data']);
        if (response.data['data']['project'] != null) {
          project.value = ProjectModel.fromJson(response.data['data']['project']);
        }
      }
    } catch (e) {
      error.value = 'فشل في تحميل بيانات المحاكاة';
    }
    isLoading.value = false;
    fetchTodos(projectId);
  }

  Future<void> fetchTodos(int projectId) async {
    isLoadingTodos.value = true;
    try {
      final response = await _api.get(ApiConfig.projectTodos(projectId));
      if (response.data['success'] == true) {
        final data = response.data['data'];
        todos.value = data['todos'] ?? [];
        riskPercentage.value = (data['risk_percentage'] ?? 0) as int;
        aiGenerated.value = data['ai_generated'] == true;
      }
    } catch (e) {
      // Non-fatal: the sandbox still works without the checklist.
    } finally {
      isLoadingTodos.value = false;
    }
  }

  Future<void> toggleTodo(int projectId, int todoId) async {
    try {
      final response =
          await _api.post(ApiConfig.toggleTodo(projectId, todoId));
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final updated = data['todo'];
        final index = todos.indexWhere((t) => t['id'] == todoId);
        if (index != -1 && updated != null) {
          todos[index] = updated;
          todos.refresh();
        }
        riskPercentage.value = (data['risk_percentage'] ?? riskPercentage.value) as int;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'تعذّر تحديث المهمة');
    }
  }
}
