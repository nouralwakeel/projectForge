import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController controller = Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.fetch());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: AppTheme.primaryColor,
          title: const Text('الإشعارات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
          actions: [
            Obx(() => controller.unreadCount.value > 0
                ? TextButton(
                    onPressed: controller.markAllAsRead,
                    child: const Text('تعليم الكل كمقروء'),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('لا توجد إشعارات',
                      style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => controller.fetch(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _tile(controller.items[i]),
            ),
          );
        }),
      ),
    );
  }

  Widget _tile(NotificationModel n) {
    final (icon, color) = _styleFor(n.type);
    return GestureDetector(
      onTap: () => controller.markAsRead(n),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: n.isRead
                ? AppTheme.outlineVariant.withValues(alpha: 0.4)
                : AppTheme.primaryColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (n.body != null && n.body!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      n.body!,
                      style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(n.createdAt),
                    style: TextStyle(fontSize: 11.5, color: AppTheme.greyColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _styleFor(String type) {
    switch (type) {
      case 'team_approved':
        return (Icons.check_circle, AppTheme.successColor);
      case 'team_rejected':
        return (Icons.cancel, AppTheme.dangerColor);
      case 'team_request':
        return (Icons.group_add, AppTheme.tertiaryColor);
      default:
        return (Icons.notifications, AppTheme.primaryColor);
    }
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 30) return 'منذ ${diff.inDays} يوم';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
