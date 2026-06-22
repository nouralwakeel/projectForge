import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxList<NotificationModel> items = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await _api.get(ApiConfig.notificationsUnreadCount);
      if (res.data['success'] == true) {
        unreadCount.value = (res.data['data']?['unread_count'] ?? 0) as int;
      }
    } catch (_) {
      // Non-fatal: badge simply won't update this cycle.
    }
  }

  Future<void> fetch() async {
    isLoading.value = true;
    try {
      final res = await _api.get(ApiConfig.notifications);
      if (res.data['success'] == true) {
        final data = res.data['data'];
        final list = (data['notifications'] ?? []) as List;
        items.value = list.map((e) => NotificationModel.fromJson(e)).toList();
        unreadCount.value = (data['unread_count'] ?? 0) as int;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل الإشعارات');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(NotificationModel n) async {
    if (n.isRead) return;
    try {
      await _api.put(ApiConfig.notificationRead(n.id));
      n.readAt = DateTime.now();
      items.refresh();
      if (unreadCount.value > 0) unreadCount.value--;
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.put(ApiConfig.notificationsReadAll);
      final now = DateTime.now();
      for (final n in items) {
        n.readAt ??= now;
      }
      items.refresh();
      unreadCount.value = 0;
    } catch (_) {
      Get.snackbar('خطأ', 'فشل في تحديث الإشعارات');
    }
  }
}
