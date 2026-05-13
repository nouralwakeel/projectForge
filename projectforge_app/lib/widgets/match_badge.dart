import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class MatchBadge extends StatelessWidget {
  final double percentage;

  const MatchBadge({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.matchColor(percentage);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${percentage.toStringAsFixed(0)}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
