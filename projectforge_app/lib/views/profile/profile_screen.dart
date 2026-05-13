import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Get.toNamed(AppRoutes.settings)),
        ],
      ),
      body: Obx(() {
        final user = authService.currentUser.value;
        if (user == null) {
          return const Center(child: Text('لا توجد بيانات'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(radius: 50, child: Text(user.fullName[0], style: const TextStyle(fontSize: 32))),
              const SizedBox(height: 16),
              Text(user.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user.email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Card(
                child: Column(children: [
                  _infoTile('الرقم الجامعي', user.studentId, Icons.badge),
                  _infoTile('التخصص', user.major?.name ?? 'غير محدد', Icons.school),
                  _infoTile('المستوى الأكاديمي', '${user.academicLevel ?? "-"}', Icons.stairs),
                  _infoTile('الجنس', user.gender == 'male' ? 'ذكر' : 'أنثى', Icons.person),
                  _infoTile('الدور', user.role, Icons.admin_panel_settings),
                ]),
              ),
              const SizedBox(height: 16),
              if (user.skills != null && user.skills!.isNotEmpty) ...[
                const Align(alignment: Alignment.centerLeft, child: Text('المهارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.skills!.map((s) => Chip(
                    label: Text('${s.name} (${s.proficiencyLevel}/5)'),
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.survey),
                  child: const Text('تعديل المهارات'),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => authController.logout(),
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return ListTile(leading: Icon(icon), title: Text(label), subtitle: Text(value));
  }
}
