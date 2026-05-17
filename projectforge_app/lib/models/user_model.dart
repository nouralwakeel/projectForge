class UserModel {
  final int id;
  final String studentId;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String? dateOfBirth;
  final int? majorId;
  final int? academicLevel;
  final String role;
  final MajorModel? major;
  final List<UserSkillModel>? skills;

  UserModel({
    required this.id,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    this.dateOfBirth,
    this.majorId,
    this.academicLevel,
    required this.role,
    this.major,
    this.skills,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id'],
      studentId: student?['stud_num']?.toString() ?? '',
      firstName: student?['first_name'] ?? json['name']?.toString().split(' ').first ?? '',
      lastName: student?['last_name'] ?? json['name']?.toString().split(' ').last ?? '',
      email: json['email'] ?? '',
      gender: student?['gender'] ?? 'male',
      dateOfBirth: student?['date_of_birth'],
      majorId: student?['major_id'],
      academicLevel: student?['academic_level'],
      role: json['role'] ?? 'student',
      major: student?['major'] != null ? MajorModel.fromJson(student!['major']) : null,
      skills: student?['skills'] != null
          ? (student!['skills'] as List).map((e) => UserSkillModel.fromJson(e)).toList()
          : null,
    );
  }
}

class MajorModel {
  final int id;
  final String name;
  final String code;

  MajorModel({required this.id, required this.name, required this.code});

  factory MajorModel.fromJson(Map<String, dynamic> json) {
    return MajorModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class UserSkillModel {
  final int id;
  final String name;
  final String category;
  final int proficiencyLevel;
  final int interestLevel;

  UserSkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.proficiencyLevel,
    this.interestLevel = 1,
  });

  factory UserSkillModel.fromJson(Map<String, dynamic> json) {
    return UserSkillModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      proficiencyLevel: json['pivot']?['proficiency_level'] ?? 1,
      interestLevel: json['pivot']?['interest_level'] ?? 1,
    );
  }
}
