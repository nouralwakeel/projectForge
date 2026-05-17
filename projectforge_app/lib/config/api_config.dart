class ApiConfig {
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';

  static const String majors = '/majors';
  static const String skills = '/skills';
  static const String userSkills = '/user/skills';

  static const String projects = '/projects';
  static const String recommendations = '/recommendations';
  static const String teams = '/teams';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminProjects = '/admin/projects';

  static String projectSandbox(int id) => '/projects/$id/sandbox';
  static String projectEstimate(int id) => '/projects/$id/estimate';
  static String teamEstimate(int id) => '/teams/$id/estimate';
}
