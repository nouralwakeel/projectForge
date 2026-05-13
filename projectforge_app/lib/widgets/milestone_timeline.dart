import 'package:flutter/material.dart';
import '../models/sandbox_model.dart';

class MilestoneTimeline extends StatelessWidget {
  final List<TimelineModel> timeline;

  const MilestoneTimeline({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: List.generate(timeline.length, (index) {
        final t = timeline[index];
        final isLast = index == timeline.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        '${t.order}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(t.description),
                      const SizedBox(height: 4),
                      Text(
                        '${t.startDate} → ${t.endDate}  (${t.estimatedDays} يوم)',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
