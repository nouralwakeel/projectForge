import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../config/app_theme.dart';

class SuccessGauge extends StatelessWidget {
  final double percentage;
  final double radius;
  final double lineWidth;

  const SuccessGauge({
    super.key,
    required this.percentage,
    this.radius = 96,
    this.lineWidth = 16,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.successProbabilityColor(percentage);
    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      percent: (percentage / 100).clamp(0.0, 1.0),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: AppTheme.surfaceContainerHigh,
      progressColor: color,
      animateFromLastPercent: true,
      animation: true,
      animationDuration: 1200,
      center: Text(
        '${percentage.toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
          height: 1.1,
        ),
      ),
    );
  }
}
