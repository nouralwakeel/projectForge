# ProjectForge - تقرير المشروع الشامل

> **التاريخ:** 2026-04-06
> **التقنيات:** Laravel 12 (Backend) + Flutter (Frontend)
> **قاعدة البيانات:** MySQL (MariaDB via XAMPP)
> **PHP:** 8.2.12 | **Composer:** 2.8.8

---

## الفهرس

1. [نظرة عامة على المشروع](#1-نظرة-عامة-على-المشروع)
2. [البنية التقنية المعتمدة](#2-البنية-التقنية-المعتمدة)
3. [ما تم إنجازه - Laravel Backend](#3-ما-تم-إنجازه---laravel-backend)
4. [المشاكل المكتشفة والإصلاحات المطلوبة](#4-المشاكل-المكتشفة-والإصلاحات-المطلوبة)
5. [الخطوات التفصيلية القادمة - Laravel](#5-الخطوات-التفصيلية-القادمة---laravel)
6. [الخطوات القادمة - Flutter Frontend](#6-الخطوات-القادمة---flutter-frontend)
7. [الخطوات القادمة - الدمج والاختبار والنشر](#7-الخطوات-القادمة---الدمج-والاختبار-والنشر)
8. [سياق المحادثة الحالي](#8-سياق-المحادثة-الحالي)
9. [هيكل المشروع الحالي](#9-هيكل-المشروع-الحالي)
10. [مخطط قاعدة البيانات (ERD)](#10-مخطط-قاعدة-البيانات-erd)

---

## 1. نظرة عامة على المشروع

**ProjectForge** هو نظام ذكي لإدارة مشاريع التخرج الجامعية يهدف إلى:

- **استبيان المهارات (Project-DNA):** بناء ملف مهارات لكل طالب عبر استبيان تفاعلي
- **محرك التوصية (Recommendation Engine):** اقتراح مشاريع مناسبة بناءً على مهارات الطالب
- **بيئة المحاكاة (Sandbox):** توليد خطط عمل (Milestones) ومخاطر محتملة (Risks) لكل مشروع
- **مقيّم النجاح (Success Estimator):** حساب احتمالية نجاح الطالب/الفريق في مشروع معين
- **مطابقة الفرق (Team Matching):** اقتراح فرق متوازنة بناءً على المهارات المتكاملة

### المراحل الستة للمشروع الكامل

| المرحلة | الوصف | المدة المتوقعة | الحالة |
|---------|-------|----------------|--------|
| **1** | التحليل وتصميم قاعدة البيانات (ERD) | أسبوع | **مكتمل** |
| **2** | تصميم UI/UX (Figma) | أسبوع | لم يبدأ |
| **3** | تطوير Backend (Laravel) | 2-3 أسابيع | **جاري - 40%** |
| **4** | تطوير Frontend (Flutter) | 3 أسابيع | لم يبدأ |
| **5** | الدمج والاختبار | أسبوع | لم يبدأ |
| **6** | النشر والعرض التوضيحي | أسبوع | لم يبدأ |

---

## 2. البنية التقنية المعتمدة

```
┌─────────────────────────────────────────────────────┐
│                  Flutter App (Frontend)              │
│           Android / iOS / Web                        │
│   State Management: GetX / Bloc / Riverpod          │
└────────────────────┬────────────────────────────────┘
                     │  REST API (JSON)
                     │  Authentication: Bearer Token (Sanctum)
┌────────────────────▼────────────────────────────────┐
│              Laravel 12 (Backend API)                │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │  Auth (Sanctum)  │  Recommendation Engine    │   │
│  │  CRUD APIs       │  Success Estimator        │   │
│  │  Sandbox Engine  │  Team Matching            │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│  Eloquent ORM                                        │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│          MySQL / MariaDB (XAMPP)                      │
│          Database: projectforge                       │
│          13 جدول + personal_access_tokens            │
└─────────────────────────────────────────────────────┘
```

**إعدادات الاتصال بقاعدة البيانات:**
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=projectforge
DB_USERNAME=root
DB_PASSWORD=
```

---

## 3. ما تم إنجازه - Laravel Backend

### 3.1 قاعدة البيانات والمايقريشنز (Migrations) - مكتمل 100%

تم إنشاء **13 ملف migration** وتشغيلها بنجاح بالترتيب التالي:

| # | الملف | الجدول | الحقول الرئيسية |
|---|-------|--------|-----------------|
| 1 | `2026_04_06_150327_01_create_majors_table` | `majors` | id, name, code (unique) |
| 2 | `2026_04_06_150327_02_create_users_table` | `users` + `password_reset_tokens` + `sessions` | student_id (unique), first_name, last_name, email (unique), password, gender (enum), date_of_birth, major_id (FK), academic_level, role (enum) |
| 3 | `2026_04_06_150328_create_skills_table` | `skills` | id, name, category |
| 4 | `2026_04_06_150329_create_projects_table` | `projects` | id, title, description, type, difficulty_level, advisor_id (FK->users), status (enum) |
| 5 | `2026_04_06_150330_create_teams_table` | `teams` | id, name, project_id (FK->projects), is_approved |
| 6 | `2026_04_06_150331_create_milestones_table` | `milestones` | id, project_id (FK), title, description, estimated_days, order_sequence |
| 7 | `2026_04_06_150332_create_risks_table` | `risks` | id, project_id (FK), risk_description, impact_level (enum), mitigation_plan |
| 8 | `2026_04_06_150333_create_success_estimations_table` | `success_estimations` | id, team_id (FK nullable), user_id (FK nullable), project_id (FK), success_probability (decimal), calculated_at, factors_log (JSON) |
| 9 | `2026_04_06_150334_create_user_skills_table` | `user_skills` | id, user_id (FK), skill_id (FK), proficiency_level, unique(user_id, skill_id) |
| 10 | `2026_04_06_150335_create_project_skills_table` | `project_skills` | id, project_id (FK), skill_id (FK), weight (decimal), unique(project_id, skill_id) |
| 11 | `2026_04_06_150336_create_team_members_table` | `team_members` | id, team_id (FK), user_id (FK), role_in_team, unique(team_id, user_id) |
| 12 | `2026_04_06_153512_create_personal_access_tokens_table` | `personal_access_tokens` | (Sanctum tokens) |
| 13 | `0001_01_01_000001_create_cache_table` | `cache` + `cache_locks` | (Laravel default) |

### 3.2 الموديلز (Models) - مكتمل 100%

تم إنشاء **11 موديل** في `app/Models/` مع جميع العلاقات:

| الموديل | العلاقات المعرّفة | الحقول القابلة للتعبئة ($fillable) |
|---------|-------------------|------------------------------------|
| `User` | belongsTo(Major), belongsToMany(Skill via user_skills), belongsToMany(Team via team_members), hasMany(Project as advisor), hasMany(SuccessEstimation) | student_id, first_name, last_name, email, password, gender, date_of_birth, major_id, academic_level, role |
| `Major` | hasMany(User) | name, code |
| `Skill` | belongsToMany(User via user_skills), belongsToMany(Project via project_skills) | name, category |
| `Project` | belongsTo(User as advisor), belongsToMany(Skill via project_skills), hasMany(Team), hasMany(Milestone), hasMany(Risk), hasMany(SuccessEstimation) | title, description, type, difficulty_level, advisor_id, status |
| `Team` | belongsTo(Project), belongsToMany(User via team_members), hasMany(SuccessEstimation) | name, project_id, is_approved |
| `Milestone` | belongsTo(Project) | project_id, title, description, estimated_days, order_sequence |
| `Risk` | belongsTo(Project) | project_id, risk_description, impact_level, mitigation_plan |
| `SuccessEstimation` | belongsTo(Team), belongsTo(User), belongsTo(Project) | team_id, user_id, project_id, success_probability, calculated_at, factors_log |
| `UserSkill` | belongsTo(User), belongsTo(Skill) | user_id, skill_id, proficiency_level |
| `ProjectSkill` | belongsTo(Project), belongsTo(Skill) | project_id, skill_id, weight |
| `TeamMember` | belongsTo(Team), belongsTo(User) | team_id, user_id, role_in_team |

### 3.3 المصادقة (Authentication) - مكتمل 100%

- تم تثبيت **Laravel Sanctum v4.3.1**
- تم نشر ملف الإعدادات `config/sanctum.php`
- تم تشغيل migration الخاص بـ `personal_access_tokens`
- تم إضافة `HasApiTokens` trait إلى `User` model

### 3.4 Controllers - مكتمل جزئياً (15%)

تم إنشاء **9 Controllers** في `app/Http/Controllers/API/`:

| Controller | الحالة | الدوال المنفذة |
|-----------|--------|----------------|
| **AuthController** | **مكتمل** | register(), login(), logout(), me() |
| MajorController | **هيكل فارغ** | index(), store(), show(), update(), destroy() - بدون منطق |
| SkillController | **هيكل فارغ** | index(), store(), show(), update(), destroy() - بدون منطق |
| ProjectController | **هيكل فارغ** | index(), store(), show(), update(), destroy() - بدون منطق |
| TeamController | **هيكل فارغ** | index(), store(), show(), update(), destroy() - بدون منطق |
| UserController | **هيكل فارغ** | index(), store(), show(), update(), destroy() - بدون منطق |
| RecommendationController | **فارغ تماماً** | لا توجد دوال |
| SandboxController | **فارغ تماماً** | لا توجد دوال |
| SuccessEstimationController | **فارغ تماماً** | لا توجد دوال |

### 3.5 Form Requests - مكتمل جزئياً (0% تنفيذ فعلي)

تم إنشاء **4 ملفات Request** لكنها جميعها **فارغة** (بدون قواعد تحقق):

| Request | الحالة | المشكلة |
|---------|--------|---------|
| `RegisterRequest` | فارغ | `authorize()` يُرجع `false` (سيرفض جميع الطلبات!) + لا توجد قواعد تحقق |
| `LoginRequest` | فارغ | `authorize()` يُرجع `false` + لا توجد قواعد تحقق |
| `UpdateSkillsRequest` | فارغ | `authorize()` يُرجع `false` + لا توجد قواعد تحقق |
| `StoreProjectRequest` | فارغ | `authorize()` يُرجع `false` + لا توجد قواعد تحقق |

---

## 4. المشاكل المكتشفة والإصلاحات المطلوبة

### 4.1 مشاكل حرجة (Critical Bugs) - يجب إصلاحها فوراً

#### BUG-01: Form Requests ترفض جميع الطلبات
**الملفات:** `RegisterRequest.php`, `LoginRequest.php`, `UpdateSkillsRequest.php`, `StoreProjectRequest.php`
**المشكلة:** جميع ملفات Form Request تحتوي على `authorize(): return false;` مما يعني أن **أي طلب سيتم رفضه** بـ 403 Forbidden.
**الإصلاح:** تغيير `return false;` إلى `return true;` وإضافة قواعد التحقق المناسبة.

#### BUG-02: Form Requests بدون قواعد تحقق
**المشكلة:** لا توجد أي قواعد validation في ملفات Request، مما يعني قبول أي بيانات بدون تحقق.
**الإصلاح:** إضافة قواعد التحقق لكل Request.

#### BUG-03: ملف `routes/api.php` غير موجود
**المشكلة:** لا يوجد ملف `routes/api.php` بالأساس. لن تعمل أي API بدونه.
**الإصلاح:** إنشاء ملف `routes/api.php` وتسجيل جميع المسارات وتعديل `bootstrap/app.php` لتحميل ملف API routes.

#### BUG-04: UserFactory و DatabaseSeeder لا يزالان يستخدمان الحقول القديمة
**الملفات:** `database/factories/UserFactory.php`, `database/seeders/DatabaseSeeder.php`
**المشكلة:** UserFactory يستخدم حقل `name` بدلاً من `first_name` و `last_name`، كما أن DatabaseSeeder يستخدم `name` أيضاً. هذا سيسبب خطأ عند تشغيل `php artisan db:seed`.
**الإصلاح:** تحديث UserFactory ليستخدم الحقول الجديدة (student_id, first_name, last_name, gender, date_of_birth, major_id, academic_level).

### 4.2 مشاكل متوسطة (Medium)

#### BUG-05: عدم وجود Middleware للتمييز بين أدوار المستخدمين
**المشكلة:** لا يوجد middleware للتحقق من صلاحيات المستخدم (student, advisor, admin).
**الإصلاح:** إنشاء `RoleMiddleware` للتحقق من دور المستخدم.

#### BUG-06: `APP_NAME` لا يزال `Laravel`
**الملف:** `.env`
**الإصلاح:** تغيير `APP_NAME=Laravel` إلى `APP_NAME=ProjectForge`.

#### BUG-07: عدم وجود Factories للموديلات الأخرى
**المشكلة:** يوجد فقط `UserFactory`. لا توجد Factories لباقي الموديلات (Major, Skill, Project, Team, etc.).
**الإصلاح:** إنشاء Factory لكل موديل.

---

## 5. الخطوات التفصيلية القادمة - Laravel

### الخطوة 5.1: إصلاح المشاكل الحرجة (الأولوية: عاجل)

#### 5.1.1 إصلاح Form Requests

**`RegisterRequest.php`** - يجب تحديثه إلى:
```php
public function authorize(): bool { return true; }

public function rules(): array
{
    return [
        'student_id'     => 'required|string|unique:users',
        'first_name'     => 'required|string|max:255',
        'last_name'      => 'required|string|max:255',
        'email'          => 'required|email|unique:users',
        'password'       => 'required|string|min:8|confirmed',
        'gender'         => 'required|in:male,female',
        'date_of_birth'  => 'required|date',
        'major_id'       => 'required|exists:majors,id',
        'academic_level' => 'required|integer|min:1|max:10',
        'role'           => 'sometimes|in:student,advisor,admin',
    ];
}
```

**`LoginRequest.php`** - يجب تحديثه إلى:
```php
public function authorize(): bool { return true; }

public function rules(): array
{
    return [
        'email'    => 'required|email',
        'password' => 'required|string',
    ];
}
```

**`UpdateSkillsRequest.php`** - يجب تحديثه إلى:
```php
public function authorize(): bool { return true; }

public function rules(): array
{
    return [
        'skills'                    => 'required|array|min:1',
        'skills.*.skill_id'        => 'required|exists:skills,id',
        'skills.*.proficiency_level'=> 'required|integer|min:1|max:5',
    ];
}
```

**`StoreProjectRequest.php`** - يجب تحديثه إلى:
```php
public function authorize(): bool { return true; }

public function rules(): array
{
    return [
        'title'            => 'required|string|max:255',
        'description'      => 'required|string',
        'type'             => 'required|string',
        'difficulty_level' => 'required|integer|min:1|max:5',
        'skills'           => 'required|array|min:1',
        'skills.*.id'      => 'required|exists:skills,id',
        'skills.*.weight'  => 'required|numeric|min:0|max:1',
    ];
}
```

#### 5.1.2 إنشاء ملف `routes/api.php`

يجب إنشاء الملف وتعديل `bootstrap/app.php` لتحميله:

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    // Public routes
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/majors', [MajorController::class, 'index']);
    Route::get('/skills', [SkillController::class, 'index']);
    Route::get('/projects', [ProjectController::class, 'index']);
    Route::get('/projects/{id}', [ProjectController::class, 'show']);

    // Protected routes (require authentication)
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);

        // User skills (Project-DNA)
        Route::post('/user/skills', [UserController::class, 'updateSkills']);
        Route::get('/user/skills', [UserController::class, 'getSkills']);

        // Projects
        Route::post('/projects', [ProjectController::class, 'store']);
        Route::put('/projects/{id}', [ProjectController::class, 'update']);
        Route::delete('/projects/{id}', [ProjectController::class, 'destroy']);

        // Recommendations
        Route::get('/recommendations', [RecommendationController::class, 'getRecommendations']);

        // Teams
        Route::apiResource('teams', TeamController::class);
        Route::post('/teams/{id}/join', [TeamController::class, 'join']);

        // Sandbox
        Route::get('/projects/{id}/sandbox', [SandboxController::class, 'getSandbox']);

        // Success Estimation
        Route::get('/projects/{projectId}/estimate', [SuccessEstimationController::class, 'estimate']);
        Route::get('/teams/{teamId}/estimate', [SuccessEstimationController::class, 'estimateTeam']);

        // Admin routes
        Route::middleware('role:admin')->group(function () {
            Route::apiResource('majors', MajorController::class)->except('index');
            Route::apiResource('skills', SkillController::class)->except('index');
        });
    });
});
```

تعديل في `bootstrap/app.php`:
```php
->withRouting(
    web: __DIR__.'/../routes/web.php',
    api: __DIR__.'/../routes/api.php',
    commands: __DIR__.'/../routes/console.php',
)
```

#### 5.1.3 تحديث UserFactory

```php
public function definition(): array
{
    return [
        'student_id'     => fake()->unique()->numerify('STU-#####'),
        'first_name'     => fake()->firstName(),
        'last_name'      => fake()->lastName(),
        'email'          => fake()->unique()->safeEmail(),
        'email_verified_at' => now(),
        'password'       => static::$password ??= Hash::make('password'),
        'gender'         => fake()->randomElement(['male', 'female']),
        'date_of_birth'  => fake()->dateTimeBetween('-30 years', '-18 years'),
        'major_id'       => null,
        'academic_level' => fake()->numberBetween(1, 8),
        'role'           => 'student',
        'remember_token' => Str::random(10),
    ];
}
```

### الخطوة 5.2: إكمال Controllers الأساسية (CRUD)

#### 5.2.1 MajorController
```
index()   -> GET /api/v1/majors       -> إرجاع جميع التخصصات
store()   -> POST /api/v1/majors      -> إنشاء تخصص جديد (admin)
show()    -> GET /api/v1/majors/{id}  -> عرض تخصص واحد
update()  -> PUT /api/v1/majors/{id}  -> تعديل تخصص (admin)
destroy() -> DELETE /api/v1/majors/{id} -> حذف تخصص (admin)
```

#### 5.2.2 SkillController
```
index()   -> GET /api/v1/skills       -> إرجاع جميع المهارات (مع تصفية حسب category)
store()   -> POST /api/v1/skills      -> إنشاء مهارة جديدة (admin)
show()    -> GET /api/v1/skills/{id}  -> عرض مهارة واحدة
update()  -> PUT /api/v1/skills/{id}  -> تعديل مهارة (admin)
destroy() -> DELETE /api/v1/skills/{id} -> حذف مهارة (admin)
```

#### 5.2.3 ProjectController
```
index()   -> GET /api/v1/projects        -> إرجاع المشاريع (مع pagination + تصفية حسب type, status, difficulty)
store()   -> POST /api/v1/projects       -> إنشاء مشروع (مع ربط المهارات المطلوبة)
show()    -> GET /api/v1/projects/{id}   -> عرض مشروع مع skills, milestones, risks
update()  -> PUT /api/v1/projects/{id}   -> تعديل مشروع
destroy() -> DELETE /api/v1/projects/{id} -> حذف مشروع
```

#### 5.2.4 TeamController
```
index()   -> GET /api/v1/teams           -> إرجاع الفرق
store()   -> POST /api/v1/teams          -> إنشاء فريق (مع ربط مشروع)
show()    -> GET /api/v1/teams/{id}      -> عرض فريق مع الأعضاء
join()    -> POST /api/v1/teams/{id}/join -> انضمام عضو للفريق
update()  -> PUT /api/v1/teams/{id}      -> تعديل فريق
destroy() -> DELETE /api/v1/teams/{id}   -> حذف فريق
```

#### 5.2.5 UserController
```
index()        -> GET /api/v1/users             -> إرجاع المستخدمين (admin)
show()         -> GET /api/v1/users/{id}        -> عرض ملف مستخدم
updateSkills() -> POST /api/v1/user/skills      -> تحديث مهارات الطالب (الاستبيان)
getSkills()    -> GET /api/v1/user/skills       -> جلب مهارات الطالب الحالي
```

### الخطوة 5.3: بناء خوارزمية التوصية (Recommendation Engine)

**الملف:** `RecommendationController.php`
**المنطق المطلوب:**

```
1. جلب مهارات الطالب (user_skills) مع مستويات الإجادة
2. جلب جميع المشاريع المتاحة (status = 'available')
3. لكل مشروع، حساب Match Score:

   Match Score = Σ (user_proficiency × skill_weight) / Σ (max_proficiency × skill_weight)

   حيث:
   - user_proficiency = مستوى إجادة الطالب للمهارة (1-5)
   - skill_weight = وزن المهارة في المشروع (0-1)
   - max_proficiency = 5 (الحد الأقصى)

4. ترتيب المشاريع تنازلياً حسب Match Score
5. إرجاع أفضل 10 مشاريع مع نسبة التطابق
```

**مثال عملي:**
```
الطالب يمتلك: Flutter(4), Dart(5), Firebase(2)
المشروع يتطلب: Flutter(weight:0.5), Dart(weight:0.3), Firebase(weight:0.2)

Match = (4×0.5 + 5×0.3 + 2×0.2) / (5×0.5 + 5×0.3 + 5×0.2)
Match = (2 + 1.5 + 0.4) / (2.5 + 1.5 + 1.0)
Match = 3.9 / 5.0 = 78%
```

### الخطوة 5.4: بناء مقيّم النجاح (Success Estimator)

**الملف:** `SuccessEstimationController.php`
**المنطق المطلوب:**

```
المعادلة:
Success% = (Skill_Coverage × 0.5) + (Team_Balance × 0.2) + (Difficulty_Factor × 0.3)

حيث:
- Skill_Coverage = نسبة تغطية مهارات الفريق/الطالب لمتطلبات المشروع (0-100%)
- Team_Balance = مدى تكامل مهارات أعضاء الفريق (0-100%)
- Difficulty_Factor = (6 - difficulty_level) / 5 × 100
  (مشروع بصعوبة 1 = 100%، مشروع بصعوبة 5 = 20%)
```

**الخطوات:**
1. جلب المشروع مع مهاراته المطلوبة (`project_skills`)
2. جلب مهارات الطالب/الفريق (`user_skills`)
3. حساب Skill Coverage
4. حساب Team Balance (إذا كان فريق)
5. حساب Difficulty Factor
6. تطبيق المعادلة
7. تخزين النتيجة في `success_estimations`
8. إرجاع النتيجة مع `factors_log` (JSON يشرح مكونات النسبة)

### الخطوة 5.5: بناء نظام Sandbox

**الملف:** `SandboxController.php`
**المنطق المطلوب:**

```
1. جلب المشروع حسب النوع (type)
2. بناء خطة Milestones مبدئية بناءً على نوع المشروع:

   - "تطبيق موبايل":
     M1: تحليل المتطلبات (7 أيام)
     M2: تصميم UI/UX (10 أيام)
     M3: بناء الواجهات الأمامية (14 يوم)
     M4: بناء Backend API (14 يوم)
     M5: الربط والاختبار (7 أيام)
     M6: النشر (3 أيام)

   - "موقع ويب":
     M1: تحليل المتطلبات (5 أيام)
     M2: تصميم الموقع (7 أيام)
     M3: برمجة Frontend (12 يوم)
     M4: برمجة Backend (12 يوم)
     M5: اختبار وتحسين (5 أيام)
     M6: النشر (2 أيام)

   - "نظام ذكاء اصطناعي":
     M1: جمع البيانات (10 أيام)
     M2: تحليل واستكشاف البيانات (7 أيام)
     M3: بناء النموذج (14 يوم)
     M4: تدريب وتقييم (10 أيام)
     M5: بناء واجهة المستخدم (10 أيام)
     M6: النشر (5 أيام)

3. بناء قائمة المخاطر بناءً على نوع ومستوى صعوبة المشروع
4. إرجاع البيانات بصيغة JSON منظمة
```

### الخطوة 5.6: إنشاء Role Middleware

```php
// app/Http/Middleware/RoleMiddleware.php
public function handle($request, Closure $next, ...$roles)
{
    if (!in_array($request->user()->role, $roles)) {
        return response()->json(['message' => 'Unauthorized'], 403);
    }
    return $next($request);
}
```

### الخطوة 5.7: إنشاء Seeders و Factories

#### Factories المطلوبة:
- `MajorFactory` - توليد تخصصات أكاديمية
- `SkillFactory` - توليد مهارات تقنية
- `ProjectFactory` - توليد مشاريع متنوعة
- `TeamFactory` - توليد فرق عمل

#### Seeders المطلوبة:
1. **MajorSeeder** - إدراج 8-10 تخصصات حقيقية (هندسة برمجيات، علوم حاسب، نظم معلومات، إلخ)
2. **SkillSeeder** - إدراج 30-50 مهارة حقيقية مصنفة (Frontend, Backend, AI, Databases, Soft Skills)
3. **ProjectSeeder** - إدراج 15-20 مشروع تخرج واقعي مع متطلبات المهارات والأوزان
4. **UserSeeder** - توليد 100 طالب وهمي مع مهارات عشوائية
5. **TeamSeeder** - توليد 10 فرق مع أعضاء
6. **MilestoneSeeder** - إضافة مراحل تنفيذية للمشاريع
7. **RiskSeeder** - إضافة مخاطر للمشاريع

**ترتيب التشغيل في DatabaseSeeder:**
```php
$this->call([
    MajorSeeder::class,
    SkillSeeder::class,
    UserSeeder::class,      // يحتاج majors
    ProjectSeeder::class,   // يحتاج users (advisor)
    TeamSeeder::class,      // يحتاج projects + users
    MilestoneSeeder::class, // يحتاج projects
    RiskSeeder::class,      // يحتاج projects
]);
```

### الخطوة 5.8: إضافة API Resources (اختياري لكن مفيد)

إنشاء Laravel API Resources لتنسيق الاستجابات:
```
php artisan make:resource UserResource
php artisan make:resource ProjectResource
php artisan make:resource TeamResource
php artisan make:resource SkillResource
php artisan make:resource RecommendationResource
```

---

## 6. الخطوات القادمة - Flutter Frontend

### 6.1 تأسيس المشروع

```bash
flutter create --org com.projectforge projectforge_app
```

### 6.2 اختيار State Management

الخيارات:
- **GetX** - الأسهل والأسرع في التطبيق
- **Bloc** - الأكثر تنظيماً للمشاريع الكبيرة
- **Riverpod** - الأحدث والأكثر مرونة

### 6.3 الحزم المطلوبة (pubspec.yaml)

```yaml
dependencies:
  http: ^1.2.0           # HTTP client لربط API
  dio: ^5.4.0            # بديل أقوى لـ http
  shared_preferences: ^2.2.0  # تخزين محلي (token)
  fl_chart: ^0.68.0      # رسومات بيانية (Success Estimator)
  flutter_svg: ^2.0.0    # أيقونات SVG
  google_fonts: ^6.1.0   # خطوط
  intl: ^0.19.0          # تنسيق التواريخ
  flutter_secure_storage: ^9.0.0  # تخزين آمن (token)
```

### 6.4 الشاشات المطلوبة

| # | الشاشة | الوصف | الـ API المرتبطة |
|---|--------|-------|------------------|
| 1 | Splash Screen | شاشة البداية | - |
| 2 | Login Screen | تسجيل الدخول | `POST /api/v1/login` |
| 3 | Register Screen | إنشاء حساب | `POST /api/v1/register` + `GET /api/v1/majors` |
| 4 | Skills Survey | استبيان المهارات (Project-DNA) | `GET /api/v1/skills` + `POST /api/v1/user/skills` |
| 5 | Dashboard | لوحة التحكم الرئيسية | `GET /api/v1/recommendations` |
| 6 | Project Details | تفاصيل المشروع | `GET /api/v1/projects/{id}` |
| 7 | Sandbox View | خطة العمل والمراحل | `GET /api/v1/projects/{id}/sandbox` |
| 8 | Success Estimator | مؤشر احتمالية النجاح | `GET /api/v1/projects/{id}/estimate` |
| 9 | Team Matching | اقتراح/إنشاء الفرق | `POST /api/v1/teams` + `GET /api/v1/teams` |
| 10 | Profile | الملف الشخصي | `GET /api/v1/me` |

### 6.5 هيكل Flutter المقترح

```
lib/
├── main.dart
├── config/
│   ├── api_config.dart       # API base URL
│   └── theme.dart            # ألوان وخطوط
├── models/
│   ├── user_model.dart
│   ├── project_model.dart
│   ├── skill_model.dart
│   ├── team_model.dart
│   └── milestone_model.dart
├── services/
│   ├── api_service.dart      # HTTP client مركزي
│   ├── auth_service.dart     # تسجيل دخول/خروج
│   └── storage_service.dart  # تخزين Token
├── controllers/              # (إذا GetX)
│   ├── auth_controller.dart
│   ├── project_controller.dart
│   └── skill_controller.dart
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── survey/
│   │   └── skills_survey_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── project/
│   │   ├── project_list_screen.dart
│   │   └── project_detail_screen.dart
│   ├── sandbox/
│   │   └── sandbox_screen.dart
│   ├── estimator/
│   │   └── success_estimator_screen.dart
│   ├── team/
│   │   └── team_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── widgets/
    ├── project_card.dart
    ├── skill_chip.dart
    ├── milestone_timeline.dart
    └── success_gauge.dart
```

---

## 7. الخطوات القادمة - الدمج والاختبار والنشر

### 7.1 الدمج (Integration)
1. ربط Flutter مع Laravel API
2. اختبار جميع المسارات
3. التأكد من عمل المصادقة (Sanctum tokens)
4. التحقق من CORS (Cross-Origin) إذا كان الاختبار من المتصفح

### 7.2 الاختبار
1. **Logic Testing:** التأكد من أن التوصيات منطقية
2. **UI Testing:** التأكد من التجاوب على أجهزة مختلفة
3. **API Testing:** اختبار جميع endpoints باستخدام Postman
4. **Bug Fixing:** معالجة الأخطاء

### 7.3 النشر (Deployment)
1. **Backend:** رفع Laravel على DigitalOcean/AWS + إعداد SSL
2. **Frontend:** استخراج APK/AAB للأندرويد + IPA للآيفون
3. **Demo:** تجهيز سيناريو العرض التوضيحي

---

## 8. سياق المحادثة الحالي

### ما حدث خلال هذه الجلسة (بالتسلسل الزمني):

1. **قراءة README.md:** تمت مراجعة خطة المشروع الشاملة باللغة العربية
2. **فحص البيئة:**
   - تأكيد وجود PHP 8.2.12 و Composer 2.8.8
   - تأكيد وجود MySQL/MariaDB في XAMPP
3. **إنشاء مشروع Laravel:**
   - `composer create-project laravel/laravel backend`
   - تم تثبيت Laravel 12.56.0 (لأن v13 يتطلب PHP 8.3)
   - حدث timeout أثناء التثبيت لكن تم حله بـ `composer install`
4. **تهيئة قاعدة البيانات:**
   - تعديل `.env` من SQLite إلى MySQL
   - إنشاء قاعدة `projectforge` عبر XAMPP MySQL
   - توليد مفتاح التطبيق `php artisan key:generate`
5. **إنشاء المايقريشنز:**
   - إنشاء 10 ملفات migration
   - **مشكلة واجهتنا:** خطأ Foreign Key عند تشغيل migrations لأن جدول `majors` كان يُنشأ بعد `users` (الذي يعتمد عليه)
   - **الحل:** إعادة ترتيب ملفات المايقريشن بحيث يُنشأ `majors` أولاً ثم `users`
   - تم تشغيل `php artisan migrate:fresh` بنجاح
6. **إنشاء الموديلز:** 11 موديل مع جميع العلاقات
7. **تثبيت Sanctum:**
   - `composer require laravel/sanctum`
   - نشر ملفات Sanctum
   - تشغيل migration الخاص بالتوكنات
   - إضافة `HasApiTokens` إلى `User` model
8. **إنشاء Controllers:** 9 controllers في `app/Http/Controllers/API/`
9. **إنشاء Form Requests:** 4 ملفات request (فارغة)
10. **تنفيذ AuthController:** register, login, logout, me

### الحالة عند التوقف:

```
Backend Progress: ~40%
├── Database & Migrations  ████████████████████ 100%
├── Models & Relations     ████████████████████ 100%
├── Authentication Setup   ████████████████████ 100%
├── Form Requests          ██░░░░░░░░░░░░░░░░░░  10% (created but empty + bugs)
├── Controllers (CRUD)     ███░░░░░░░░░░░░░░░░░  15% (only AuthController done)
├── Recommendation Engine  ░░░░░░░░░░░░░░░░░░░░   0%
├── Success Estimator      ░░░░░░░░░░░░░░░░░░░░   0%
├── Sandbox System         ░░░░░░░░░░░░░░░░░░░░   0%
├── API Routes             ░░░░░░░░░░░░░░░░░░░░   0% (api.php doesn't exist!)
├── Seeders & Factories    ░░░░░░░░░░░░░░░░░░░░   0% (defaults are broken)
└── Testing                ░░░░░░░░░░░░░░░░░░░░   0%
```

### ترتيب الأولوية للعمل القادم:

| الأولوية | المهمة | السبب |
|----------|--------|-------|
| **1 - عاجل** | إصلاح Form Requests (authorize + rules) | بدونها لن تعمل أي API |
| **2 - عاجل** | إنشاء `routes/api.php` + تعديل bootstrap | بدونها لن تكون APIs متاحة |
| **3 - عاجل** | تحديث UserFactory + DatabaseSeeder | بدونها لن يعمل seeding |
| **4 - مهم** | إكمال CRUD Controllers | البنية التحتية لجميع العمليات |
| **5 - مهم** | إنشاء Seeders ببيانات واقعية | لاختبار الخوارزميات |
| **6 - مهم** | بناء Recommendation Engine | الميزة الأساسية في المشروع |
| **7 - مهم** | بناء Success Estimator | ميزة أساسية |
| **8 - مهم** | بناء Sandbox System | ميزة أساسية |
| **9 - متوسط** | إنشاء Role Middleware | للتحكم بالصلاحيات |
| **10 - متوسط** | API Resources + Pagination | تنسيق الاستجابات |
| **11 - لاحقاً** | اختبارات PHP Unit | ضمان الجودة |

---

## 9. هيكل المشروع الحالي

```
projectForge/
├── README.md                          # خطة المشروع الأصلية (عربي)
├── PROJECT_REPORT.md                  # هذا التقرير
├── erd.txt                            # مخطط ERD نصي
├── uml.txt                            # مخطط UML نصي
├── استمارة.pdf                         # استمارة المشروع
├── مخططات المشروع/                    # مجلد المخططات
│
└── backend/                           # مشروع Laravel 12
    ├── .env                           # إعدادات البيئة (MySQL)
    ├── composer.json                  # Dependencies
    ├── PROGRESS.md                    # ملف تقدم قديم
    │
    ├── app/
    │   ├── Http/
    │   │   ├── Controllers/
    │   │   │   ├── Controller.php     # Base controller
    │   │   │   └── API/
    │   │   │       ├── AuthController.php              ✅ مكتمل
    │   │   │       ├── MajorController.php             🔴 هيكل فارغ
    │   │   │       ├── SkillController.php             🔴 هيكل فارغ
    │   │   │       ├── ProjectController.php           🔴 هيكل فارغ
    │   │   │       ├── TeamController.php              🔴 هيكل فارغ
    │   │   │       ├── UserController.php              🔴 هيكل فارغ
    │   │   │       ├── RecommendationController.php    🔴 فارغ تماماً
    │   │   │       ├── SandboxController.php           🔴 فارغ تماماً
    │   │   │       └── SuccessEstimationController.php 🔴 فارغ تماماً
    │   │   │
    │   │   └── Requests/
    │   │       ├── RegisterRequest.php     🔴 فارغ + authorize=false
    │   │       ├── LoginRequest.php        🔴 فارغ + authorize=false
    │   │       ├── UpdateSkillsRequest.php 🔴 فارغ + authorize=false
    │   │       └── StoreProjectRequest.php 🔴 فارغ + authorize=false
    │   │
    │   └── Models/
    │       ├── User.php              ✅ مكتمل (مع HasApiTokens)
    │       ├── Major.php             ✅ مكتمل
    │       ├── Skill.php             ✅ مكتمل
    │       ├── Project.php           ✅ مكتمل
    │       ├── Team.php              ✅ مكتمل
    │       ├── Milestone.php         ✅ مكتمل
    │       ├── Risk.php              ✅ مكتمل
    │       ├── SuccessEstimation.php  ✅ مكتمل
    │       ├── UserSkill.php         ✅ مكتمل
    │       ├── ProjectSkill.php      ✅ مكتمل
    │       └── TeamMember.php        ✅ مكتمل
    │
    ├── database/
    │   ├── migrations/
    │   │   ├── 0001_01_01_000001_create_cache_table.php         ✅
    │   │   ├── 0001_01_01_000002_create_jobs_table.php          ✅
    │   │   ├── 2026_04_06_150327_01_create_majors_table.php     ✅
    │   │   ├── 2026_04_06_150327_02_create_users_table.php      ✅
    │   │   ├── 2026_04_06_150328_create_skills_table.php        ✅
    │   │   ├── 2026_04_06_150329_create_projects_table.php      ✅
    │   │   ├── 2026_04_06_150330_create_teams_table.php         ✅
    │   │   ├── 2026_04_06_150331_create_milestones_table.php    ✅
    │   │   ├── 2026_04_06_150332_create_risks_table.php         ✅
    │   │   ├── 2026_04_06_150333_create_success_estimations.php ✅
    │   │   ├── 2026_04_06_150334_create_user_skills_table.php   ✅
    │   │   ├── 2026_04_06_150335_create_project_skills.php      ✅
    │   │   ├── 2026_04_06_150336_create_team_members.php        ✅
    │   │   └── 2026_04_06_153512_create_personal_access_tokens.php ✅
    │   │
    │   ├── factories/
    │   │   └── UserFactory.php       🔴 يستخدم حقول قديمة (name بدل first_name/last_name)
    │   │
    │   └── seeders/
    │       └── DatabaseSeeder.php    🔴 يستخدم حقول قديمة + لا يوجد seeders مخصصة
    │
    ├── routes/
    │   ├── web.php                   ✅ (default welcome)
    │   ├── console.php               ✅ (default)
    │   └── api.php                   🔴 غير موجود! (يجب إنشاؤه)
    │
    └── config/
        ├── sanctum.php               ✅ (Sanctum published)
        └── ...                       ✅ (Laravel defaults)
```

**رموز الحالة:**
- ✅ = مكتمل ويعمل
- 🔴 = يحتاج إصلاح أو إكمال

---

## 10. مخطط قاعدة البيانات (ERD)

```
┌──────────────┐       ┌──────────────┐
│   majors     │       │    skills    │
├──────────────┤       ├──────────────┤
│ id (PK)      │       │ id (PK)      │
│ name         │       │ name         │
│ code (UQ)    │       │ category     │
│ timestamps   │       │ timestamps   │
└──────┬───────┘       └──────┬───────┘
       │ 1:N                  │
       ▼                      │
┌──────────────┐              │
│    users     │              │
├──────────────┤              │
│ id (PK)      │              │
│ student_id   │──┐           │
│ first_name   │  │           │
│ last_name    │  │           │
│ email (UQ)   │  │    ┌──────▼───────────┐
│ password     │  │    │  user_skills     │
│ gender       │  │    │  (Project-DNA)   │
│ date_of_birth│  │    ├──────────────────┤
│ major_id(FK) │  ├───►│ user_id (FK)     │
│ academic_lvl │  │    │ skill_id (FK)    │
│ role (enum)  │  │    │ proficiency_level│
│ timestamps   │  │    │ UQ(user,skill)   │
└──┬───────────┘  │    └──────────────────┘
   │              │
   │ 1:N (advisor)│
   │              │    ┌──────────────────┐
   │              │    │ project_skills   │
   ▼              │    ├──────────────────┤
┌──────────────┐  │    │ project_id (FK)  │
│  projects    │  │    │ skill_id (FK)    │
├──────────────┤  │    │ weight (decimal) │
│ id (PK)      │◄─┼───►│ UQ(project,skill)│
│ title        │  │    └──────────────────┘
│ description  │  │
│ type         │  │    ┌──────────────────┐
│ difficulty   │  │    │  team_members    │
│ advisor_id   │  │    ├──────────────────┤
│ status(enum) │  ├───►│ user_id (FK)     │
│ timestamps   │  │    │ team_id (FK)     │
└──┬──┬──┬─────┘  │    │ role_in_team     │
   │  │  │        │    │ UQ(team,user)    │
   │  │  │        │    └───────▲──────────┘
   │  │  │        │            │
   │  │  │  ┌─────┼────────────┘
   │  │  │  │     │
   │  │  ▼  │     │
   │  │ ┌───┴──────────┐
   │  │ │    teams     │
   │  │ ├──────────────┤
   │  │ │ id (PK)      │
   │  │ │ name         │
   │  │ │ project_id   │
   │  │ │ is_approved  │
   │  │ │ timestamps   │
   │  │ └──────┬───────┘
   │  │        │
   │  │        │        ┌────────────────────┐
   │  │        └───────►│ success_estimations│
   │  │                 ├────────────────────┤
   │  │                 │ id (PK)            │
   │  ├────────────────►│ team_id (FK null)  │
   │  │                 │ user_id (FK null)  │
   │  │                 │ project_id (FK)    │
   │  │                 │ success_probability│
   │  │                 │ calculated_at      │
   │  │                 │ factors_log (JSON) │
   │  │                 └────────────────────┘
   │  │
   │  ▼
   │ ┌──────────────┐
   │ │  milestones  │
   │ ├──────────────┤
   │ │ id (PK)      │
   │ │ project_id   │
   │ │ title        │
   │ │ description  │
   │ │ estimated_days│
   │ │ order_sequence│
   │ │ timestamps   │
   │ └──────────────┘
   ▼
  ┌──────────────┐
  │    risks     │
  ├──────────────┤
  │ id (PK)      │
  │ project_id   │
  │ risk_desc    │
  │ impact_level │
  │ mitigation   │
  │ timestamps   │
  └──────────────┘
```

### ملخص العلاقات:

| العلاقة | النوع | الجدول الوسيط |
|---------|-------|---------------|
| Major -> Users | One-to-Many | - |
| User <-> Skills | Many-to-Many | `user_skills` |
| Project <-> Skills | Many-to-Many | `project_skills` |
| User <-> Teams | Many-to-Many | `team_members` |
| Project -> Teams | One-to-Many | - |
| Project -> Milestones | One-to-Many | - |
| Project -> Risks | One-to-Many | - |
| User (advisor) -> Projects | One-to-Many | - |
| Project/Team/User -> SuccessEstimations | One-to-Many | - |

---

> **نهاية التقرير** - تم إعداده في 2026-04-06
