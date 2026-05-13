import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/settings_service.dart';
import '../../services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<SettingsService>(SettingsService(), permanent: true);
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
