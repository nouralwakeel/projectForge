import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppConstants {
  static const String appName = 'ProjectForge';
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  static const List<String> projectTypes = [
    'mobile_app',
    'web_application',
    'ai_system',
  ];

  static const Map<String, String> projectTypeLabels = {
    'mobile_app': 'تطبيق موبايل',
    'web_application': 'تطبيق ويب',
    'ai_system': 'نظام ذكاء اصطناعي',
  };

  static const Map<String, String> statusLabels = {
    'available': 'متاح',
    'in_progress': 'قيد التنفيذ',
    'completed': 'مكتمل',
    'cancelled': 'ملغي',
  };

  static const Map<String, String> impactLabels = {
    'low': 'منخفض',
    'medium': 'متوسط',
    'high': 'عالي',
  };

  static const Map<String, Color> impactColors = {
    'low': AppTheme.successColor,
    'medium': AppTheme.warningColor,
    'high': AppTheme.dangerColor,
  };
}
