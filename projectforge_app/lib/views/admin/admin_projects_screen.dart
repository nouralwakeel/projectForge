import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';

class AdminProjectsScreen extends StatefulWidget {
  const AdminProjectsScreen({super.key});

  @override
  State<AdminProjectsScreen> createState() => _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen> {
  final AdminDashboardController adminController =
      Get.put(AdminDashboardController());

  @override
  void initState() {
    super.initState();
    adminController.fetchAdminProjects();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'متاح';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'in_progress':
        return AppTheme.tertiaryColor;
      case 'completed':
        return AppTheme.primaryColor;
      case 'cancelled':
        return AppTheme.dangerColor;
      default:
        return AppTheme.successColor;
    }
  }

  String _semesterLabel(dynamic semester) {
    switch (semester) {
      case 'first':
        return 'الفصل الأول';
      case 'second':
        return 'الفصل الثاني';
      case 'summer':
        return 'الفصل الصيفي';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightColor,
        appBar: AppBar(
          title: const Text('إدارة المشاريع'),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.onSurface,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: adminController.fetchAdminProjects,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStatusFilter(),
            Expanded(
              child: Obx(() {
                if (adminController.isLoadingProjects.value &&
                    adminController.adminProjects.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final projects = adminController.adminProjects;
                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined,
                            size: 64,
                            color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('لا توجد مشاريع حالياً',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => adminController.fetchAdminProjects(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: projects.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildProjectCard(projects[index]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final filters = [
      {'value': 'all', 'label': 'الكل'},
      {'value': 'available', 'label': 'متاح'},
      {'value': 'in_progress', 'label': 'قيد التنفيذ'},
      {'value': 'completed', 'label': 'مكتمل'},
      {'value': 'cancelled', 'label': 'ملغي'},
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: filters.map((f) {
                final isActive =
                    adminController.projectsStatusFilter.value == f['value'];
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () =>
                        adminController.setProjectsStatusFilter(f['value']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isActive ? AppTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isActive
                                ? AppTheme.primaryColor
                                : AppTheme.outlineVariant),
                      ),
                      child: Text(
                        f['label']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? Colors.white
                              : AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildProjectCard(dynamic project) {
    final title = project['title'] ?? '';
    final status = (project['status'] ?? 'available').toString();
    final statusColor = _statusColor(status);
    final typeName = project['type']?['name'] ?? project['type']?['label'];
    final academicYear = project['academic_year']?.toString();
    final semester = _semesterLabel(project['semester']);
    final teams = (project['teams'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: AppTheme.onSurfaceVariant),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'available', child: Text('متاح')),
                  const PopupMenuItem(
                      value: 'in_progress', child: Text('قيد التنفيذ')),
                  const PopupMenuItem(value: 'completed', child: Text('مكتمل')),
                  const PopupMenuItem(value: 'cancelled', child: Text('ملغي')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('حذف',
                          style: TextStyle(color: AppTheme.dangerColor))),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    adminController.deleteProject(project['id']);
                  } else {
                    adminController.updateProjectStatus(
                        project['id'], value.toString());
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(_statusLabel(status), statusColor, Icons.flag_outlined),
              if (typeName != null)
                _chip(typeName.toString(), AppTheme.tertiaryColor,
                    Icons.category_outlined),
              if (academicYear != null && academicYear.isNotEmpty)
                _chip(academicYear, AppTheme.secondaryColor,
                    Icons.calendar_today_outlined),
              if (semester.isNotEmpty)
                _chip(semester, AppTheme.secondaryColor,
                    Icons.event_note_outlined),
            ],
          ),
          const SizedBox(height: 12),
          _buildTeamSection(teams),
        ],
      ),
    );
  }

  Widget _buildTeamSection(List teams) {
    if (teams.isEmpty) {
      return Row(
        children: [
          Icon(Icons.groups_outlined, size: 16, color: AppTheme.greyColor),
          const SizedBox(width: 6),
          const Text('لا يوجد فريق يعمل على المشروع',
              style: TextStyle(fontSize: 12.5, color: AppTheme.onSurfaceVariant)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: teams.map<Widget>((team) {
        final teamName = team['name'] ?? 'فريق';
        final members = (team['members'] as List?) ?? [];
        return Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Icon(Icons.groups, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text('$teamName · ${members.length} أعضاء',
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _chip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
