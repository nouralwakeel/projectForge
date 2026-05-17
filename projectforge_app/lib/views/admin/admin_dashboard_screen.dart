import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.put(AdminDashboardController());
    final authController = Get.find<AuthController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              backgroundColor: Colors.white.withValues(alpha: 0.85),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
              titleSpacing: 0,
              leadingWidth: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      'ProForge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'لوحة التحكم',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => Get.toNamed(AppRoutes.settings),
                          icon: Icon(Icons.settings_outlined, color: AppTheme.primaryColor, size: 20),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(shape: const CircleBorder()),
                        ),
                        PopupMenuButton(
                          icon: Icon(Icons.person, color: AppTheme.primaryColor, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'profile', child: Text('الملف الشخصي')),
                            const PopupMenuItem(value: 'logout', child: Text('تسجيل الخروج')),
                          ],
                          onSelected: (v) {
                            if (v == 'logout') authController.logout();
                            if (v == 'profile') Get.toNamed(AppRoutes.profile);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              sliver: Obx(() {
                if (adminController.isLoading.value && adminController.stats.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (adminController.stats.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('فشل في تحميل البيانات'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => adminController.fetchDashboardData(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildListDelegate([
                    _WelcomeHeader(),
                    const SizedBox(height: 24),
                    _StatsGrid(stats: adminController.stats),
                    const SizedBox(height: 32),
                    _QuickActionsSection(adminController: adminController),
                    const SizedBox(height: 32),
                    _RecentUsersSection(adminController: adminController),
                    const SizedBox(height: 32),
                    _RecentProjectsSection(adminController: adminController),
                    const SizedBox(height: 100),
                  ]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Obx(() {
      final user = authController.isLoggedIn.value
          ? 'مدير النظام'
          : '';
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: 0.85),
              AppTheme.tertiaryColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user,
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'مرحباً بك في لوحة التحكم',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.people,
                label: 'الطلاب',
                value: '${stats['students_count'] ?? 0}',
                color: AppTheme.primaryColor,
              )),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(
                icon: Icons.assignment,
                label: 'المشاريع',
                value: '${stats['projects_count'] ?? 0}',
                color: AppTheme.tertiaryColor,
              )),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(
                icon: Icons.groups,
                label: 'الفرق',
                value: '${stats['teams_count'] ?? 0}',
                color: AppTheme.secondaryColor,
              )),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(
                icon: Icons.school,
                label: 'التخصصات',
                value: '${stats['majors_count'] ?? 0}',
                color: AppTheme.successColor,
              )),
            ],
          );
        }
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: (constraints.maxWidth - 12) / 2,
              child: _StatCard(
                icon: Icons.people,
                label: 'الطلاب',
                value: '${stats['students_count'] ?? 0}',
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 12) / 2,
              child: _StatCard(
                icon: Icons.assignment,
                label: 'المشاريع',
                value: '${stats['projects_count'] ?? 0}',
                color: AppTheme.tertiaryColor,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 12) / 2,
              child: _StatCard(
                icon: Icons.groups,
                label: 'الفرق',
                value: '${stats['teams_count'] ?? 0}',
                color: AppTheme.secondaryColor,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 12) / 2,
              child: _StatCard(
                icon: Icons.school,
                label: 'التخصصات',
                value: '${stats['majors_count'] ?? 0}',
                color: AppTheme.successColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final AdminDashboardController adminController;
  const _QuickActionsSection({required this.adminController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إجراءات سريعة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final actions = [
              _ActionCard(
                icon: Icons.person_add,
                label: 'إدارة المستخدمين',
                subtitle: 'عرض وإدارة حسابات الطلاب',
                color: AppTheme.primaryColor,
                onTap: () => adminController.navigateToUsers(),
              ),
              _ActionCard(
                icon: Icons.assignment_outlined,
                label: 'إدارة المشاريع',
                subtitle: 'إنشاء وتعديل وحذف المشاريع',
                color: AppTheme.tertiaryColor,
                onTap: () => adminController.navigateToProjects(),
              ),
              _ActionCard(
                icon: Icons.school_outlined,
                label: 'إدارة التخصصات',
                subtitle: 'إضافة وتعديل التخصصات',
                color: AppTheme.successColor,
                onTap: () => adminController.navigateToMajors(),
              ),
              _ActionCard(
                icon: Icons.psychology_outlined,
                label: 'إدارة المهارات',
                subtitle: 'إضافة وتعديل المهارات',
                color: AppTheme.secondaryColor,
                onTap: () => adminController.navigateToSkills(),
              ),
            ];
            if (isWide) {
              return Row(
                children: actions.map((a) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: a))).toList(),
              );
            }
            return Column(
              children: [
                Row(children: [Expanded(child: actions[0]), const SizedBox(width: 12), Expanded(child: actions[1])]),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: actions[2]), const SizedBox(width: 12), Expanded(child: actions[3])]),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(fontSize: 11, height: 1.3, color: AppTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _RecentUsersSection extends StatelessWidget {
  final AdminDashboardController adminController;
  const _RecentUsersSection({required this.adminController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final users = adminController.recentUsers;
      if (users.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'آخر المستخدمين',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
              ),
              TextButton(
                onPressed: () => adminController.navigateToUsers(),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...users.take(5).map((user) => _UserTile(user: user)),
        ],
      );
    });
  }
}

class _UserTile extends StatelessWidget {
  final dynamic user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['name'] ?? '';
    final email = user['email'] ?? '';
    final role = user['role'] ?? 'student';
    final roleColor = role == 'admin'
        ? AppTheme.dangerColor
        : role == 'advisor'
            ? AppTheme.tertiaryColor
            : AppTheme.primaryColor;
    final roleLabel = role == 'admin'
        ? 'مدير'
        : role == 'advisor'
            ? 'مشرف'
            : 'طالب';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: roleColor.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.person, size: 20, color: roleColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              roleLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: roleColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentProjectsSection extends StatelessWidget {
  final AdminDashboardController adminController;
  const _RecentProjectsSection({required this.adminController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final projects = adminController.recentProjects;
      if (projects.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'آخر المشاريع',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
              ),
              TextButton(
                onPressed: () => adminController.navigateToProjects(),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...projects.take(5).map((project) => _ProjectTile(project: project)),
        ],
      );
    });
  }
}

class _ProjectTile extends StatelessWidget {
  final dynamic project;
  const _ProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.assignment, size: 20, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(statusLabel, style: TextStyle(fontSize: 12, color: statusColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}