import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'category_style.dart';
import 'skill_rating_buttons.dart';

class SkillCard extends StatelessWidget {
  final String skillName;
  final int proficiency;
  final int interest;
  final ValueChanged<int> onProficiencyChanged;
  final ValueChanged<int> onInterestChanged;
  final CategoryStyle categoryStyle;

  const SkillCard({
    super.key,
    required this.skillName,
    required this.proficiency,
    required this.interest,
    required this.onProficiencyChanged,
    required this.onInterestChanged,
    required this.categoryStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skillName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (categoryStyle.useSideBySideLayout)
            _buildSideBySideLayout()
          else
            _buildStackedLayout(),
        ],
      ),
    );
  }

  Widget _buildSideBySideLayout() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildProficiencySection()),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: AppTheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(child: _buildInterestSection()),
        ],
      ),
    );
  }

  Widget _buildStackedLayout() {
    return Column(
      children: [
        _buildProficiencySection(),
        const SizedBox(height: 12),
        _buildInterestSection(),
      ],
    );
  }

  Widget _buildProficiencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مستوى المهارة',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        SkillRatingButtons(
          value: proficiency,
          onChanged: onProficiencyChanged,
          inactiveBorderColor: categoryStyle.profInactiveBorder,
          activeBgColor: categoryStyle.profActiveBg,
          activeTextColor: categoryStyle.profActiveText,
        ),
      ],
    );
  }

  Widget _buildInterestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الاهتمام',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        SkillRatingButtons(
          value: interest,
          onChanged: onInterestChanged,
          inactiveBorderColor: AppTheme.secondaryContainer,
          activeBgColor: AppTheme.secondaryFixed,
          activeTextColor: AppTheme.onSecondaryFixed,
        ),
      ],
    );
  }
}
