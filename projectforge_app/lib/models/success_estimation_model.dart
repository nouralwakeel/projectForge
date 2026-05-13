class SuccessEstimationModel {
  final double successProbability;
  final EstimationFactors factors;
  final int? teamSize;
  final int difficultyLevel;
  final int estimationId;

  SuccessEstimationModel({
    required this.successProbability,
    required this.factors,
    this.teamSize,
    required this.difficultyLevel,
    required this.estimationId,
  });

  factory SuccessEstimationModel.fromJson(Map<String, dynamic> json) {
    return SuccessEstimationModel(
      successProbability: (json['success_probability'] ?? 0).toDouble(),
      factors: EstimationFactors.fromJson(json['factors'] ?? {}),
      teamSize: json['team_size'],
      difficultyLevel: json['difficulty_level'] ?? 1,
      estimationId: json['estimation_id'] ?? 0,
    );
  }
}

class EstimationFactors {
  final double skillCoverage;
  final double teamBalance;
  final double difficultyFactor;

  EstimationFactors({
    required this.skillCoverage,
    required this.teamBalance,
    required this.difficultyFactor,
  });

  factory EstimationFactors.fromJson(Map<String, dynamic> json) {
    return EstimationFactors(
      skillCoverage: (json['skill_coverage'] ?? 0).toDouble(),
      teamBalance: (json['team_balance'] ?? 0).toDouble(),
      difficultyFactor: (json['difficulty_factor'] ?? 0).toDouble(),
    );
  }
}
