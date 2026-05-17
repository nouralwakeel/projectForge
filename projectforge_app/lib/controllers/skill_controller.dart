import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/skill_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class SkillController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  RxList<SkillModel> skills = <SkillModel>[].obs;
  RxMap<int, int> selectedProficiency = <int, int>{}.obs;
  RxMap<int, int> selectedInterest = <int, int>{}.obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxString error = ''.obs;
  RxInt currentStep = 0.obs;

  static const List<List<String>> stepCategories = [
    ['Frontend', 'Programming Languages', 'Backend'],
    ['Databases', 'AI/ML', 'Tools', 'Cloud', 'Design'],
    ['Cybersecurity', 'IoT', 'Soft Skills'],
  ];

  static const List<String> stepTitles = [
    'استبيان المهارات - الجزء الأول',
    'استبيان المهارات - الجزء الثاني',
    'استبيان المهارات - الجزء الثالث',
  ];

  static const List<String> stepSubtitles = [
    'التطوير والبرمجة',
    'البيانات والذكاء الاصطناعي والأدوات',
    'الأمن السيبراني، إنترنت الأشياء، والمهارات الناعمة',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSkills();
  }

  Future<void> fetchSkills() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await _api.get(ApiConfig.skills);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        skills.value = list.map((e) => SkillModel.fromJson(e)).toList();
      }
      await _loadExistingSkills();
    } catch (e) {
      error.value = 'فشل في تحميل المهارات';
    }
    isLoading.value = false;
  }

  Future<void> _loadExistingSkills() async {
    try {
      final response = await _api.get(ApiConfig.userSkills);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        for (var item in list) {
          final model = UserSkillModel.fromJson(item);
          selectedProficiency[model.id] = model.proficiencyLevel;
          selectedInterest[model.id] = model.interestLevel;
        }
      }
    } catch (_) {}
  }

  void setProficiency(int skillId, int level) {
    selectedProficiency[skillId] = level;
  }

  void removeProficiency(int skillId) {
    selectedProficiency.remove(skillId);
  }

  void setInterest(int skillId, int level) {
    selectedInterest[skillId] = level;
  }

  void removeInterest(int skillId) {
    selectedInterest.remove(skillId);
  }

  void nextStep() {
    if (currentStep.value < stepCategories.length - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  bool get isLastStep => currentStep.value == stepCategories.length - 1;

  List<String> categoriesForCurrentStep() {
    return stepCategories[currentStep.value];
  }

  List<SkillModel> skillsByCategory(String category) {
    return skills.where((s) => s.category == category).toList();
  }

  Future<bool> saveSkills() async {
    if (selectedProficiency.isEmpty) {
      Get.snackbar('تنبيه', 'اختر مهارة واحدة على الأقل');
      return false;
    }
    if (isSaving.value) return false;
    isSaving.value = true;
    try {
      final skillIds = selectedProficiency.keys.toSet();
      final skillsData = skillIds.map((id) => {
            'skill_id': id,
            'proficiency_level': selectedProficiency[id] ?? 1,
            'interest_level': selectedInterest[id] ?? 1,
          }).toList();

      final response = await _api.post(ApiConfig.userSkills, data: {
        'skills': skillsData,
      });

      if (response.data['success'] == true) {
        Get.offAllNamed('/dashboard');
        return true;
      } else {
        final msg = response.data['message'] ?? 'فشل في حفظ المهارات';
        Get.snackbar('خطأ', msg.toString());
      }
    } on DioException catch (e) {
      String msg = 'فشل في حفظ المهارات';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = 'انتهت مهلة الاتصال، تحقق من الشبكة';
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          msg = errors.values.first.first.toString();
        }
      } else if (e.response?.data?['message'] != null) {
        msg = e.response!.data['message'].toString();
      }
      Get.snackbar('خطأ', msg);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ غير متوقع: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
    return false;
  }

  List<String> get categories {
    final cats = skills.map((s) => s.category).toSet().toList();
    cats.sort();
    return cats;
  }
}
