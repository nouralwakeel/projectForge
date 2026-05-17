import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'config/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  // Ensure settings are loaded before any service reads the base URL
  Get.put<StorageService>(StorageService(), permanent: true);
  final settings = SettingsService();
  Get.put<SettingsService>(settings, permanent: true);
  await settings.ensureLoaded();
  Get.put<ApiService>(ApiService(), permanent: true);
  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);

  runApp(const ProjectForgeApp());
}

class ProjectForgeApp extends StatelessWidget {
  const ProjectForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ProjectForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      locale: const Locale('ar'),
      fallbackLocale: const Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
    );
  }
}
