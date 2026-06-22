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
              const SizedBox(height: 16),
              _buildRiskGauge(controller),
              const SizedBox(height: 16),
              _buildTodoSection(controller, id),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRiskGauge(SandboxController controller) {
    final risk = controller.riskPercentage.value;
    final color = risk >= 70
        ? Colors.red
        : risk >= 40
            ? Colors.orange
            : Colors.green;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: color, size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('نسبة خطورة المشروع',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text('$risk%',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: risk / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تنخفض نسبة الخطورة كلما أنجزت مهام القائمة أدناه',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoSection(SandboxController controller, int projectId) {
    if (controller.isLoadingTodos.value && controller.todos.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ));
    }
    if (controller.todos.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('قائمة المهام',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (controller.aiGenerated.value)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 13, color: Colors.deepPurple),
                    SizedBox(width: 4),
                    Text('مولّدة بالذكاء',
                        style: TextStyle(fontSize: 11, color: Colors.deepPurple)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...controller.todos.map((todo) {
          final isDone = todo['is_done'] == true;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: CheckboxListTile(
              value: isDone,
              onChanged: (_) =>
                  controller.toggleTodo(projectId, todo['id'] as int),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                todo['title']?.toString() ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : null,
                ),
              ),
              subtitle: (todo['description']?.toString().isNotEmpty ?? false)
                  ? Text(todo['description'].toString(),
                      style: const TextStyle(fontSize: 12.5))
                  : null,
            ),
          );
        }),
      ],
    );
  }
}
