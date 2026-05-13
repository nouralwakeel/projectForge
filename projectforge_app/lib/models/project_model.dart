class ProjectModel {
  final int id;
  final String title;
  final String description;
  final String type;
  final int difficultyLevel;
  final String status;
  final int? advisorId;
  final AdvisorModel? advisor;
  final List<ProjectSkillModel>? skills;
  final List<MilestoneModel>? milestones;
  final List<RiskModel>? risks;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficultyLevel,
    required this.status,
    this.advisorId,
    this.advisor,
    this.skills,
    this.milestones,
    this.risks,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      difficultyLevel: json['difficulty_level'] ?? 1,
      status: json['status'] ?? 'available',
      advisorId: json['advisor_id'],
      advisor: json['advisor'] != null ? AdvisorModel.fromJson(json['advisor']) : null,
      skills: json['skills'] != null
          ? (json['skills'] as List).map((e) => ProjectSkillModel.fromJson(e)).toList()
          : null,
      milestones: json['milestones'] != null
          ? (json['milestones'] as List).map((e) => MilestoneModel.fromJson(e)).toList()
          : null,
      risks: json['risks'] != null
          ? (json['risks'] as List).map((e) => RiskModel.fromJson(e)).toList()
          : null,
    );
  }
}

class AdvisorModel {
  final int id;
  final String firstName;
  final String lastName;

  AdvisorModel({required this.id, required this.firstName, required this.lastName});

  String get fullName => '$firstName $lastName';

  factory AdvisorModel.fromJson(Map<String, dynamic> json) {
    return AdvisorModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }
}

class ProjectSkillModel {
  final int id;
  final String name;
  final String category;
  final double weight;

  ProjectSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.weight,
  });

  factory ProjectSkillModel.fromJson(Map<String, dynamic> json) {
    return ProjectSkillModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      weight: (json['pivot']?['weight'] ?? 0).toDouble(),
    );
  }
}

class MilestoneModel {
  final int id;
  final String title;
  final String description;
  final int estimatedDays;
  final int orderSequence;

  MilestoneModel({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedDays,
    required this.orderSequence,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      estimatedDays: json['estimated_days'] ?? 0,
      orderSequence: json['order_sequence'] ?? 0,
    );
  }
}

class RiskModel {
  final int id;
  final String riskDescription;
  final String impactLevel;
  final String mitigationPlan;

  RiskModel({
    required this.id,
    required this.riskDescription,
    required this.impactLevel,
    required this.mitigationPlan,
  });

  factory RiskModel.fromJson(Map<String, dynamic> json) {
    return RiskModel(
      id: json['id'],
      riskDescription: json['risk_description'] ?? '',
      impactLevel: json['impact_level'] ?? 'low',
      mitigationPlan: json['mitigation_plan'] ?? '',
    );
  }
}
