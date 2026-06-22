import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../../app/routes/app_routes.dart';
import '../../config/api_config.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ApiService _api = Get.find<ApiService>();

  final emailCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  int step = 1; // 1 = request OTP, 2 = verify + reset
  bool isLoading = false;
  bool obscure = true;
  String? error;

  @override
  void dispose() {
    emailCtrl.dispose();
    otpCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  String? _serverMessage(Object e) {
    if (e is DioException && e.response?.data is Map) {
      return e.response?.data['message']?.toString();
    }
    return null;
  }

  Future<void> _requestOtp() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => error = 'أدخل البريد الإلكتروني');
      return;
    }
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final res = await _api.post(ApiConfig.passwordForgot, data: {'email': email});
      final devOtp = res.data['data']?['dev_otp']?.toString();
      if (devOtp != null && devOtp.isNotEmpty) {
        otpCtrl.text = devOtp;
        Get.snackbar('وضع التطوير', 'رمز التحقق: $devOtp',
            duration: const Duration(seconds: 6));
      } else {
        Get.snackbar('تم', 'إذا كان البريد مسجّلاً فستصلك رسالة بالرمز');
      }
      setState(() => step = 2);
    } catch (e) {
      setState(() => error = _serverMessage(e) ?? 'تعذّر إرسال الرمز. حاول لاحقاً.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final otp = otpCtrl.text.trim();
    final password = passwordCtrl.text;
    final confirm = confirmCtrl.text;

    if (otp.isEmpty) {
      setState(() => error = 'أدخل رمز التحقق');
      return;
    }
    if (password.length < 8) {
      setState(() => error = 'كلمة المرور يجب ألا تقل عن 8 أحرف');
      return;
    }
    if (password != confirm) {
      setState(() => error = 'كلمتا المرور غير متطابقتين');
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      await _api.post(ApiConfig.passwordReset, data: {
        'email': emailCtrl.text.trim(),
        'otp': otp,
        'password': password,
        'password_confirmation': confirm,
      });
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar('تم', 'تم تحديث كلمة المرور. سجّل الدخول الآن');
    } catch (e) {
      setState(() => error = _serverMessage(e) ?? 'تعذّر تعيين كلمة المرور.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppTheme.primaryColor,
          title: const Text('استرجاع كلمة المرور',
              style: TextStyle(color: AppTheme.onSurface, fontSize: 18)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: step == 1 ? _buildStepEmail() : _buildStepReset(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.lock_reset, size: 48, color: AppTheme.primaryColor),
        const SizedBox(height: 12),
        const Text('أدخل بريدك الإلكتروني',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
        const SizedBox(height: 6),
        const Text('سنرسل لك رمز تحقق لإعادة تعيين كلمة المرور',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          decoration: _decoration('user@university.edu', Icons.mail_outline),
        ),
        if (error != null) _errorText(),
        const SizedBox(height: 16),
        _primaryButton('إرسال الرمز', _requestOtp),
      ],
    );
  }

  Widget _buildStepReset() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.verified_user_outlined, size: 48, color: AppTheme.primaryColor),
        const SizedBox(height: 12),
        const Text('أدخل الرمز وكلمة المرور الجديدة',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
        const SizedBox(height: 6),
        Text('تم إرسال الرمز إلى ${emailCtrl.text.trim()}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        TextField(
          controller: otpCtrl,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          maxLength: 6,
          decoration: _decoration('رمز التحقق (6 أرقام)', Icons.pin_outlined),
        ),
        TextField(
          controller: passwordCtrl,
          obscureText: obscure,
          textDirection: TextDirection.ltr,
          decoration: _decoration('كلمة المرور الجديدة', Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.primaryColor, size: 20),
                onPressed: () => setState(() => obscure = !obscure),
              )),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmCtrl,
          obscureText: obscure,
          textDirection: TextDirection.ltr,
          decoration: _decoration('تأكيد كلمة المرور', Icons.lock_outline),
        ),
        if (error != null) _errorText(),
        const SizedBox(height: 16),
        _primaryButton('تعيين كلمة المرور', _resetPassword),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isLoading ? null : _requestOtp,
          child: const Text('إعادة إرسال الرمز'),
        ),
      ],
    );
  }

  Widget _errorText() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(error!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppTheme.dangerColor)),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.greyColor, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppTheme.lightColor,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.outlineVariant),
      ),
    );
  }
}
