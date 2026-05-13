import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final authService = Get.find<AuthService>();
      if (authService.isLoggedIn.value) {
        final user = authService.currentUser.value;
        if (user != null && user.skills != null && user.skills!.isNotEmpty) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.survey);
        }
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_circle, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            const Text(
              'ProjectForge',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'نظام إدارة مشاريع التخرج',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
