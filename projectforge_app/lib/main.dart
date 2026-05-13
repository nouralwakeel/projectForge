import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'config/app_theme.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };
    runApp(const ProjectForgeApp());
  }, (error, stack) {
    debugPrint('Unhandled error: $error');
  });
}

class ProjectForgeApp extends StatelessWidget {
  const ProjectForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ProjectForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      locale: const Locale('ar'),
      fallbackLocale: const Locale('en'),
    );
  }
}
