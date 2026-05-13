import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../models/project_model.dart';
import 'match_badge.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final double matchPercentage;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.matchPercentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  MatchBadge(percentage: matchPercentage),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(AppConstants.projectTypeLabels[project.type] ?? project.type, style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('صعوبة ${project.difficultyLevel}', style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Spacer(),
                  if (project.advisor != null)
                    Text('المشرف: ${project.advisor!.fullName}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
