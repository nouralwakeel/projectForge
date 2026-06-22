import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AdminMajorsScreen extends StatefulWidget {
  const AdminMajorsScreen({super.key});

  @override
  State<AdminMajorsScreen> createState() => _AdminMajorsScreenState();
}

class _AdminMajorsScreenState extends State<AdminMajorsScreen> {
  final ApiService _api = Get.find<ApiService>();
  List<dynamic> majors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMajors();
  }

  Future<void> _loadMajors() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.get(ApiConfig.majors);
      if (res.data['success'] == true) {
        setState(() => majors = res.data['data'] is List ? res.data['data'] : (res.data['data']['data'] ?? []));
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _deleteMajor(int id) async {
    try {
      await _api.delete('${ApiConfig.majors}/$id');
      setState(() => majors.removeWhere((m) => m['id'] == id));
      Get.snackbar('نجاح', 'تم حذف التخصص بنجاح', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف التخصص', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة تخصص جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم التخصص')),
              const SizedBox(height: 12),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'رمز التخصص')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(ctx);
                try {
                  await _api.post(ApiConfig.majors, data: {'name': nameCtrl.text, 'code': codeCtrl.text});
                  nav.pop();
                  _loadMajors();
                  Get.snackbar('نجاح', 'تم إضافة التخصص بنجاح', snackPosition: SnackPosition.BOTTOM);
                } catch (e) {
                  Get.snackbar('خطأ', 'فشل في إضافة التخصص', snackPosition: SnackPosition.BOTTOM);
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
          title: const Text('إدارة التخصصات'),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : majors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 64, color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('لا توجد تخصصات', style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadMajors,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: majors.length,
                      itemBuilder: (context, index) {
                        final major = majors[index];
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
                                  color: AppTheme.successColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.school_outlined, size: 20, color: AppTheme.successColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(major['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                                    const SizedBox(height: 2),
                                    Text(major['code'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: AppTheme.dangerColor.withValues(alpha: 0.7)),
                                onPressed: () => _deleteMajor(major['id']),
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