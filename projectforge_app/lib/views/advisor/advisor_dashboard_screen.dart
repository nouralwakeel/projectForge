import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/advisor_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';

class AdvisorDashboardScreen extends StatelessWidget {
  const AdvisorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdvisorDashboardController());
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
                          'لوحة تحكم المشرف',
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
                        IconButton(
                          onPressed: () => Get.toNamed(AppRoutes.profile),
                          icon: Icon(Icons.person_outline, color: AppTheme.primaryColor, size: 20),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(shape: const CircleBorder()),
                        ),
                        PopupMenuButton(
                          icon: Icon(Icons.more_vert, color: AppTheme.primaryColor, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'logout', child: Text('تسجيل الخروج')),
                          ],
                          onSelected: (v) {
                            if (v == 'logout') authController.logout();
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
                if (controller.isLoading.value && controller.stats.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.stats.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('فشل في تحميل البيانات'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchDashboardData(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildListDelegate([
                    _AdvisorWelcomeHeader(),
                    const SizedBox(height: 24),
                    _AdvisorStatsGrid(stats: controller.stats),
                    const SizedBox(height: 32),
                    _PendingRequestsCard(controller: controller),
                    const SizedBox(height: 32),
                    _SupervisedProjectsSection(controller: controller),
                    const SizedBox(height: 100),
                  ]),
                );
              }),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 1) {
              Get.toNamed(AppRoutes.advisorTeamRequests);
            } else if (index == 2) {
              Get.toNamed(AppRoutes.profile);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.group_add_outlined),
                  Obx(() {
                    final count = controller.stats['pending_requests_count'] ?? 0;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              activeIcon: Icon(Icons.group_add),
              label: 'طلبات الفرق',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'الملف الشخصي',
            ),
          ],
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.greyColor,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 8,
        ),
      ),
    );
  }
}

class _AdvisorWelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppTheme.tertiaryColor,
              AppTheme.tertiaryColor.withValues(alpha: 0.85),
              AppTheme.primaryColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.tertiaryColor.withValues(alpha: 0.3),
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
                  child: const Icon(Icons.school, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'إدارة المشاريع والفرق المشرف عليها',
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
  }
}

class _AdvisorStatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _AdvisorStatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final cards = [
          _StatCard(
            icon: Icons.assignment,
            label: 'المشاريع',
            value: '${stats['projects_count'] ?? 0}',
            color: AppTheme.tertiaryColor,
          ),
          _StatCard(
            icon: Icons.groups,
            label: 'الفرق',
            value: '${stats['teams_count'] ?? 0}',
            color: AppTheme.primaryColor,
          ),
          _StatCard(
            icon: Icons.pending_actions,
            label: 'طلبات معلقة',
            value: '${stats['pending_requests_count'] ?? 0}',
            color: AppTheme.warningColor,
          ),
          _StatCard(
            icon: Icons.check_circle,
            label: 'مكتملة',
            value: '${(stats['status_counts'] as Map?)?['completed'] ?? 0}',
            color: AppTheme.successColor,
          ),
        ];
        if (isWide) {
          return Row(
            children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList(),
          );
        }
        return Column(
          children: [
            Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
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

class _PendingRequestsCard extends StatelessWidget {
  final AdvisorDashboardController controller;
  const _PendingRequestsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.stats['pending_requests_count'] ?? 0;
      if (count == 0) return const SizedBox.shrink();
      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.advisorTeamRequests),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.warningColor.withValues(alpha: 0.15),
                AppTheme.warningColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.notifications_active, color: AppTheme.warningColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count طلبات فرق معلقة',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'اضغط لعرض والتعامل مع الطلبات',
                      style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios, size: 16, color: AppTheme.warningColor),
            ],
          ),
        ),
      );
    });
  }
}

class _SupervisedProjectsSection extends StatelessWidget {
  final AdvisorDashboardController controller;
  const _SupervisedProjectsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final projects = controller.projects;
      if (projects.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المشاريع المشرف عليها',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Icon(Icons.assignment_outlined, size: 48, color: AppTheme.greyColor),
                  const SizedBox(height: 12),
                  const Text(
                    'لا توجد مشاريع مشرف عليها حالياً',
                    style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المشاريع المشرف عليها (${projects.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
          ),
          const SizedBox(height: 16),
          ...projects.map((project) => _AdvisorProjectCard(project: project)),
        ],
      );
    });
  }
}

class _AdvisorProjectCard extends StatelessWidget {
  final dynamic project;
  const _AdvisorProjectCard({required this.project});

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return AppTheme.successColor;
      case 'in_progress':
        return AppTheme.tertiaryColor;
      case 'completed':
        return AppTheme.primaryColor;
      case 'cancelled':
        return AppTheme.dangerColor;
      default:
        return AppTheme.greyColor;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return 'متاح';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = project['title'] ?? '';
    final status = project['status'] ?? 'available';
    final difficultyLevel = project['difficulty_level'] ?? 1;
    final teams = project['teams'] as List? ?? [];
    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_alt, size: 14, color: AppTheme.greyColor),
                    const SizedBox(width: 4),
                    Text(
                      'مستوى الصعوبة: $difficultyLevel',
                      style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.groups, size: 14, color: AppTheme.greyColor),
                    const SizedBox(width: 4),
                    Text(
                      '${teams.length} فريق',
                      style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (teams.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الفرق:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  ...teams.map((team) {
                    final teamName = team['name'] ?? '';
                    final supervisorStatus = team['supervisor_status'] ?? 'pending';
                    final members = team['members'] as List? ?? [];

                    Color badgeColor;
                    String badgeLabel;
                    if (supervisorStatus == 'approved') {
                      badgeColor = AppTheme.successColor;
                      badgeLabel = 'مقبول';
                    } else if (supervisorStatus == 'rejected') {
                      badgeColor = AppTheme.dangerColor;
                      badgeLabel = 'مرفوض';
                    } else {
                      badgeColor = AppTheme.warningColor;
                      badgeLabel = 'معلق';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.group, size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teamName,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                                ),
                                Text(
                                  '${members.length} عضو',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
