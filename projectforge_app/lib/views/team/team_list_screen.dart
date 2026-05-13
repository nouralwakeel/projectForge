import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/team_controller.dart';
import '../../app/routes/app_routes.dart';

class TeamListScreen extends StatelessWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeamController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفرق'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Get.toNamed(AppRoutes.settings)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.teams.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.teams.isEmpty) {
          return const Center(child: Text('لا توجد فرق'));
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchTeams(),
          child: ListView.builder(
            itemCount: controller.teams.length,
            itemBuilder: (_, i) {
              final team = controller.teams[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(team.name[0])),
                  title: Text(team.name),
                  subtitle: Text('الأعضاء: ${team.members?.length ?? 0} | ${team.isApproved ? "معتمد" : "بانتظار الاعتماد"}'),
                  trailing: IconButton(icon: const Icon(Icons.login), onPressed: () => controller.joinTeam(team.id)),
                  onTap: () => Get.toNamed(AppRoutes.teamDetail.replaceAll(':id', '${team.id}')),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showCreateDialog(BuildContext context, TeamController controller) {
    final nameCtrl = TextEditingController();
    final projectIdCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'إنشاء فريق جديد',
      content: Column(children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الفريق')),
        const SizedBox(height: 12),
        TextField(controller: projectIdCtrl, decoration: const InputDecoration(labelText: 'رقم المشروع'), keyboardType: TextInputType.number),
      ]),
      textConfirm: 'إنشاء',
      textCancel: 'إلغاء',
      onConfirm: () {
        if (nameCtrl.text.isNotEmpty && projectIdCtrl.text.isNotEmpty) {
          controller.createTeam(nameCtrl.text, int.parse(projectIdCtrl.text));
          Get.back();
        }
      },
    );
  }
}
