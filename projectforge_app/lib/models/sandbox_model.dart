class TimelineModel {
  final int milestoneId;
  final String title;
  final String description;
  final int estimatedDays;
  final String startDate;
  final String endDate;
  final int order;

  TimelineModel({
    required this.milestoneId,
    required this.title,
    required this.description,
    required this.estimatedDays,
    required this.startDate,
    required this.endDate,
    required this.order,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    return TimelineModel(
      milestoneId: json['milestone_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      estimatedDays: json['estimated_days'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}

class SandboxModel {
  final dynamic project;
  final List<TimelineModel> timeline;
  final int totalEstimatedDays;

  SandboxModel({
    required this.project,
    required this.timeline,
    required this.totalEstimatedDays,
  });

  factory SandboxModel.fromJson(Map<String, dynamic> json) {
    return SandboxModel(
      project: json['project'],
      timeline: (json['timeline'] as List?)?.map((e) => TimelineModel.fromJson(e)).toList() ?? [],
      totalEstimatedDays: json['total_estimated_days'] ?? 0,
    );
  }
}
