import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/project_controller.dart';
import '../../config/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/skill_chip.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectController>();
    final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProjectDetail(id);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المشروع'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Get.toNamed(AppRoutes.settings)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final project = controller.selectedProject.value;
        if (project == null) {
          return const Center(child: Text('المشروع غير موجود'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                Chip(label: Text(AppConstants.projectTypeLabels[project.type] ?? project.type)),
                const SizedBox(width: 8),
                Chip(label: Text('صعوبة: ${project.difficultyLevel}')),
                const SizedBox(width: 8),
                Chip(label: Text(AppConstants.statusLabels[project.status] ?? project.status)),
              ]),
              const SizedBox(height: 16),
              const Text('الوصف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(project.description),
              const SizedBox(height: 16),
              if (project.advisor != null) ...[
                const Text('المشرف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(project.advisor!.fullName),
                const SizedBox(height: 16),
              ],
              if (project.skills != null && project.skills!.isNotEmpty) ...[
                const Text('المهارات المطلوبة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: project.skills!.map((s) => SkillChip(skill: s)).toList()),
                const SizedBox(height: 16),
              ],
              const Divider(),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.sandbox.replaceAll(':id', '$id')),
                  icon: const Icon(Icons.timeline),
                  label: const Text('خطة العمل'),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.estimation.replaceAll(':id', '$id')),
                  icon: const Icon(Icons.analytics),
                  label: const Text('تقدير النجاح'),
                )),
              ]),
            ],
          ),
        );
      }),
    );
  }
}
