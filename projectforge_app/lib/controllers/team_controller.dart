import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/team_model.dart';
import '../services/api_service.dart';

class TeamController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  RxList<TeamModel> teams = <TeamModel>[].obs;
  Rx<TeamModel?> selectedTeam = Rx<TeamModel?>(null);
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, fetchTeams);
  }

  Future<void> fetchTeams() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await _api.get(ApiConfig.teams);
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final list = (data['data'] ?? data) as List;
        teams.value = list.map((e) => TeamModel.fromJson(e)).toList();
      }
    } catch (e) {
      error.value = 'فشل في تحميل الفرق';
    }
    isLoading.value = false;
  }

  Future<bool> createTeam(String name, int projectId) async {
    try {
      final response = await _api.post(ApiConfig.teams, data: {
        'name': name,
        'project_id': projectId,
      });
      if (response.data['success'] == true) {
        await fetchTeams();
        return true;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إنشاء الفريق');
    }
    return false;
  }

  Future<bool> joinTeam(int teamId) async {
    try {
      final response = await _api.post('${ApiConfig.teams}/$teamId/join');
      if (response.data['success'] == true) {
        await fetchTeams();
        return true;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في الانضمام للفريق');
    }
    return false;
  }

  Future<void> fetchTeamDetail(int id) async {
    isLoading.value = true;
    try {
      final response = await _api.get('${ApiConfig.teams}/$id');
      if (response.data['success'] == true) {
        selectedTeam.value = TeamModel.fromJson(response.data['data']);
      }
    } catch (e) {
      error.value = 'فشل في تحميل تفاصيل الفريق';
    }
    isLoading.value = false;
  }
}
