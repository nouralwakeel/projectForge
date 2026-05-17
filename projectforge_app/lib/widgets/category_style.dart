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
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Programming Languages',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.code,
    ),
    'Backend': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Backend',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.dns,
    ),
    'Databases': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Databases',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.storage,
    ),
    'AI/ML': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'AI/ML',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.psychology,
    ),
    'Tools': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Tools',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.build,
    ),
    'Cloud': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Cloud',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.cloud,
    ),
    'Design': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Design',
      useSideBySideLayout: false,
      useSkillGrid: false,
      icon: Icons.palette,
    ),
    'Cybersecurity': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Cybersecurity',
      useSideBySideLayout: true,
      useSkillGrid: false,
      icon: Icons.security,
    ),
    'IoT': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
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
