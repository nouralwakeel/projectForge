import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/estimation_controller.dart';
import '../../config/app_theme.dart';
import '../../models/success_estimation_model.dart';
import '../../widgets/success_gauge.dart';
import '../../app/routes/app_routes.dart';

class SuccessEstimatorScreen extends StatelessWidget {
  const SuccessEstimatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EstimationController>();
    final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.estimation.value == null && !controller.isLoading.value) {
        controller.estimateProject(id);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        if (controller.error.value.isNotEmpty) {
          return _buildErrorState(controller, id);
        }
        final est = controller.estimation.value;
        if (est == null) {
          return const Center(child: Text('لا توجد بيانات'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBreadcrumb(),
              const SizedBox(height: 24),
              _buildBentoGrid(context, est),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'PF',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'ProjectForge',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.02,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Get.toNamed(AppRoutes.settings),
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.grey[400]),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryContainer,
            child: Text(
              'م',
              style: TextStyle(color: AppTheme.onPrimaryContainer, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(EstimationController controller, int id) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
          const SizedBox(height: 12),
          Text(controller.error.value, style: TextStyle(color: AppTheme.errorColor, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.estimateProject(id),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_open, size: 18, color: AppTheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              'تقدير فرص النجاح',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_left, size: 14, color: AppTheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              'مقدر النجاح',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'تقدير فرص النجاح',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: AppTheme.onSurface, height: 1.2),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Text(
            'تحليل مبني على البيانات لتشكيلة فريقك، المهارات المتوفرة، وتعقيد المشروع لضمان تسليم سلس.',
            style: TextStyle(fontSize: 16, height: 1.6, color: AppTheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context, SuccessEstimationModel est) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return Column(
          children: [
            if (isWide)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 8, child: _buildGaugeCard(est)),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: _buildInsightCard(est)),
                  ],
                ),
              )
            else ...[
              _buildGaugeCard(est),
              const SizedBox(height: 16),
              _buildInsightCard(est),
            ],
            const SizedBox(height: 16),
            if (isWide)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 6, child: _buildFactorsCard(est.factors)),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _buildTeamBalanceCard(est.teamSize),
                          const SizedBox(height: 16),
                          _buildDifficultyCard(est.difficultyLevel),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _buildFactorsCard(est.factors),
              const SizedBox(height: 16),
              _buildTeamBalanceCard(est.teamSize),
              const SizedBox(height: 16),
              _buildDifficultyCard(est.difficultyLevel),
            ],
          ],
        );
      },
    );
  }

  Widget _buildGaugeCard(SuccessEstimationModel est) {
    final rating = _getRating(est.successProbability);
    return _buildTactileCard(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryContainer.withValues(alpha: 0.2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الاحتمالية الإجمالية',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSurface, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getGaugeDescription(est.successProbability),
                      style: TextStyle(fontSize: 16, height: 1.6, color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        border: Border.all(color: AppTheme.surfaceContainerHighest),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, size: 18, color: AppTheme.secondaryColor),
                          const SizedBox(width: 8),
                          Text('تصنيف: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
                          Text(
                            rating.label,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: rating.color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              SuccessGauge(percentage: est.successProbability),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(SuccessEstimationModel est) {
    final insight = _getWeakestInsight(est.factors);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer,
        border: Border.all(color: AppTheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceContainerLowest,
                ),
                child: Icon(Icons.warning, color: AppTheme.secondaryColor, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                'نقطة ضعف محتملة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSecondaryContainer, height: 1.4),
              ),
              const SizedBox(height: 4),
              Text(
                insight.description,
                style: TextStyle(fontSize: 14, height: 1.5, color: AppTheme.onSecondaryContainer.withValues(alpha: 0.9)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.surfaceContainerLowest,
                foregroundColor: AppTheme.onSurface,
                side: BorderSide(color: AppTheme.outlineVariant, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              child: const Text('عرض التفاصيل'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsCard(EstimationFactors factors) {
    final combined = ((factors.skillCoverage + factors.teamBalance + factors.difficultyFactor) / 3).toStringAsFixed(0);
    return _buildTactileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.tertiaryColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'تغطية العوامل المؤثرة',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSurface, height: 1.4),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$combined% مجتمعة',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFactorBar('تغطية المهارات', factors.skillCoverage, AppTheme.primaryColor),
          const SizedBox(height: 16),
          _buildFactorBar('توازن الفريق', factors.teamBalance, AppTheme.tertiaryColor),
          const SizedBox(height: 16),
          _buildFactorBar('عامل التعقيد', factors.difficultyFactor, AppTheme.secondaryColor),
        ],
      ),
    );
  }

  Widget _buildFactorBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppTheme.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamBalanceCard(int? teamSize) {
    final size = teamSize ?? 3;
    final displayCount = size.clamp(1, 5);
    return _buildTactileCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'توازن الفريق',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSurface, height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  'توزيع جيد للأدوار القيادية والتقنية.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant, height: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildStackedAvatars(displayCount),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars(int count) {
    const colors = [
      AppTheme.primaryColor,
      AppTheme.tertiaryColor,
      AppTheme.secondaryColor,
      AppTheme.successColor,
      AppTheme.primaryContainer,
    ];
    return SizedBox(
      height: 48,
      width: 48.0 + (count - 1) * 16.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = count - 1; i >= 0; i--)
            Positioned(
              right: i * 16.0,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[i % colors.length],
                  border: Border.all(color: AppTheme.surfaceContainerLowest, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(int difficultyLevel) {
    final level = difficultyLevel.clamp(1, 5);
    final info = _getDifficultyInfo(level);
    return _buildTactileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مستوى التعقيد',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.onSurface, height: 1.4),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 16, color: AppTheme.errorColor),
                    const SizedBox(width: 4),
                    Text(
                      info.label,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: info.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(tag, style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTactileCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border.all(color: AppTheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  _RatingInfo _getRating(double probability) {
    if (probability >= 80) return _RatingInfo('مشروع واعد', AppTheme.tertiaryColor);
    if (probability >= 50) return _RatingInfo('مشروع قابل للتحسين', AppTheme.secondaryColor);
    return _RatingInfo('يحتاج مراجعة', AppTheme.errorColor);
  }

  String _getGaugeDescription(double probability) {
    if (probability >= 80) {
      return 'بناءً على التكوين الحالي، يمتلك مشروعك فرصة ممتازة للنجاح والتسليم في الوقت المحدد.';
    }
    if (probability >= 50) {
      return 'مشروعك لديه فرصة معقولة للنجاح مع بعض التحسينات المطلوبة في الفريق والمهارات.';
    }
    return 'مشروعك يحتاج إلى تحسينات جوهرية في تشكيلة الفريق أو المهارات لزيادة فرص النجاح.';
  }

  _InsightInfo _getWeakestInsight(EstimationFactors factors) {
    final entries = [
      _FactorEntry('تغطية المهارات', factors.skillCoverage, 'التوافق في مهارات التطوير أقل من المطلوب للمرحلة الحالية.'),
      _FactorEntry('توازن الفريق', factors.teamBalance, 'التوزيع في أدوار الفريق غير متوازن بشكل كافٍ لتحمل أعباء المشروع.'),
      _FactorEntry('عامل التعقيد', factors.difficultyFactor, 'مستوى تعقيد المشروع يضغط على الموارد المتاحة وقد يؤثر على الجدول الزمني.'),
    ];
    entries.sort((a, b) => a.value.compareTo(b.value));
    return _InsightInfo(entries.first.name, entries.first.description);
  }

  _DifficultyInfo _getDifficultyInfo(int level) {
    const labels = {1: 'منخفض', 2: 'منخفض - متوسط', 3: 'متوسط', 4: 'متوسط - مرتفع', 5: 'مرتفع'};
    List<String> tags;
    if (level <= 2) {
      tags = ['تصميم بسيط', 'واجهات أساسية'];
    } else if (level == 3) {
      tags = ['ربط واجهات API', 'مصادقة المستخدمين', 'زمن استجابة حرج'];
    } else if (level == 4) {
      tags = ['تكامل أنظمة متعددة', 'أمان متقدم', 'أداء حرج'];
    } else {
      tags = ['بنية تحتية معقدة', 'أمان متقدم', 'أداء حرج', 'تكامل أنظمة'];
    }
    return _DifficultyInfo(labels[level] ?? 'متوسط', tags);
  }
}

class _RatingInfo {
  final String label;
  final Color color;
  const _RatingInfo(this.label, this.color);
}

class _InsightInfo {
  final String factorName;
  final String description;
  const _InsightInfo(this.factorName, this.description);
}

class _FactorEntry {
  final String name;
  final double value;
  final String description;
  const _FactorEntry(this.name, this.value, this.description);
}

class _DifficultyInfo {
  final String label;
  final List<String> tags;
  const _DifficultyInfo(this.label, this.tags);
}
