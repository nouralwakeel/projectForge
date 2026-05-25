import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/team_controller.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _OverviewPage();
      case 1:
        return const _TeamsDiscoveryPage();
      case 2:
        return _buildPlaceholderPage(Icons.biotech, 'المختبر');
      case 3:
        return const _ProfileTab();
      default:
        return const _OverviewPage();
    }
  }

  Widget _buildPlaceholderPage(IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.primaryColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 18, color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      _NavItem('الرئيسية', Icons.dashboard),
      _NavItem('المطابقة', Icons.groups),
      _NavItem('المختبر', Icons.biotech),
      _NavItem('الملف', Icons.person),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = _currentIndex == i;
              final item = items[i];
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryColor.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isActive ? AppTheme.primaryColor : Colors.grey,
                        size: 24,
                        fill: isActive ? 1.0 : 0.0,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isActive ? AppTheme.primaryColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  _NavItem(this.label, this.icon);
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _HeroSection(),
                const SizedBox(height: 48),
                const _HowWeHelpSection(),
                const SizedBox(height: 48),
                const _BenefitsSection(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      titleSpacing: 0,
      leadingWidth: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'ProjectForge',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                  letterSpacing: -0.02,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Text(
              'نظرة عامة',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                  icon: Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications, color: AppTheme.primaryColor),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: AppTheme.surfaceContainerHigh,
                      child: const Icon(Icons.person, size: 18, color: AppTheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamsDiscoveryPage extends StatefulWidget {
  const _TeamsDiscoveryPage();

  @override
  State<_TeamsDiscoveryPage> createState() => _TeamsDiscoveryPageState();
}

class _TeamsDiscoveryPageState extends State<_TeamsDiscoveryPage> {
  int _selectedFilter = 0;
  final _filters = ['الكل', 'الذكاء الاصطناعي', 'تطوير الويب', 'تطبيقات الجوال'];

  final _mockSkillDemand = [
    {'name': 'Flutter', 'percentage': 0.8, 'color': AppTheme.primaryColor},
    {'name': 'UI/UX Design', 'percentage': 0.5, 'color': AppTheme.tertiaryColor},
    {'name': 'Firebase', 'percentage': 0.3, 'color': AppTheme.secondaryColor},
  ];

  final _mockTopTeam = {
    'name': 'فريق أنظمة ذكية',
    'match': 95,
    'description': 'نطور نظام توصيات ذكي يعتمد على الذكاء الاصطناعي لتوصية المشاريع المناسبة للطلاب.',
    'skills': ['Flutter', 'Python', 'ML', 'Firebase'],
    'members': 3,
  };

  final _teamColors = [
    AppTheme.primaryColor,
    AppTheme.tertiaryColor,
    AppTheme.secondaryColor,
    AppTheme.successColor,
    AppTheme.tertiaryContainer,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeamController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            titleSpacing: 0,
            leadingWidth: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'ProjectForge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                        letterSpacing: -0.02,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    'المطابقة',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.settings),
                        icon: Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(shape: const CircleBorder()),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications, color: AppTheme.primaryColor),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(shape: const CircleBorder()),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.outlineVariant),
                        ),
                        child: ClipOval(
                          child: Container(
                            color: AppTheme.surfaceContainerHigh,
                            child: const Icon(Icons.person, size: 18, color: AppTheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 32),
                _buildBentoGrid(controller),
                const SizedBox(height: 40),
                _buildSuggestedTeamsSection(controller),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.3, color: AppTheme.onSurface),
            children: [
              TextSpan(text: 'اكتشف فريقك '),
              TextSpan(text: 'المثالي', style: TextStyle(color: AppTheme.primaryColor)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'استكشف الفرق التي تبحث عن مهاراتك وانضم إلى المشروع الأنسب لك.',
          style: TextStyle(fontSize: 15, height: 1.6, color: AppTheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppTheme.primaryColor : AppTheme.outlineVariant,
                ),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBentoGrid(TeamController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildFeaturedTeamCard()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildSkillDemandCard()),
            ],
          );
        }
        return Column(
          children: [
            _buildFeaturedTeamCard(),
            const SizedBox(height: 16),
            _buildSkillDemandCard(),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedTeamCard() {
    final team = _mockTopTeam;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
            AppTheme.tertiaryColor.withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _RadialGradientPainterHero()),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        team['name'] as String,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildMatchCircle(team['match'] as int),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  team['description'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (team['skills'] as List<String>).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'طلب انضمام',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCircle(int percentage) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillDemandCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.analytics_outlined, size: 20, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              const Text(
                'مهاراتك المطلوبة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._mockSkillDemand.map<Widget>((skill) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Text(
                        skill['name'] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.onSurface),
                      ),
                      Text(
                        '${((skill['percentage'] as double) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: skill['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: skill['percentage'] as double,
                      minHeight: 8,
                      backgroundColor: (skill['color'] as Color).withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(skill['color'] as Color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSuggestedTeamsSection(TeamController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'فرق أخرى مقترحة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
        ),
        const SizedBox(height: 20),
        Obx(() {
          if (controller.isLoading.value && controller.teams.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (controller.teams.isEmpty) {
            return _buildEmptyTeamsState(controller);
          }
          return _buildTeamsGrid(controller);
        }),
      ],
    );
  }

  Widget _buildEmptyTeamsState(TeamController controller) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.groups, size: 48, color: AppTheme.primaryColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'لا توجد فرق متاحة حالياً',
            style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => controller.fetchTeams(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsGrid(TeamController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 550) {
          crossAxisCount = 2;
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: _getCardAspectRatio(crossAxisCount),
          ),
          itemCount: controller.teams.length,
          itemBuilder: (context, index) {
            final team = controller.teams[index];
            return _buildTeamCard(team, index);
          },
        );
      },
    );
  }

  double _getCardAspectRatio(int crossAxisCount) {
    if (crossAxisCount >= 3) return 0.65;
    if (crossAxisCount == 2) return 0.6;
    return 0.55;
  }

  Widget _buildTeamCard(dynamic team, int index) {
    final colorAccent = _teamColors[index % _teamColors.length];
    final matchPercent = 60 + (index * 7) % 35;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: colorAccent),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          team.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.matchColor(matchPercent.toDouble()).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$matchPercent%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.matchColor(matchPercent.toDouble()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      team.project?.description ?? 'فريق مشروع تخرج',
                      style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (team.project?.skills ?? [])
                        .take(3)
                        .map<Widget>((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorAccent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.name,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colorAccent),
                              ),
                            ))
                        .toList(),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMemberAvatars(team.members?.length ?? 0, colorAccent),
                      GestureDetector(
                        onTap: () => Get.toNamed(
                          AppRoutes.teamDetail.replaceAll(':id', '${team.id}'),
                        ),
                        child: Text(
                          'التفاصيل',
                          style: TextStyle(
                            fontSize: 13,
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
        ],
      ),
    );
  }

  Widget _buildMemberAvatars(int count, Color color) {
    final display = count.clamp(1, 5);
    return Row(
      children: List.generate(display, (i) {
        return Transform.translate(
          offset: Offset(-i * 12.0, 0),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1 + (i * 0.05)),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(Icons.person, size: 14, color: color),
          ),
        );
      }),
    );
  }
}

