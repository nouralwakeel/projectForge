import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../config/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController controller = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>();

  final fullNameCtrl = TextEditingController();
  final studNumCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordConfirmCtrl = TextEditingController();
  final dobDisplayCtrl = TextEditingController();

  String? selectedGender;
  DateTime? selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    controller.selectedMajor.value = null;
    if (controller.majors.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadMajors());
    }
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    studNumCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    passwordConfirmCtrl.dispose();
    dobDisplayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightColor,
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
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceContainerHighest),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 30,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    return IntrinsicHeight(
                      child: Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        children: [
                          Expanded(
                            flex: isWide ? 1 : 0,
                            child: Container(
                              width: isWide ? null : double.infinity,
                              padding: EdgeInsets.all(isWide ? 48 : 24),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ProjectForge',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.02,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'إنشاء حساب جديد',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'انضم إلينا لبدء رحلتك الأكاديمية.',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildLabel('الاسم الكامل'),
                                    const SizedBox(height: 4),
                                    _buildTextField(
                                      controller: fullNameCtrl,
                                      hint: 'أحمد المحمد',
                                      icon: Icons.person_outline,
                                      validator: (v) =>
                                          v!.isEmpty ? 'مطلوب' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLabel('الرقم الجامعي'),
                                    const SizedBox(height: 4),
                                    _buildTextField(
                                      controller: studNumCtrl,
                                      hint: '20210001',
                                      icon: Icons.badge_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          v!.isEmpty ? 'مطلوب' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLabel('الجنس'),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      initialValue: selectedGender,
                                      decoration: _inputDecoration(
                                        hint: 'اختر الجنس',
                                        icon: Icons.person_outline,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'male',
                                          child: Text('ذكر'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'female',
                                          child: Text('أنثى'),
                                        ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => selectedGender = v),
                                      validator: (_) =>
                                          selectedGender == null
                                              ? 'مطلوب'
                                              : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLabel('تاريخ الميلاد'),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () async {
                                        final now = DateTime.now();
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime(now.year - 22, now.month, now.day),
                                          firstDate: DateTime(now.year - 60),
                                          lastDate: DateTime(now.year - 16),
                                          locale: const Locale('ar'),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            selectedDateOfBirth = picked;
                                            dobDisplayCtrl.text =
                                                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                          });
                                        }
                                      },
                                      child: AbsorbPointer(
                                        child: TextFormField(
                                          controller: dobDisplayCtrl,
                                          decoration: _inputDecoration(
                                            hint: '2000-01-01',
                                            icon: Icons.cake_outlined,
                                          ),
                                          validator: (_) =>
                                              selectedDateOfBirth == null
                                                  ? 'مطلوب'
                                                  : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLabel('التخصص الجامعي'),
                                    const SizedBox(height: 4),
                                    Obx(() {
                                      final items = controller.majors
                                          .map((m) => DropdownMenuItem<int>(
                                                value: m.id,
                                                child: Text(m.name),
                                              ))
                                          .toList();
                                      return DropdownButtonFormField<int>(
                                        initialValue: controller.selectedMajor.value,
                                        decoration: _inputDecoration(
                                          hint: 'هندسة البرمجيات',
                                          icon: Icons.school_outlined,
                                        ),
                                        items: items,
                                        onChanged: items.isEmpty
                                            ? null
                                            : (v) =>
                                                controller.selectedMajor.value =
                                                    v,
                                        validator: (_) =>
                                            controller.selectedMajor.value ==
                                                    null
                                                ? 'مطلوب'
                                                : null,
                                      );
                                    }),
                                    const SizedBox(height: 16),
                                    _buildLabel('البريد الإلكتروني'),
                                    const SizedBox(height: 4),
                                    _buildTextField(
                                      controller: emailCtrl,
                                      hint: 'student@university.edu',
                                      icon: Icons.mail_outline,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) =>
                                          v!.isEmpty ? 'مطلوب' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLabel('كلمة المرور'),
                                    const SizedBox(height: 4),
                                    _buildTextField(
                                      controller: passwordCtrl,
                                      hint: '••••••••',
                                      icon: Icons.lock_outline,
                                      obscure: true,
                                      validator: (v) => v!.length < 8
                                          ? '8 أحرف على الأقل'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLabel('تأكيد كلمة المرور'),
                                    const SizedBox(height: 4),
                                    _buildTextField(
                                      controller: passwordConfirmCtrl,
                                      hint: '••••••••',
                                      icon: Icons.lock,
                                      obscure: true,
                                      validator: (v) =>
                                          v != passwordCtrl.text
                                              ? 'غير متطابق'
                                              : null,
                                    ),
                                    const SizedBox(height: 24),
                                    Obx(() => Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: controller.isLoading.value
                                                ? AppTheme.primaryColor
                                                    .withValues(alpha: 0.6)
                                                : AppTheme.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x806D0047),
                                                offset: Offset(0, 2),
                                                blurRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              onTap: controller.isLoading.value
                                                  ? null
                                                  : () {
                                                      if (formKey.currentState!
                                                          .validate()) {
                                                        final nameParts =
                                                            fullNameCtrl.text
                                                                .trim()
                                                                .split(' ');
                                                        final dob =
                                                            selectedDateOfBirth;
                                                        controller.register({
                                                          'first_name':
                                                              nameParts.first,
                                                          'last_name':
                                                              nameParts.length >
                                                                      1
                                                                  ? nameParts
                                                                      .sublist(
                                                                          1)
                                                                      .join(' ')
                                                                  : '',
                                                          'email':
                                                              emailCtrl.text,
                                                          'password':
                                                              passwordCtrl.text,
                                                          'password_confirmation':
                                                              passwordConfirmCtrl
                                                                  .text,
                                                          'stud_num':
                                                              studNumCtrl.text,
                                                          'gender':
                                                              selectedGender,
                                                          'date_of_birth': dob !=
                                                                  null
                                                              ? '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}'
                                                              : '',
                                                          'major_id': controller
                                                              .selectedMajor
                                                              .value,
                                                        });
                                                      }
                                                    },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: Center(
                                                  child: controller
                                                          .isLoading.value
                                                      ? const SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color:
                                                                Colors.white,
                                                          ),
                                                        )
                                                      : Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              'إنشاء حساب',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppTheme
                                                                    .onPrimary,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Icon(
                                                              Icons.arrow_back,
                                                              size: 18,
                                                              color: AppTheme
                                                                  .onPrimary,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'لديك حساب بالفعل؟ ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppTheme.onSurfaceVariant,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              Get.toNamed(AppRoutes.login),
                                          child: Text(
                                            'تسجيل الدخول',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isWide)
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Color(0xCCF472B6),
                                      Color(0x66C084FC),
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: AppTheme.surfaceContainerHigh,
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            Color(0xCCF472B6),
                                            Color(0x66C084FC),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 10,
                                            sigmaY: 10,
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.all(48),
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.auto_awesome,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'نظم أفكارك',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'بيئة مثالية لإدارة مشاريعك الجامعية بكفاءة وإبداع.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
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
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppTheme.outlineColor),
      prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 22),
      filled: true,
      fillColor: AppTheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.surfaceContainerHighest),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.surfaceContainerHighest),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.secondaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(hint: hint, icon: icon),
    );
  }
}
