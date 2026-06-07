import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class CategoryStyle {
  final Color barColor;
  final Color profInactiveBorder;
  final Color profActiveBg;
  final Color profActiveText;
  final String englishTitle;
  final IconData icon;

  const CategoryStyle({
    required this.barColor,
    required this.profInactiveBorder,
    required this.profActiveBg,
    required this.profActiveText,
    required this.englishTitle,
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
      icon: Icons.web,
    ),
    'Programming Languages': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Programming Languages',
      icon: Icons.code,
    ),
    'Backend': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Backend',
      icon: Icons.dns,
    ),
    'Databases': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Databases',
      icon: Icons.storage,
    ),
    'AI/ML': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'AI/ML',
      icon: Icons.psychology,
    ),
    'Tools': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Tools',
      icon: Icons.build,
    ),
    'Cloud': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Cloud',
      icon: Icons.cloud,
    ),
    'Design': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Design',
      icon: Icons.palette,
    ),
    'Cybersecurity': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Cybersecurity',
      icon: Icons.security,
    ),
    'IoT': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'IoT',
      icon: Icons.electrical_services,
    ),
    'Soft Skills': CategoryStyle(
      barColor: AppTheme.primaryColor,
      profInactiveBorder: AppTheme.primaryContainer,
      profActiveBg: AppTheme.primaryColor,
      profActiveText: AppTheme.onPrimary,
      englishTitle: 'Soft Skills',
      icon: Icons.groups,
    ),
  };
}