class _RadialGradientPainterHero extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.8, -0.8),
        radius: 0.6,
        colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
      ).createShader(rect);

    final paint2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, 0.8),
        radius: 0.5,
        colors: [Colors.white.withValues(alpha: 0.08), Colors.transparent],
      ).createShader(rect);

    canvas.drawRect(rect, paint1);
    canvas.drawRect(rect, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 30, offset: const Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _RadialGradientPainter()),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: _buildTextContent(context)),
                      const SizedBox(width: 32),
                      Expanded(child: const _FloatingIconsGrid()),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildTextContent(context),
                    const SizedBox(height: 24),
                    const SizedBox(height: 250, child: _FloatingIconsGrid()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: AppTheme.primaryContainer.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rocket_launch, size: 18, color: AppTheme.onPrimaryContainer),
              SizedBox(width: 6),
              Text(
                'منصة ذكية لمشاريع التخرج',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.onPrimaryContainer),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, height: 1.2, color: AppTheme.onSurface),
            children: [
              TextSpan(text: 'اكتشف مشروعك '),
              TextSpan(text: 'المثالي', style: TextStyle(color: AppTheme.primaryColor)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'نقدم لك في ProjectForge بيئة متكاملة تجمع بين التحليل الذكي والتخطيط المتقدم لمساعدتك في اختيار وإدارة مشروع تخرجك بنجاح واحترافية.',
          style: TextStyle(fontSize: 16, height: 1.6, color: AppTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 300;
              return ElevatedButton(
                onPressed: () {
                  try {
                    final auth = Get.find<AuthService>();
                    if (auth.isLoggedIn.value) {
                      Get.toNamed(AppRoutes.dashboard);
                    } else {
                      Get.toNamed(AppRoutes.login);
                    }
                  } catch (_) {
                    Get.toNamed(AppRoutes.login);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.max,
                  children: const [
                    Text('ابدأ الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_back, size: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FloatingIconsGrid extends StatefulWidget {
  const _FloatingIconsGrid();

  @override
  State<_FloatingIconsGrid> createState() => _FloatingIconsGridState();
}

class _FloatingIconsGridState extends State<_FloatingIconsGrid>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  static const _durations = [4000, 5000, 4500, 5500, 4000];
  static const _delays = [0, 1000, 500, 1500, 0];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_durations.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _durations[i]),
      );
    });

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: _delays[i]), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 15,
          right: 15,
          child: _floatingIcon(Icons.code, Colors.purple, 40, 1),
        ),
        Positioned(
          top: 40,
          left: 30,
          child: _floatingIcon(Icons.lightbulb, Colors.yellow.shade700, 40, 2),
        ),
        Positioned(
          bottom: 40,
          right: 60,
          child: _floatingIcon(Icons.psychology, Colors.cyan, 40, 3),
        ),
        Positioned(
          bottom: 15,
          left: 50,
          child: _floatingIcon(Icons.rocket_launch, AppTheme.primaryColor, 40, 4),
        ),
        _floatingIcon(Icons.school, AppTheme.primaryColor, 60, 0, isCenter: true),
        Positioned(
          top: 50,
          right: 80,
          child: Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 80,
          child: Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _floatingIcon(
    IconData icon,
    Color color,
    double iconSize,
    int controllerIndex, {
    bool isCenter = false,
  }) {
    return AnimatedBuilder(
      animation: _controllers[controllerIndex],
      builder: (context, child) {
        final value = _controllers[controllerIndex].value;
        final offset = sin(value * pi * 2) * 15;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.all(isCenter ? 24 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isCenter ? 9999 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}

class _RadialGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.0, -1.0),
        radius: 0.5,
        colors: [AppTheme.primaryContainer.withValues(alpha: 0.2), Colors.transparent],
      ).createShader(rect);

    final paint2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-1.0, 1.0),
        radius: 0.5,
        colors: [AppTheme.tertiaryContainer.withValues(alpha: 0.2), Colors.transparent],
      ).createShader(rect);

    canvas.drawRect(rect, paint1);
    canvas.drawRect(rect, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HowWeHelpSection extends StatelessWidget {
  const _HowWeHelpSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'كيف نساعدك؟',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _FeatureCard(
                        icon: Icons.biotech,
                        iconColor: AppTheme.tertiaryColor,
                        iconBgColor: AppTheme.tertiaryFixed.withValues(alpha: 0.2),
                        accentColor: AppTheme.tertiaryContainer,
                        title: 'تحليل المهارات (Project-DNA)',
                        description: 'نقوم بتحليل مهاراتك واهتماماتك الأكاديمية لتحديد البصمة الفريدة لمشروعك، مما يضمن توافقاً مثالياً مع طموحاتك.',
                      )),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _FeatureCard(
                        icon: Icons.lightbulb,
                        iconColor: AppTheme.secondaryColor,
                        iconBgColor: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                        accentColor: AppTheme.secondaryContainer,
                        title: 'توصيات ذكية',
                        description: 'احصل على اقتراحات لمشاريع مبتكرة مبنية على أحدث التوجهات التقنية ومتطلبات سوق العمل، مع توجيه دقيق لضمان نجاحك.',
                        hasSpinner: true,
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _FeatureCard(
                        icon: Icons.architecture,
                        iconColor: AppTheme.onSurface,
                        iconBgColor: AppTheme.surfaceContainerHighest,
                        accentColor: AppTheme.surfaceContainerHigh,
                        title: 'تخطيط بيئة العمل (Sandbox)',
                        description: 'صمم هيكل مشروعك وجرب أفكارك في بيئة آمنة ومرنة قبل البدء الفعلي، مع أدوات متقدمة لتنظيم المهام والموارد.',
                        hasKanban: true,
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: _FeatureCard(
                        icon: Icons.trending_up,
                        iconColor: AppTheme.primaryColor,
                        iconBgColor: AppTheme.primaryFixed.withValues(alpha: 0.2),
                        accentColor: AppTheme.primaryContainer,
                        title: 'تقدير النجاح',
                        description: 'استخدم نماذجنا التحليلية لتقدير فرص نجاح مشروعك الأكاديمي والعملي، مع تقارير دورية تبرز نقاط القوة ومجالات التحسين.',
                      )),
                    ],
                  ),
                ],
              );
            }
            return Column(
              children: [
                _FeatureCard(
                  icon: Icons.biotech,
                  iconColor: AppTheme.tertiaryColor,
                  iconBgColor: AppTheme.tertiaryFixed.withValues(alpha: 0.2),
                  accentColor: AppTheme.tertiaryContainer,
                  title: 'تحليل المهارات (Project-DNA)',
                  description: 'نقوم بتحليل مهاراتك واهتماماتك الأكاديمية لتحديد البصمة الفريدة لمشروعك، مما يضمن توافقاً مثالياً مع طموحاتك.',
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.lightbulb,
                  iconColor: AppTheme.secondaryColor,
                  iconBgColor: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                  accentColor: AppTheme.secondaryContainer,
                  title: 'توصيات ذكية',
                  description: 'احصل على اقتراحات لمشاريع مبتكرة مبنية على أحدث التوجهات التقنية ومتطلبات سوق العمل، مع توجيه دقيق لضمان نجاحك.',
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.architecture,
                  iconColor: AppTheme.onSurface,
                  iconBgColor: AppTheme.surfaceContainerHighest,
                  accentColor: AppTheme.surfaceContainerHigh,
                  title: 'تخطيط بيئة العمل (Sandbox)',
                  description: 'صمم هيكل مشروعك وجرب أفكارك في بيئة آمنة ومرنة قبل البدء الفعلي، مع أدوات متقدمة لتنظيم المهام والموارد.',
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.trending_up,
                  iconColor: AppTheme.primaryColor,
                  iconBgColor: AppTheme.primaryFixed.withValues(alpha: 0.2),
                  accentColor: AppTheme.primaryContainer,
                  title: 'تقدير النجاح',
                  description: 'استخدم نماذجنا التحليلية لتقدير فرص نجاح مشروعك الأكاديمي والعملي، مع تقارير دورية تبرز نقاط القوة ومجالات التحسين.',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color accentColor;
  final String title;
  final String description;
  final bool hasSpinner;
  final bool hasKanban;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.accentColor,
    required this.title,
    required this.description,
    this.hasSpinner = false,
    this.hasKanban = false,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.02),
              blurRadius: _hovered ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 4, color: widget.accentColor),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transformAlignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(
                            _hovered ? 1.1 : 1.0,
                            _hovered ? 1.1 : 1.0,
                            1.0,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.iconBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(widget.icon, size: 28, color: widget.iconColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (widget.hasSpinner) ...[
                    const SizedBox(width: 24),
                    _buildSpinner(),
                  ],
                  if (widget.hasKanban) ...[
                    const SizedBox(width: 24),
                    _buildKanban(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinner() {
    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _spinController,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryContainer.withValues(alpha: 0.2), width: 4),
              ),
              child: CustomPaint(
                painter: _SpinnerPainter(),
              ),
            ),
          ),
          Icon(Icons.auto_awesome, size: 36, color: AppTheme.secondaryContainer),
        ],
      ),
    );
  }

  Widget _buildKanban() {
    return Container(
      width: 192,
      height: 96,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: const Center(
        child: Icon(Icons.view_kanban, size: 32, color: AppTheme.outlineColor),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: pi * 1.5,
        colors: [AppTheme.secondaryContainer, AppTheme.secondaryContainer.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.drawArc(rect.deflate(2), 0, pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BenefitsSection extends StatelessWidget {
  const _BenefitsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBright,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'الفوائد الرئيسية',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
          ),
          const SizedBox(height: 12),
          const Text(
            'قيمة احترافية وأكاديمية متكاملة تضمن لك تجربة مشروع تخرج استثنائية.',
            style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _BenefitItem(
                icon: Icons.school,
                iconColor: AppTheme.primaryColor,
                iconBgColor: AppTheme.primaryContainer.withValues(alpha: 0.2),
                title: 'تميز أكاديمي',
                description: 'الوصول إلى معايير التقييم الجامعية وضمان توافق مشروعك مع المتطلبات الأكاديمية الصارمة.',
              ),
              _BenefitItem(
                icon: Icons.groups,
                iconColor: AppTheme.tertiaryColor,
                iconBgColor: AppTheme.tertiaryContainer.withValues(alpha: 0.2),
                title: 'تعاون فعال',
                description: 'أدوات مدمجة للتواصل مع فريقك والمشرفين الأكاديميين بسهولة وشفافية.',
              ),
              _BenefitItem(
                icon: Icons.timer,
                iconColor: AppTheme.secondaryColor,
                iconBgColor: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                title: 'إدارة الوقت',
                description: 'تتبع المهام والمواعيد النهائية بدقة لضمان تسليم المشروع في الوقت المحدد دون توتر.',
              ),
              _BenefitItem(
                icon: Icons.work,
                iconColor: AppTheme.onSurface,
                iconBgColor: AppTheme.surfaceContainerHighest,
                title: 'جاهزية لسوق العمل',
                description: 'بناء مشروع تخرج يمثل إضافة قوية لسيرتك الذاتية ويجذب انتباه أصحاب العمل.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.onSurfaceVariant)),
              ],
             ),
           ),
         ],
       ),
     );
   }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final authController = Get.find<AuthController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            titleSpacing: 0,
            leadingWidth: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'ProjectForge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                        letterSpacing: -0.02,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    'الملف الشخصي',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed(AppRoutes.settings),
                    icon: Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(shape: const CircleBorder()),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                final user = authService.currentUser.value;
                if (user == null) {
                  return const Center(child: Text('لا توجد بيانات'));
                }
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                        border: Border.all(color: AppTheme.primaryColor, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          user.fullName[0],
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: user.role == 'advisor'
                            ? AppTheme.tertiaryColor.withValues(alpha: 0.1)
                            : AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role == 'admin'
                            ? 'مدير'
                            : user.role == 'advisor'
                                ? 'مشرف'
                                : 'طالب',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: user.role == 'advisor'
                              ? AppTheme.tertiaryColor
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (user.studentId.isNotEmpty)
                            _profileTile('الرقم الجامعي', user.studentId, Icons.badge),
                          if (user.major != null)
                            _profileTile('التخصص', user.major!.name, Icons.school),
                          if (user.academicLevel != null)
                            _profileTile('المستوى الأكاديمي', '${user.academicLevel}', Icons.stairs),
                          _profileTile('الجنس', user.gender == 'male' ? 'ذكر' : 'أنثى', Icons.person),
                        ],
                      ),
                    ),
                    if (user.skills != null && user.skills!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'المهارات',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                                ),
                                TextButton(
                                  onPressed: () => Get.toNamed(AppRoutes.survey),
                                  child: const Text('تعديل'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: user.skills!.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  '${s.name} (${s.proficiencyLevel}/5)',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primaryColor),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => authController.logout(),
                        icon: const Icon(Icons.logout),
                        label: const Text('تسجيل الخروج'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
