import 'project_model.dart';

class TeamModel {
  final int id;
  final String name;
  final int projectId;
  final bool isApproved;
  final ProjectModel? project;
  final List<TeamMemberModel>? members;

  TeamModel({
    required this.id,
    required this.name,
    required this.projectId,
    required this.isApproved,
    this.project,
    this.members,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'],
      name: json['name'] ?? '',
      projectId: json['project_id'] ?? 0,
      isApproved: json['is_approved'] ?? false,
      project: json['project'] != null ? ProjectModel.fromJson(json['project']) : null,
      members: json['members'] != null
          ? (json['members'] as List).map((e) => TeamMemberModel.fromJson(e)).toList()
          : null,
    );
  }
}

class TeamMemberModel {
  final int id;
  final int userId;
  final int teamId;
  final String roleInTeam;
  final MemberUserModel? user;

  TeamMemberModel({
    required this.id,
    required this.userId,
    required this.teamId,
    required this.roleInTeam,
    this.user,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      teamId: json['team_id'] ?? 0,
      roleInTeam: json['role_in_team'] ?? 'member',
      user: json['user'] != null ? MemberUserModel.fromJson(json['user']) : null,
    );
  }
}

class MemberUserModel {
  final int id;
  final String firstName;
  final String lastName;

  MemberUserModel({required this.id, required this.firstName, required this.lastName});

  String get fullName => '$firstName $lastName';

  factory MemberUserModel.fromJson(Map<String, dynamic> json) {
    return MemberUserModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }
}
