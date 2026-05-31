import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/advisor_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';

class AdvisorTeamRequestsScreen extends StatelessWidget {
  const AdvisorTeamRequestsScreen({super.key});

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
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_forward, color: AppTheme.primaryColor, size: 22),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'طلبات الإشراف',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                        ),
                      ),
                    ),
                    const Spacer(),
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
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterBarDelegate(controller: controller),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: Obx(() {
                if (controller.isLoadingRequests.value && controller.teamRequests.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.teamRequests.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_off, size: 64, color: AppTheme.greyColor),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد طلبات ${_filterLabel(controller.requestsFilter.value)}',
                            style: const TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final team = controller.teamRequests[index];
                      return _TeamRequestCard(
                        team: team,
                        onApprove: () => controller.approveTeam(team['id']),
                        onReject: () => controller.rejectTeam(team['id']),
                        isPending: controller.requestsFilter.value == 'pending',
                      );
                    },
                    childCount: controller.teamRequests.length,
                  ),
                );
              }),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Get.offAllNamed(AppRoutes.advisorDashboard);
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
              icon: Icon(Icons.group_add_outlined),
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

  String _filterLabel(String filter) {
    switch (filter) {
      case 'pending':
        return 'معلقة';
      case 'approved':
        return 'مقبولة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return '';
    }
  }
}

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final AdvisorDashboardController controller;

  _FilterBarDelegate({required this.controller});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white.withValues(alpha: 0.95),
      child: Obx(() {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _FilterChip(
                label: 'معلق',
                isSelected: controller.requestsFilter.value == 'pending',
                color: AppTheme.warningColor,
                onTap: () => controller.setRequestsFilter('pending'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'مقبول',
                isSelected: controller.requestsFilter.value == 'approved',
                color: AppTheme.successColor,
                onTap: () => controller.setRequestsFilter('approved'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'مرفوض',
                isSelected: controller.requestsFilter.value == 'rejected',
                color: AppTheme.dangerColor,
                onTap: () => controller.setRequestsFilter('rejected'),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  double get maxExtent => 52;

  @override
  double get minExtent => 52;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppTheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TeamRequestCard extends StatelessWidget {
  final dynamic team;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isPending;

  const _TeamRequestCard({
    required this.team,
    required this.onApprove,
    required this.onReject,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final teamName = team['name'] ?? '';
    final projectName = team['project']?['title'] ?? '';
    final supervisorStatus = team['supervisor_status'] ?? 'pending';
    final members = team['members'] as List? ?? [];

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (supervisorStatus) {
      case 'approved':
        statusColor = AppTheme.successColor;
        statusLabel = 'مقبول';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppTheme.dangerColor;
        statusLabel = 'مرفوض';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.warningColor;
        statusLabel = 'معلق';
        statusIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.group, size: 22, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.assignment, size: 13, color: AppTheme.greyColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              projectName,
                              style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (members.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الأعضاء (${members.length})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: members.map<Widget>((member) {
                      final studentName = member['student']?['full_name'] ?? 'طالب';
                      final role = member['role_in_team'] ?? 'member';
                      final isLeader = role == 'leader';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (isLeader ? AppTheme.primaryColor : AppTheme.greyColor).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isLeader ? AppTheme.primaryColor : AppTheme.greyColor).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLeader ? Icons.star : Icons.person,
                              size: 13,
                              color: isLeader ? AppTheme.primaryColor : AppTheme.greyColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              studentName,
                              style: TextStyle(
                                fontSize: 12,
                                color: isLeader ? AppTheme.primaryColor : AppTheme.onSurfaceVariant,
                                fontWeight: isLeader ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          if (isPending)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('قبول'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('رفض'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.dangerColor,
                        side: const BorderSide(color: AppTheme.dangerColor),
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
