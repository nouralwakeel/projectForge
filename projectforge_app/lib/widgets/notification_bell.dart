import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_theme.dart';
import '../controllers/notification_controller.dart';
import '../app/routes/app_routes.dart';

/// Bell icon with an unread-count badge. Shares a single NotificationController
/// so the badge is consistent wherever it appears.
class NotificationBell extends StatelessWidget {
  final Color? color;
  const NotificationBell({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController(), permanent: true);
    final iconColor = color ?? AppTheme.primaryColor;

    return Obx(() {
      final count = c.unreadCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () {
              c.fetchUnreadCount();
              Get.toNamed(AppRoutes.notifications);
            },
            icon: Icon(Icons.notifications, color: iconColor),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(shape: const CircleBorder()),
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: const BoxDecoration(
                  color: AppTheme.dangerColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
        ],
      );
    });
  }
}
