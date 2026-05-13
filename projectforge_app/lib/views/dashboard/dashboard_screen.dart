import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/recommendation_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/project_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recController = Get.find<RecommendationController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ProjectForge'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Get.toNamed(AppRoutes.settings)),
          IconButton(icon: const Icon(Icons.person), onPressed: () => Get.toNamed(AppRoutes.profile)),
          IconButton(icon: const Icon(Icons.group), onPressed: () => Get.toNamed(AppRoutes.teams)),
          PopupMenuButton(
            itemBuilder: (_) => [const PopupMenuItem(value: 'logout', child: Text('تسجيل الخروج'))],
            onSelected: (v) { if (v == 'logout') authController.logout(); },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => recController.fetchRecommendations(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final user = authController.isLoggedIn.value ? 'مرحباً بك' : '';
                return Text(user, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
              }),
              const SizedBox(height: 4),
              const Text('المشاريع الموصى بها لك', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Obx(() {
                if (recController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (recController.error.value == 'no_skills') {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Icons.assignment_late, size: 60, color: Colors.orange),
                        const SizedBox(height: 16),
                        const Text('يجب إكمال استبيان المهارات أولاً'),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: () => Get.toNamed(AppRoutes.survey), child: const Text('إكمال الاستبيان')),
                      ],
                    ),
                  );
                }
                if (recController.recommendations.isEmpty) {
                  return const Center(child: Text('لا توجد توصيات متاحة'));
                }
                return Column(
                  children: recController.recommendations.map((rec) {
                    return ProjectCard(
                      project: rec.project,
                      matchPercentage: rec.matchPercentage,
                      onTap: () => Get.toNamed(AppRoutes.projectDetail.replaceAll(':id', '${rec.project.id}')),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
