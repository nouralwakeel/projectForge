# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Layout

Two independent applications that communicate over HTTP:

- [backend/](backend/) — Laravel 12 + PHP 8.2 API (Sanctum-based auth)
- [projectforge_app/](projectforge_app/) — Flutter app (GetX, Dio)

Top-level Arabic docs ([README.md](README.md), [PROJECT_REPORT.md](PROJECT_REPORT.md), [API_DOCUMENTATION.md](API_DOCUMENTATION.md), [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md), [erd.txt](erd.txt), [uml.txt](uml.txt)) describe the academic graduation-project domain — read these before changing data models or matching/estimation algorithms; the spec is the source of truth, not the current code.

## Common Commands

### Backend (Laravel)

Run from [backend/](backend/):

```bash
php artisan serve --host=0.0.0.0 --port=8000   # dev server (also via ../start.bat)
composer dev                                    # serve + queue + pail + vite concurrently
composer test                                   # clears config, then runs phpunit
php artisan test --filter=TestName              # single test
php artisan migrate:fresh --seed                # reset DB and run all seeders
php artisan tinker                              # REPL
./vendor/bin/pint                               # format PHP
```

### Frontend (Flutter)

Run from [projectforge_app/](projectforge_app/):

```bash
flutter pub get
flutter run                                     # default device
flutter run -d chrome                           # web
flutter test                                    # all tests
flutter test test/widget_test.dart              # single test file
flutter analyze
```

The Flutter app's base URL is set at runtime via [SettingsService](projectforge_app/lib/services/settings_service.dart) (see [api_service.dart](projectforge_app/lib/services/api_service.dart)) — change the backend host through the in-app settings screen, not hardcoded constants.

## Architecture

### Domain (academic graduation projects)

Core entities and how they connect: `User` (auth shell, role: student/advisor/admin) → has-one `Student` (academic profile: stud_num, names, gender, DOB, `major_id`) → many-to-many `Skill` via `student_skills` (with `proficiency_level` 1–5 and `interest_level`, this is the "Project-DNA"). `Project` has a `type` (`ProjectType`), a `supervisor_id` (advisor User), many-to-many `Skill` via `project_skills` (with `weight`), and one-to-many `Milestone` and `Risk`. `Team` belongs to a `Project` and has members through `team_members` (linked to `Student`, not `User`). `SuccessEstimation` records per-student-or-team probability snapshots with a `factors_log` JSON column.

**Important historical note:** student fields were originally on `users` then split into a separate `students` table (see migrations dated `2026_05_02_*`). `user_skills` was renamed to `student_skills`, and `team_members` / `success_estimations` now reference `student_id`, not `user_id`. When writing queries or relationships involving a "student", go through `User->student->...`, not `User->...`.

### Backend (Laravel)

- All API routes live in [routes/api.php](backend/routes/api.php) under the `v1` prefix. Public: register, login, list majors/skills/projects, `/health/db`. Authenticated (`auth:sanctum`): everything else. Admin-only (custom `role` middleware aliased in [bootstrap/app.php](backend/bootstrap/app.php) → [RoleMiddleware](backend/app/Http/Middleware/RoleMiddleware.php)): admin dashboard + write endpoints for majors/skills.
- Controllers are namespaced under [app/Http/Controllers/API/](backend/app/Http/Controllers/API/). Validation lives in [app/Http/Requests/](backend/app/Http/Requests/) form requests.
- Two algorithm controllers carry the business logic — keep math changes here, not in models:
  - [RecommendationController](backend/app/Http/Controllers/API/RecommendationController.php) — weighted match score = Σ(student_proficiency × project_skill_weight) / Σ(5 × weight), top 10 returned.
  - [SuccessEstimationController](backend/app/Http/Controllers/API/SuccessEstimationController.php) — probability = `0.5·skill_coverage + 0.2·team_balance + 0.3·difficulty_factor` where `difficulty_factor = (6 − difficulty_level)/5`. Persists each calculation to `success_estimations` with a `factors_log` for traceability.
- [SandboxController](backend/app/Http/Controllers/API/SandboxController.php) lazily seeds milestones/risks from hardcoded Arabic templates keyed by project type (`mobile_app`, `web_application`, `ai_system`, fallback `default`). If you add a new project type, extend `getMilestonesTemplate()` and `getRisksTemplate()` together.
- Seeders are chained via [DatabaseSeeder](backend/database/seeders/DatabaseSeeder.php) in dependency order (Major → Skill → ProjectType → User → Project → Team). Run `migrate:fresh --seed` after schema changes; the seeders are the only realistic test data.

### Frontend (Flutter)

- State management: **GetX** throughout — controllers in [lib/controllers/](projectforge_app/lib/controllers/), DI bindings in [lib/app/bindings/initial_binding.dart](projectforge_app/lib/app/bindings/initial_binding.dart), routes in [lib/app/routes/app_pages.dart](projectforge_app/lib/app/routes/app_pages.dart) and [app_routes.dart](projectforge_app/lib/app/routes/app_routes.dart).
- All HTTP goes through [ApiService](projectforge_app/lib/services/api_service.dart) (Dio). It auto-attaches the bearer token from [StorageService](projectforge_app/lib/services/storage_service.dart) (flutter_secure_storage) and on `401` clears tokens and redirects to `/login` — do not add per-request auth logic in controllers.
- Endpoint paths are centralized in [config/api_config.dart](projectforge_app/lib/config/api_config.dart); they are relative to `v1` (the base URL from `SettingsService` already includes the prefix).
- UI is RTL Arabic (`locale: Locale('ar')` in [main.dart](projectforge_app/lib/main.dart)); user-facing strings throughout the app are in Arabic. Theme and color tokens live in [config/app_theme.dart](projectforge_app/lib/config/app_theme.dart); domain enums and Arabic label maps in [config/app_constants.dart](projectforge_app/lib/config/app_constants.dart).

### Backend ↔ Frontend contract

The Laravel API returns `{success: bool, message?: string, data?: ...}` consistently (see `AuthController`/`RecommendationController` for the pattern). When adding endpoints, follow that envelope so the Flutter controllers' deserialization doesn't need special-casing.
