class SkillModel {
  final int id;
  final String name;
  final String category;

  SkillModel({required this.id, required this.name, required this.category});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
