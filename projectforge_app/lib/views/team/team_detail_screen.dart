import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/team_controller.dart';
import '../../controllers/estimation_controller.dart';
import '../../app/routes/app_routes.dart';

class TeamDetailScreen extends StatelessWidget {
  const TeamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamController = Get.find<TeamController>();
    final estController = Get.find<EstimationController>();
    final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      teamController.fetchTeamDetail(id);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفريق'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Get.toNamed(AppRoutes.settings)),
        ],
      ),
      body: Obx(() {
        if (teamController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final team = teamController.selectedTeam.value;
        if (team == null) {
          return const Center(child: Text('الفريق غير موجود'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(team.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('المشروع: ${team.project?.title ?? "غير محدد"}'),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(team.isApproved ? 'معتمد' : 'بانتظار الاعتماد'),
                      backgroundColor: team.isApproved ? Colors.green.shade100 : Colors.orange.shade100,
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              const Text('الأعضاء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(team.members ?? []).map((m) => Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(m.user?.firstName[0] ?? '?')),
                      title: Text(m.user?.fullName ?? 'عضو'),
                      trailing: Chip(
                        label: Text(m.roleInTeam == 'leader' ? 'قائد' : 'عضو'),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  estController.estimateTeam(id);
                  Get.toNamed(AppRoutes.estimation.replaceAll(':id', '${team.projectId}'));
                },
                icon: const Icon(Icons.analytics),
                label: const Text('تقدير احتمالية النجاح'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
