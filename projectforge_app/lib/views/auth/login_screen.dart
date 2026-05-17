import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../config/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.find<AuthController>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => Get.toNamed(AppRoutes.settings),
        backgroundColor: AppTheme.surfaceContainerLowest,
        foregroundColor: AppTheme.primaryColor,
        elevation: 2,
        child: const Icon(Icons.settings_outlined),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Stack(
                    children: [
                  Positioned(
                    top: -48,
                    right: -48,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -48,
                    left: -48,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.secondaryContainer.withValues(alpha: 0.2),
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width < 400 ? 24 : 48,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outlineVariant),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ProjectForge',
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'مرحباً بك مجدداً',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'سجل دخولك لمتابعة مشاريعك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('البريد الإلكتروني'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          decoration: _inputDecoration(
                            hint: 'user@university.edu',
                            icon: Icons.mail_outline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('كلمة المرور'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: passwordCtrl,
                          obscureText: obscurePassword,
                          textDirection: TextDirection.ltr,
                          decoration: _inputDecoration(
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.primaryColor,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            'هل نسيت كلمة المرور؟',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.tertiaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => controller.errorMessage.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  controller.errorMessage.value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),
                        const SizedBox(height: 12),
                        Obx(() => Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: controller.isLoading.value
                                    ? AppTheme.primaryColor.withValues(alpha: 0.6)
                                    : AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                                border: const Border(
                                  bottom: BorderSide(
                                    color: AppTheme.onPrimaryContainer,
                                    width: 2,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: controller.isLoading.value ? 0.2 : 0.39),
                                    blurRadius: controller.isLoading.value ? 10 : 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: controller.isLoading.value
                                      ? null
                                      : () => controller.login(
                                          emailCtrl.text.trim(),
                                          passwordCtrl.text),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: controller.isLoading.value
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'تسجيل الدخول',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.onPrimary,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.login,
                                                  size: 24,
                                                  color: AppTheme.onPrimary,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ليس لديك حساب؟ ',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.register),
                              child: Text(
                                'تسجيل حساب جديد',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.secondaryColor,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppTheme.secondaryColor,
                                  decorationThickness: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                 ],
                ),
              ),
            ),
          ),
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
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppTheme.outlineColor),
      prefixIcon: Icon(icon, color: AppTheme.outlineColor, size: 22),
      suffixIcon: suffixIcon,
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
        borderSide: BorderSide(color: AppTheme.secondaryColor, width: 2),
      ),
    );
  }
}
