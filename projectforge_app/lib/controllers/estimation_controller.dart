import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/success_estimation_model.dart';
import '../services/api_service.dart';

class EstimationController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  Rx<SuccessEstimationModel?> estimation = Rx<SuccessEstimationModel?>(null);
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  Future<void> estimateProject(int projectId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await _api.get(ApiConfig.projectEstimate(projectId));
      if (response.data['success'] == true) {
        estimation.value = SuccessEstimationModel.fromJson(response.data['data']);
      }
    } catch (e) {
      error.value = 'فشل في حساب احتمالية النجاح';
    }
    isLoading.value = false;
  }

  Future<void> estimateTeam(int teamId) async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await _api.get(ApiConfig.teamEstimate(teamId));
      if (response.data['success'] == true) {
        estimation.value = SuccessEstimationModel.fromJson(response.data['data']);
      }
    } catch (e) {
      error.value = 'فشل في حساب احتمالية النجاح';
    }
    isLoading.value = false;
  }
}
