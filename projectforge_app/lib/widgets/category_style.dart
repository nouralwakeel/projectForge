import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class CategoryStyle {
  final Color barColor;
  final Color profInactiveBorder;
  final Color profActiveBg;
  final Color profActiveText;
  final String englishTitle;
  final bool useSideBySideLayout;
  final bool useSkillGrid;
  final IconData icon;

  const CategoryStyle({
    required this.barColor,
    required this.profInactiveBorder,
    required this.profActiveBg,
    required this.profActiveText,
    required this.englishTitle,
    required this.useSideBySideLayout,
    required this.useSkillGrid,
    required this.icon,
  });

  Color get iconBgColor => barColor.withValues(alpha: 0.2);

  static const Map<String, CategoryStyle> map = {
    'Frontend': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Frontend',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.web,
    ),
    'Programming Languages': CategoryStyle(
      barColor: AppTheme.tertiaryColor,
      profInactiveBorder: AppTheme.tertiaryContainer,
      profActiveBg: AppTheme.tertiaryColor,
      profActiveText: Colors.white,
      englishTitle: 'Programming Languages',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.code,
    ),
    'Backend': CategoryStyle(
      barColor: AppTheme.onPrimaryFixedVariant,
      profInactiveBorder: AppTheme.primaryFixed,
      profActiveBg: AppTheme.onPrimaryFixedVariant,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Backend',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.dns,
    ),
    'Databases': CategoryStyle(
      barColor: AppTheme.surfaceContainerHighest,
      profInactiveBorder: AppTheme.surfaceContainerHighest,
      profActiveBg: AppTheme.surfaceDim,
      profActiveText: AppTheme.onSurface,
      englishTitle: 'Databases',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.storage,
    ),
    'AI/ML': CategoryStyle(
      barColor: AppTheme.tertiaryFixedDim,
      profInactiveBorder: AppTheme.tertiaryFixed,
      profActiveBg: AppTheme.tertiaryColor,
      profActiveText: Colors.white,
      englishTitle: 'AI/ML',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.psychology,
    ),
    'Tools': CategoryStyle(
      barColor: AppTheme.secondaryFixedDim,
      profInactiveBorder: AppTheme.secondaryContainer,
      profActiveBg: AppTheme.secondaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Tools',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.build,
    ),
    'Cloud': CategoryStyle(
      barColor: AppTheme.surfaceContainerHigh,
      profInactiveBorder: AppTheme.surfaceContainerHigh,
      profActiveBg: AppTheme.surfaceDim,
      profActiveText: AppTheme.onSurface,
      englishTitle: 'Cloud',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.cloud,
    ),
    'Design': CategoryStyle(
      barColor: AppTheme.primaryFixedDim,
      profInactiveBorder: AppTheme.primaryFixed,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Design',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.palette,
    ),
    'Cybersecurity': CategoryStyle(
      barColor: AppTheme.tertiaryColor,
      profInactiveBorder: AppTheme.tertiaryContainer,
      profActiveBg: AppTheme.tertiaryColor,
      profActiveText: Colors.white,
      englishTitle: 'Cybersecurity',
      useSideBySideLayout: true,
      useSkillGrid: false,
      icon: Icons.security,
    ),
    'IoT': CategoryStyle(
      barColor: AppTheme.surfaceContainerHighest,
      profInactiveBorder: AppTheme.surfaceContainerHighest,
      profActiveBg: AppTheme.surfaceDim,
      profActiveText: AppTheme.onSurface,
      englishTitle: 'IoT',
      useSideBySideLayout: true,
      useSkillGrid: false,
      icon: Icons.electrical_services,
    ),
    'Soft Skills': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Soft Skills',
      useSideBySideLayout: false,
      useSkillGrid: true,
      icon: Icons.groups,
    ),
  };
}
