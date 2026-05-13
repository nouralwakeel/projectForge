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
  }
}
