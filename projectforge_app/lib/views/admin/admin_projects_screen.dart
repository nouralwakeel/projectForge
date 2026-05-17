import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';

class AdminProjectsScreen extends StatelessWidget {
  const AdminProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.put(AdminDashboardController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightColor,
        appBar: AppBar(
          title: const Text('إدارة المشاريع'),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.onSurface,
          elevation: 0,
        ),
        body: Obx(() {
          if (adminController.isLoading.value && adminController.recentProjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = adminController.recentProjects;
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('لا توجد مشاريع حالياً', style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => adminController.fetchDashboardData(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final project = projects[index];
                final title = project['title'] ?? '';
                final status = project['status'] ?? 'available';
                final statusLabel = status == 'available'
                    ? 'متاح'
                    : status == 'in_progress'
                        ? 'قيد التنفيذ'
                        : status == 'completed'
                            ? 'مكتمل'
                            : 'ملغي';
                final statusColor = status == 'available'
                    ? AppTheme.successColor
                    : status == 'in_progress'
                        ? AppTheme.tertiaryColor
                        : status == 'completed'
                            ? AppTheme.primaryColor
                            : AppTheme.dangerColor;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.assignment, size: 22, color: statusColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(statusLabel, style: TextStyle(fontSize: 13, color: statusColor)),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: AppTheme.onSurfaceVariant),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'available', child: Text('متاح')),
                          const PopupMenuItem(value: 'in_progress', child: Text('قيد التنفيذ')),
                          const PopupMenuItem(value: 'completed', child: Text('مكتمل')),
                          const PopupMenuItem(value: 'cancelled', child: Text('ملغي')),
                          const PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(color: AppTheme.dangerColor))),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            adminController.deleteProject(project['id']);
                          } else {
                            adminController.updateProjectStatus(project['id'], value);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}