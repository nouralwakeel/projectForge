class ApiConfig {
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';

  static const String passwordForgot = '/password/forgot';
  static const String passwordReset = '/password/reset';

  static const String assistantChat = '/assistant/chat';

  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(int id) => '/notifications/$id/read';

  static const String majors = '/majors';
  static const String skills = '/skills';
  static const String userSkills = '/user/skills';

  static const String projects = '/projects';
  static const String recommendations = '/recommendations';
  static const String teams = '/teams';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminProjects = '/admin/projects';
  static String adminUserRestore(int id) => '/admin/users/$id/restore';

  static const String advisorDashboard = '/advisor/dashboard';
  static const String advisorTeamRequests = '/advisor/team-requests';

  static String projectSandbox(int id) => '/projects/$id/sandbox';
  static String projectEstimate(int id) => '/projects/$id/estimate';
  static String teamEstimate(int id) => '/teams/$id/estimate';
  static String projectTodos(int id) => '/projects/$id/todos';
  static String toggleTodo(int id, int todoId) =>
      '/projects/$id/todos/$todoId/toggle';
}
