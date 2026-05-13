import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/recommendation_model.dart';
import '../services/api_service.dart';

class RecommendationController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  RxList<RecommendationModel> recommendations = <RecommendationModel>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await _api.get(ApiConfig.recommendations);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        recommendations.value =
            list.map((e) => RecommendationModel.fromJson(e)).toList();
      }
    } catch (e) {
      if (e.toString().contains('400')) {
        error.value = 'no_skills';
      } else {
        error.value = 'فشل في تحميل التوصيات';
      }
    }
    isLoading.value = false;
  }
}
