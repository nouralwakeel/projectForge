import 'package:get/get.dart';
import '../../controllers/estimation_controller.dart';
import '../../controllers/project_controller.dart';
import '../../controllers/recommendation_controller.dart';
import '../../controllers/sandbox_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/skill_controller.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../controllers/advisor_dashboard_controller.dart';
import '../../controllers/team_controller.dart';
import '../../views/admin/admin_dashboard_screen.dart';
import '../../views/admin/admin_users_screen.dart';
import '../../views/admin/admin_projects_screen.dart';
import '../../views/admin/admin_majors_screen.dart';
import '../../views/admin/admin_skills_screen.dart';
import '../../views/advisor/advisor_dashboard_screen.dart';
import '../../views/advisor/advisor_team_requests_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/intro/intro_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/dashboard/home_screen.dart';
import '../../views/estimation/success_estimator_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/project/project_detail_screen.dart';
import '../../views/sandbox/sandbox_screen.dart';
import '../../views/settings/settings_screen.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/survey/skills_survey_screen.dart';
import '../../views/team/team_detail_screen.dart';
import '../../views/team/team_list_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.intro,
      page: () => const IntroScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.survey,
      page: () => const SkillsSurveyScreen(),
      binding: BindingsBuilder.put(() => SkillController()),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder.put(() => RecommendationController()),
    ),
    GetPage(
      name: AppRoutes.projectDetail,
      page: () => const ProjectDetailScreen(),
      binding: BindingsBuilder.put(() => ProjectController()),
    ),
    GetPage(
      name: AppRoutes.sandbox,
      page: () => const SandboxScreen(),
      binding: BindingsBuilder.put(() => SandboxController()),
    ),
    GetPage(
      name: AppRoutes.estimation,
      page: () => const SuccessEstimatorScreen(),
      binding: BindingsBuilder.put(() => EstimationController()),
    ),
    GetPage(
      name: AppRoutes.teams,
      page: () => const TeamListScreen(),
      binding: BindingsBuilder.put(() => TeamController()),
    ),
    GetPage(
      name: AppRoutes.teamDetail,
      page: () => const TeamDetailScreen(),
      binding: BindingsBuilder.put(() => TeamController()),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: BindingsBuilder.put(() => SettingsController()),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
      binding: BindingsBuilder.put(() => AdminDashboardController()),
    ),
    GetPage(
      name: AppRoutes.adminUsers,
      page: () => const AdminUsersScreen(),
    ),
    GetPage(
      name: AppRoutes.adminProjects,
      page: () => const AdminProjectsScreen(),
    ),
    GetPage(
      name: AppRoutes.adminMajors,
      page: () => const AdminMajorsScreen(),
    ),
    GetPage(
      name: AppRoutes.adminSkills,
      page: () => const AdminSkillsScreen(),
    ),
    GetPage(
      name: AppRoutes.advisorDashboard,
      page: () => const AdvisorDashboardScreen(),
      binding: BindingsBuilder.put(() => AdvisorDashboardController()),
    ),
    GetPage(
      name: AppRoutes.advisorTeamRequests,
      page: () => const AdvisorTeamRequestsScreen(),
      binding: BindingsBuilder.put(() => AdvisorDashboardController()),
    ),
  ];
}
