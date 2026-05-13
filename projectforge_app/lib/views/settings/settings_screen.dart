import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildSectionTitle('إعدادات الاتصال بالخادم'),
            const SizedBox(height: 12),
            _buildConfigCard(controller),
            const SizedBox(height: 24),
            _buildSectionTitle('اختبار الاتصال'),
            const SizedBox(height: 12),
            _buildTestApiCard(controller),
            const SizedBox(height: 16),
            _buildTestDbCard(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        textAlign: TextAlign.end,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildConfigCard(SettingsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildLabel('عنوان IP الخاص بالخادم'),
          const SizedBox(height: 6),
          TextField(
            controller: controller.ipController,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.url,
            decoration: _inputDecoration(
              hint: '10.0.2.2',
              icon: Icons.dns_outlined,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabel('رقم المنفذ'),
          const SizedBox(height: 6),
          TextField(
            controller: controller.portController,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
              hint: '8000',
              icon: Icons.settings_ethernet_outlined,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.saveSettings,
              icon: const Icon(Icons.save_outlined),
              label: const Text('حفظ الإعدادات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestApiCard(SettingsController controller) {
    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.api_outlined,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'اختبار الاتصال مع API',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        Text(
                          'يتصل بـ /api/v1/majors',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (controller.apiTestResult.value != null) ...[
                const SizedBox(height: 12),
                _buildResultBanner(
                  controller.apiTestSuccess.value,
                  controller.apiTestResult.value!,
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.isTestingApi.value
                      ? null
                      : controller.testApiConnection,
                  icon: controller.isTestingApi.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: Text(
                    controller.isTestingApi.value
                        ? 'جاري الاختبار...'
                        : 'اختبار API',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildTestDbCard(SettingsController controller) {
    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.tertiaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storage_outlined,
                      color: AppTheme.tertiaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'اختبار الاتصال مع قاعدة البيانات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        Text(
                          'يتصل بـ /api/v1/health/db',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (controller.dbTestResult.value != null) ...[
                const SizedBox(height: 12),
                _buildResultBanner(
                  controller.dbTestSuccess.value,
                  controller.dbTestResult.value!,
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.isTestingDb.value
                      ? null
                      : controller.testDbConnection,
                  icon: controller.isTestingDb.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.storage),
                  label: Text(
                    controller.isTestingDb.value
                        ? 'جاري الاختبار...'
                        : 'اختبار قاعدة البيانات',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.tertiaryColor,
                    side: const BorderSide(color: AppTheme.tertiaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildResultBanner(bool success, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success
            ? AppTheme.successColor.withValues(alpha: 0.1)
            : AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: success
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.error_outline,
            color: success ? AppTheme.successColor : AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: success ? AppTheme.successColor : AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.onSurface,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.outlineColor),
      prefixIcon: Icon(icon, color: AppTheme.outlineColor, size: 22),
      filled: true,
      fillColor: AppTheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }
}
