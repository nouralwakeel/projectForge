import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late List<AnimationController> _floatControllers;
  late List<Animation<double>> _floatAnimations;

  late AnimationController _staggerController;
  late List<Animation<double>> _staggerAnimations;

  final List<_FloatingIcon> _icons = const [
    _FloatingIcon(icon: Icons.school, color: AppTheme.primaryColor, size: 64),
    _FloatingIcon(icon: Icons.code, color: AppTheme.tertiaryColor, size: 44),
    _FloatingIcon(
        icon: Icons.lightbulb_outline, color: AppTheme.secondaryColor, size: 44),
    _FloatingIcon(
        icon: Icons.psychology, color: Color(0xFF00BCD4), size: 44),
    _FloatingIcon(
        icon: Icons.rocket_launch, color: AppTheme.primaryColor, size: 44),
  ];

  late List<Offset> _iconPositions;

  @override
  void initState() {
    super.initState();
    _iconPositions = [
      Offset(0, 0),
      Offset(-0.6, -0.5),
      Offset(0.6, -0.4),
      Offset(-0.5, 0.5),
      Offset(0.55, 0.45),
    ];

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController, curve: Curves.easeIn),
    );

    _floatControllers = List.generate(_icons.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 3500 + i * 400),
      )..repeat(reverse: true);
    });
    _floatAnimations = _floatControllers.map((c) {
      return Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _staggerAnimations = List.generate(_icons.length, (i) {
      final start = 0.1 + (i * 0.12);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, start + 0.3, curve: Curves.easeOutBack),
        ),
      );
    }).toList();

    _logoController.forward();
    _staggerController.forward();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    try {
      final authService = Get.find<AuthService>();
      await authService.checkLogin().timeout(const Duration(seconds: 5));
      if (authService.isLoggedIn.value) {
        final user = authService.currentUser.value;
        if (user != null && user.role == 'admin') {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else if (user != null && user.role == 'advisor') {
          Get.offAllNamed(AppRoutes.advisorDashboard);
        } else if (user != null &&
            user.skills != null &&
            user.skills!.isNotEmpty) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.survey);
        }
      } else {
        Get.offAllNamed(AppRoutes.intro);
      }
    } catch (e) {
      debugPrint('Splash error: $e');
      Get.offAllNamed(AppRoutes.intro);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    for (final c in _floatControllers) {
      c.dispose();
    }
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height * 0.38;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppTheme.lightColor,
              AppTheme.surfaceContainer,
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildDecorativeBlurs(size),
            ...List.generate(_icons.length, (i) {
              return _buildFloatingIcon(i, centerX, centerY);
            }),
            _buildCenterLogo(centerX, centerY),
            _buildBottomText(size),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeBlurs(Size size) {
    return Stack(
      children: [
        Positioned(
          top: size.height * 0.12,
          right: size.width * 0.1,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.2,
          left: size.width * 0.05,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00BCD4).withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.45,
          left: size.width * 0.4,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryColor.withValues(alpha: 0.06),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingIcon(int index, double cx, double cy) {
    final icon = _icons[index];
    final pos = _iconPositions[index];
    final floatRange = 14.0 + index * 2.0;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_floatAnimations[index], _staggerAnimations[index]]),
      builder: (context, child) {
        final stagger = _staggerAnimations[index].value;
        final floatVal = _floatAnimations[index].value;

        final dx = cx + pos.dx * 100 - icon.size / 2;
        final dy =
            cy + pos.dy * 100 - icon.size / 2 + (floatVal * floatRange);

        return Positioned(
          left: dx,
          top: dy,
          child: Opacity(
            opacity: stagger.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: stagger.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: icon.color.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: icon.color.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(
          icon.icon,
          size: icon.size * 0.55,
          color: icon.color,
        ),
      ),
    );
  }

  Widget _buildCenterLogo(double cx, double cy) {
    return Positioned(
      left: cx - 50,
      top: cy - 50,
      child: AnimatedBuilder(
        animation: _logoController,
        builder: (context, child) {
          return Opacity(
            opacity: _logoOpacity.value,
            child: Transform.scale(
              scale: _logoScale.value,
              child: child,
            ),
          );
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/ico.svg',
              width: 70,
              height: 70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomText(Size size) {
    return Positioned(
      bottom: size.height * 0.12,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _logoController,
        builder: (context, child) {
          return Opacity(
            opacity: _logoOpacity.value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ProjectForge',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'منصة إدارة مشاريع التخرج الذكية',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.darkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingIcon {
  final IconData icon;
  final Color color;
  final double size;

  const _FloatingIcon({
    required this.icon,
    required this.color,
    required this.size,
  });
}
