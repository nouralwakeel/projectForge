import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AdminSkillsScreen extends StatefulWidget {
  const AdminSkillsScreen({super.key});

  @override
  State<AdminSkillsScreen> createState() => _AdminSkillsScreenState();
}

class _AdminSkillsScreenState extends State<AdminSkillsScreen> {
  final ApiService _api = Get.find<ApiService>();
  List<dynamic> skills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.get(ApiConfig.skills);
      if (res.data['success'] == true) {
        setState(() => skills = res.data['data'] is List ? res.data['data'] : (res.data['data']['data'] ?? []));
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _deleteSkill(int id) async {
    try {
      await _api.delete('${ApiConfig.skills}/$id');
      setState(() => skills.removeWhere((s) => s['id'] == id));
      Get.snackbar('نجاح', 'تم حذف المهارة بنجاح', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف المهارة', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة مهارة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المهارة')),
              const SizedBox(height: 12),
              TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'التصنيف')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _api.post(ApiConfig.skills, data: {'name': nameCtrl.text, 'category': categoryCtrl.text});
                  Navigator.pop(ctx);
                  _loadSkills();
                  Get.snackbar('نجاح', 'تم إضافة المهارة بنجاح', snackPosition: SnackPosition.BOTTOM);
                } catch (e) {
                  Get.snackbar('خطأ', 'فشل في إضافة المهارة', snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightColor,
        appBar: AppBar(
          title: const Text('إدارة المهارات'),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : skills.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.psychology_outlined, size: 64, color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('لا توجد مهارات', style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSkills,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: skills.length,
                      itemBuilder: (context, index) {
                        final skill = skills[index];
                        final category = skill['category'] ?? '';
                        final catColor = category == 'technical'
                            ? AppTheme.primaryColor
                            : category == 'soft'
                                ? AppTheme.tertiaryColor
                                : AppTheme.secondaryColor;
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
                                  color: catColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.psychology_outlined, size: 20, color: catColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(skill['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                                    const SizedBox(height: 2),
                                    Text(category, style: TextStyle(fontSize: 12, color: catColor)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: AppTheme.dangerColor.withValues(alpha: 0.7)),
                                onPressed: () => _deleteSkill(skill['id']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}