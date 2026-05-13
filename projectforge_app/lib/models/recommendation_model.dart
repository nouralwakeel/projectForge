import 'project_model.dart';

class RecommendationModel {
  final ProjectModel project;
  final double matchScore;
  final double matchPercentage;

  RecommendationModel({
    required this.project,
    required this.matchScore,
    required this.matchPercentage,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      project: ProjectModel.fromJson(json['project']),
      matchScore: (json['match_score'] ?? 0).toDouble(),
      matchPercentage: (json['match_percentage'] ?? 0).toDouble(),
    );
  }
}
