import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../models/project_model.dart';

class RiskCard extends StatelessWidget {
  final RiskModel risk;

  const RiskCard({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final impactColor = AppConstants.impactColors[risk.impactLevel] ?? Colors.grey;
    return Card(
      color: impactColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: impactColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    risk.riskDescription,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Chip(
                  label: Text(
                    AppConstants.impactLabels[risk.impactLevel] ?? risk.impactLevel,
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'التخفيف: ${risk.mitigationPlan}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
