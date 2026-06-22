import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../app/routes/app_routes.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_FeatureItem> _features = const [
    _FeatureItem(
      icon: Icons.school_outlined,
      title: 'إدارة مشاريع التخرج',
      color: AppTheme.primaryColor,
    ),
    _FeatureItem(
      icon: Icons.people_alt_outlined,
      title: 'تقييم المهارات والتوافق',
      color: AppTheme.tertiaryColor,
    ),
    _FeatureItem(
      icon: Icons.analytics_outlined,
      title: 'تقدير نسبة النجاح',
      color: AppTheme.secondaryColor,
    ),
    _FeatureItem(
      icon: Icons.groups_outlined,
      title: 'إدارة الفرق والمشاريع',
      color: AppTheme.successColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    'تخطي',
                    style: TextStyle(fontSize: 16, color: AppTheme.greyColor),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.04),
                      SvgPicture.asset(
                        'assets/ico_slide.svg',
                        width: 280,
                        height: 100,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ProjectForge',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'نظرة عامة — كيف نساعدك؟',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'نظام متكامل يساعد الطلاب والمشرفين والإداريين على تنظيم وإدارة مشاريع التخرج بكفاءة عالية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      ...List.generate(_features.length, (index) {
                        final feature = _features[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: feature.color.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: feature.color.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color:
                                        feature.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    feature.icon,
                                    size: 28,
                                    color: feature.color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    feature.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: feature.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _goToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'ابدأ الآن',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.color,
  });
}
