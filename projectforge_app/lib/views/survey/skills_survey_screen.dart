import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/skill_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/category_style.dart';
import '../../widgets/category_section.dart';
import '../../widgets/skill_card.dart';

class SkillsSurveyScreen extends StatelessWidget {
  const SkillsSurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SkillController>();

    return Scaffold(
      backgroundColor: AppTheme.lightColor,
      appBar: AppBar(
        title: const Text('استبيان المهارات'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.skills.isEmpty) {
          return const Center(child: Text('لا توجد مهارات متاحة'));
        }
        return Column(
          children: [
            _buildStepHeader(controller),
            Expanded(
              child: _buildStepBody(controller),
            ),
            _buildStepFooter(controller),
          ],
        );
      }),
    );
  }

  Widget _buildStepHeader(SkillController controller) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          Text(
            SkillController.stepTitles[controller.currentStep.value],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            SkillController.stepSubtitles[controller.currentStep.value],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressBars(controller),
        ],
      ),
    );
  }

  Widget _buildProgressBars(SkillController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(SkillController.stepCategories.length, (index) {
        final isActive = index <= controller.currentStep.value;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 64,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepBody(SkillController controller) {
    final categories = controller.categoriesForCurrentStep();
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: categories.map((category) {
        final categorySkills = controller.skillsByCategory(category);
        if (categorySkills.isEmpty) return const SizedBox.shrink();
        final style = CategoryStyle.map[category];
        if (style == null) return const SizedBox.shrink();
        return CategorySection(
          title: category,
          categoryStyle: style,
          children: categorySkills.map((skill) {
            return Obx(() {
              final proficiency =
                  controller.selectedProficiency[skill.id] ?? 1;
              final interest = controller.selectedInterest[skill.id] ?? 1;
              return SkillCard(
                skillName: skill.name,
                proficiency: proficiency,
                interest: interest,
                onProficiencyChanged: (v) =>
                    controller.setProficiency(skill.id, v),
                onInterestChanged: (v) =>
                    controller.setInterest(skill.id, v),
                categoryStyle: style,
              );
            });
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildStepFooter(SkillController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          if (controller.currentStep.value > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.previousStep(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppTheme.primaryColor),
                ),
                child: const Text(
                  'السابق',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ),
          if (controller.currentStep.value > 0)
            const SizedBox(width: 12),
          Expanded(
            child: Obx(() {
              if (controller.isLastStep) {
                return _buildSubmitButton(controller);
              }
              return ElevatedButton(
                onPressed: () => controller.nextStep(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('التالي'),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(SkillController controller) {
    return Obx(() => GestureDetector(
      onTap: controller.isSaving.value ? null : () => controller.saveSkills(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
        decoration: BoxDecoration(
          color: controller.isSaving.value
              ? AppTheme.primaryColor.withValues(alpha: 0.6)
              : AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            bottom: BorderSide(
              color: AppTheme.onPrimaryFixedVariant,
              width: 2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.39),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.isSaving.value)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            else ...[
              const Text(
                'إرسال الاستبيان',
                style: TextStyle(
                  color: AppTheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.send,
                color: AppTheme.onPrimary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    ));
  }
}
