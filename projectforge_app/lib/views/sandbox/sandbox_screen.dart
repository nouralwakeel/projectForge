import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sandbox_controller.dart';
import '../../widgets/milestone_timeline.dart';
import '../../widgets/risk_card.dart';
import '../../app/routes/app_routes.dart';

class SandboxScreen extends StatelessWidget {
  const SandboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SandboxController>();
    final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSandbox(id);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('خطة العمل - Sandbox'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Get.toNamed(AppRoutes.settings)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final sandbox = controller.sandbox.value;
        final project = controller.project.value;
        if (sandbox == null) {
          return const Center(child: Text('لا توجد بيانات'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    const Icon(Icons.schedule, size: 32, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(project?.title ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('إجمالي المدة: ${sandbox.totalEstimatedDays} يوم', style: const TextStyle(color: Colors.grey)),
                    ])),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              const Text('المراحل الزمنية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              MilestoneTimeline(timeline: sandbox.timeline),
              if (project?.risks != null && project!.risks!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('المخاطر المحتملة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...project.risks!.map((r) => RiskCard(risk: r)),
              ],
            ],
          ),
        );
      }),
    );
  }
}
