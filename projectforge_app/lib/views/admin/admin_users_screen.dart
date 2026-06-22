import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  List<dynamic> users = [];
  bool isLoading = true;
  String selectedRole = 'all';
  bool showArchived = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final params = <String, dynamic>{};
      if (selectedRole != 'all') params['role'] = selectedRole;
      if (showArchived) params['archived'] = 1;
      final response =
          await _apiService.get(ApiConfig.adminUsers, queryParameters: params);
      if (response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          users = data is List ? data : (data['data'] ?? []);
        });
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل المستخدمين');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> archiveUser(int userId, String userName) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الأرشفة'),
        content: Text(
            'سيتم أرشفة حساب "$userName" (لن يتمكن من تسجيل الدخول). يمكنك استعادته لاحقاً. هل تريد المتابعة؟'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('أرشفة', style: TextStyle(color: AppTheme.dangerColor)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _apiService.delete('${ApiConfig.adminUsers}/$userId');
      Get.snackbar('نجاح', 'تمت أرشفة الحساب بنجاح');
      fetchUsers();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في أرشفة الحساب');
    }
  }

  Future<void> restoreUser(int userId, String userName) async {
    try {
      await _apiService.put(ApiConfig.adminUserRestore(userId));
      Get.snackbar('نجاح', 'تمت استعادة الحساب بنجاح');
      fetchUsers();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في استعادة الحساب');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightColor,
        appBar: AppBar(
          title: Text(showArchived ? 'الحسابات المؤرشفة' : 'إدارة المستخدمين'),
          actions: [
            IconButton(
              tooltip: showArchived ? 'الحسابات النشطة' : 'الحسابات المؤرشفة',
              onPressed: () {
                setState(() => showArchived = !showArchived);
                fetchUsers();
              },
              icon: Icon(showArchived ? Icons.people_alt_outlined : Icons.archive_outlined),
            ),
            IconButton(
              onPressed: fetchUsers,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildRoleFilter(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : users.isEmpty
                      ? const Center(child: Text('لا يوجد مستخدمين'))
                      : RefreshIndicator(
                          onRefresh: fetchUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: users.length,
                            itemBuilder: (context, index) => _buildUserCard(users[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilter() {
    final roles = [
      {'value': 'all', 'label': 'الكل'},
      {'value': 'student', 'label': 'طلاب'},
      {'value': 'advisor', 'label': 'مشرفين'},
      {'value': 'admin', 'label': 'مديرين'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: roles.map((role) {
            final isActive = selectedRole == role['value'];
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedRole = role['value']!);
                  fetchUsers();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? AppTheme.primaryColor : AppTheme.outlineVariant),
                  ),
                  child: Text(
                    role['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    final name = user['name'] ?? '';
    final email = user['email'] ?? '';
    final role = user['role'] ?? 'student';
    final roleLabel = role == 'admin' ? 'مدير' : role == 'advisor' ? 'مشرف' : 'طالب';
    final roleColor = role == 'admin'
        ? AppTheme.dangerColor
        : role == 'advisor'
            ? AppTheme.tertiaryColor
            : AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: roleColor.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.person, size: 22, color: roleColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? email : name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(roleLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: roleColor)),
          ),
          if (role != 'admin') ...[
            const SizedBox(width: 8),
            showArchived
                ? IconButton(
                    tooltip: 'استعادة',
                    onPressed: () =>
                        restoreUser(user['id'], name.isEmpty ? email : name),
                    icon: const Icon(Icons.restore, size: 20, color: AppTheme.successColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : IconButton(
                    tooltip: 'أرشفة',
                    onPressed: () =>
                        archiveUser(user['id'], name.isEmpty ? email : name),
                    icon: const Icon(Icons.archive_outlined, size: 20, color: AppTheme.dangerColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
          ],
        ],
      ),
    );
  }
}