# ProjectForge - خطة التنفيذ التفصيلية

> **تاريخ التحديث:** 2026-04-15
> **الحالة:** بعد تدقيق شامل للباك إند

---

## 1. حالة الباك إند الحالية (الفعلية بعد التدقيق)

### ما تم إنجازه بالكامل ✅

| المكون | الحالة | ملاحظات |
|--------|--------|---------|
| Database Migrations (14 ملف) | ✅ 100% | 13 جدول + cache/jobs |
| Models (11 موديل) | ✅ 100% | مع جميع العلاقات و $fillable |
| AuthController | ✅ 100% | register, login, logout, me |
| MajorController | ✅ 100% | CRUD كامل مع validation |
| SkillController | ✅ 100% | CRUD كامل مع تصفية category |
| ProjectController | ✅ 100% | CRUD كامل مع skills ربط + pagination |
| TeamController | ✅ 100% | CRUD + join() مع تحقق العضوية |
| UserController | ✅ 100% | index, show, updateSkills, getSkills |
| RecommendationController | ✅ 100% | محرك التوصية مع match score |
| SandboxController | ✅ 100% | milestones + risks تلقائية + timeline |
| SuccessEstimationController | ✅ 100% | estimate فردية + estimateTeam جماعية |
| RoleMiddleware | ✅ 100% | معالجة 401 + 403 |
| Form Requests (4 ملفات) | ✅ 100% | authorize=true + قواعد تحقق كاملة |
| routes/api.php | ✅ 100% | جميع المسارات مسجلة |
| bootstrap/app.php | ✅ 100% | api routes + middleware alias |
| UserFactory | ✅ 100% | حقول محدثة |
| MajorSeeder | ✅ 100% | 8 تخصصات |
| SkillSeeder | ✅ 100% | 40 مهارة مصنفة |
| ProjectSeeder | ✅ 100% | 10 مشاريع مع مهارات + advisor |
| DatabaseSeeder | ✅ 100% | يستدعي MajorSeeder → SkillSeeder → ProjectSeeder |

### ما زال مطلوباً 🔴

| المكون | الأولوية | ملاحظات |
|--------|----------|---------|
| إصلاح `APP_NAME` في `.env` | عالية | تغيير من `Laravel` إلى `ProjectForge` |
| UserSeeder (بيانات طلاب وهمية) | عالية | لاختبار التوصيات |
| TeamSeeder + MemberSeeder | متوسطة | فرق مع أعضاء |
| MilestoneSeeder + RiskSeeder | منخفضة | البيانات تتولد تلقائياً من Sandbox |
| Factories للموديلات الأخرى | منخفضة | MajorFactory, SkillFactory, ProjectFactory, TeamFactory |
| API Resources | متوسطة | تنسيق موحد للاستجابات |
| اختبارات PHP Unit | منخفضة | feature tests لكل endpoint |
| CORS إعدادات | عالية | ضروري لربط Flutter |
| Sanctum SPA state domains | متوسطة | إعداد stateful domains |

---

## 2. الإصلاحات المطلوبة (مرتبة حسب الأولوية)

### P0 - عاجل (قبل بدء Flutter)

#### FIX-01: تغيير APP_NAME
```
الملف: backend/.env (سطر 1)
التغيير: APP_NAME=Laravel → APP_NAME=ProjectForge
```

#### FIX-02: إعداد CORS لربط Flutter
```
المطلوب: إعداد config/cors.php أو middleware
السماح بـ: localhost, 10.0.2.2 (Android emulator), 127.0.0.1
```

#### FIX-03: إنشاء UserSeeder
```
المطلوب: توليد 50-100 طالب وهمي مع مهارات عشوائية
يعتمد على: MajorSeeder (يجب ضبط major_id)
```

#### FIX-04: إنشاء TeamSeeder
```
المطلوب: 10 فرق مع أعضاء من الطلاب المولدين
يعتمد على: ProjectSeeder + UserSeeder
```

### P1 - مهم (أثناء تطوير Flutter)

#### FIX-05: إنشاء API Resources
```
المطلوب:
- UserResource
- ProjectResource  
- TeamResource
- SkillResource
- RecommendationResource
- SuccessEstimationResource
الهدف: تنسيق موحد لاستجابات JSON
```

#### FIX-06: إضافة Pagination metadata
```
المطلوب: تنسيق موحد للاستجابات المقسمة
يستخدم: ResourceCollection أو custom wrapper
```

### P2 - لاحق

#### FIX-07: Factories للموديلات الأخرى
```
المطلوب: MajorFactory, SkillFactory, ProjectFactory, TeamFactory
```

#### FIX-08: اختبارات Feature Tests
```
المطلوب: test لكل API endpoint
الملفات: tests/Feature/
```

---

## 3. خطة بدء Flutter (التنفيذ التفصيلي)

### المرحلة 1: تأسيس المشروع (يوم 1)

#### 1.1 إنشاء المشروع
```bash
flutter create --org com.projectforge projectforge_app
cd projectforge_app
```

#### 1.2 إضافة الحزم في pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP
  dio: ^5.4.0
  
  # State Management
  get: ^4.6.6                    # GetX
  
  # Storage
  flutter_secure_storage: ^9.0.0  # تخزين آمن للـ token
  shared_preferences: ^2.2.0      # تخزين بسيط
  
  # UI
  fl_chart: ^0.68.0               # رسوم بيانية (Success Estimator)
  google_fonts: ^6.1.0            # خطوط
  flutter_svg: ^2.0.0             # أيقونات SVG
  percent_indicator: ^4.2.3       # مؤشرات دائرية (Match Score)
  
  # Utilities
  intl: ^0.19.0                   # تنسيق التواريخ
  cached_network_image: ^3.3.0    # تخزين مؤقت للصور
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

#### 1.3 هيكل المجلدات
```
lib/
├── main.dart
├── app/
│   ├── routes/
│   │   ├── app_pages.dart         # تسميات المسارات
│   │   └── app_routes.dart        # تعريفات المسارات
│   └── bindings/                  # GetX bindings
│       └── initial_binding.dart
├── config/
│   ├── api_config.dart            # Base URL + endpoints
│   ├── app_theme.dart             # ألوان + خطوط
│   └── app_constants.dart         # ثوابت عامة
├── services/
│   ├── api_service.dart           # Dio client مركزي + interceptors
│   ├── auth_service.dart          # login/register/logout/token
│   └── storage_service.dart       # secure storage wrapper
├── models/
│   ├── user_model.dart
│   ├── major_model.dart
│   ├── skill_model.dart
│   ├── project_model.dart
│   ├── team_model.dart
│   ├── milestone_model.dart
│   ├── risk_model.dart
│   ├── recommendation_model.dart
│   └── success_estimation_model.dart
├── controllers/
│   ├── auth_controller.dart       # حالة المصادقة
│   ├── skill_controller.dart      # استبيان المهارات
│   ├── project_controller.dart    # المشاريع
│   ├── recommendation_controller.dart # التوصيات
│   ├── team_controller.dart       # الفرق
│   ├── sandbox_controller.dart    # المحاكاة
│   └── estimation_controller.dart # تقدير النجاح
├── views/
│   ├── splash/
│   │   └── splash_screen.dart
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
│   ├── estimation/
│   │   └── success_estimator_screen.dart
│   ├── team/
│   │   ├── team_list_screen.dart
│   │   └── team_detail_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── widgets/
    ├── project_card.dart
    ├── skill_chip.dart
    ├── skill_slider.dart          # slider للمهارة (1-5)
    ├── milestone_timeline.dart    # عرض مراحل المشروع
    ├── success_gauge.dart         # مؤشر دائري للنجاح
    ├── match_badge.dart           # شارة نسبة التطابق
    ├── risk_card.dart
    └── loading_widget.dart
```

### المرحلة 2: البنية التحتية (يوم 2-3)

#### 2.1 api_config.dart
```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  // Android emulator → 10.0.2.2
  // iOS simulator → localhost
  // Real device → IP address of machine
  
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  
  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';
  
  // Skills
  static const String skills = '/skills';
  static const String userSkills = '/user/skills';
  
  // Projects
  static const String projects = '/projects';
  
  // Recommendations
  static const String recommendations = '/recommendations';
  
  // Teams
  static const String teams = '/teams';
  
  // Sandbox
  static String projectSandbox(int id) => '/projects/$id/sandbox';
  
  // Estimation
  static String projectEstimate(int id) => '/projects/$id/estimate';
  static String teamEstimate(int id) => '/teams/$id/estimate';
}
```

#### 2.2 api_service.dart (Dio + Interceptors)
```
المهام:
- إعداد Dio مع baseUrl و timeouts
- إضافة Token تلقائياً من SecureStorage
- معالجة 401 (إعادة توجيه لصفحة الدخول)
- معالجة الأخطاء بشكل مركزي
- Logging في وضع التطوير
```

#### 2.3 storage_service.dart
```
المهام:
- حفظ/قراءة/حذف auth token
- حفظ بيانات المستخدم الأساسية (JSON)
- التحقق من تسجيل الدخول
```

#### 2.4 auth_service.dart + auth_controller.dart
```
المهام:
- register(data) → POST /register
- login(email, password) → POST /login
- logout() → POST /logout
- getProfile() → GET /me
- إدارة حالة المستخدم (observable)
- التوجيه التلقائي (لو مسجل دخول → Dashboard)
```

### المرحلة 3: الشاشات الأساسية (يوم 4-7)

#### 3.1 Splash Screen (يوم 4)
```
- التحقق من وجود token محفوظ
- إذا يوجد → جلب بيانات المستخدم → Dashboard
- إذا لا يوجد → Login Screen
- عرض شعار ProjectForge
```

#### 3.2 Login + Register (يوم 4-5)
```
Login:
- حقل email
- حقل password
- زر تسجيل الدخول
- رابط إنشاء حساب

Register:
- student_id, first_name, last_name
- email, password, password_confirmation
- gender (male/female)
- date_of_birth (DatePicker)
- major_id (dropdown من API GET /majors)
- academic_level (1-10)
```

#### 3.3 Skills Survey - استبيان المهارات (يوم 5-6)
```
- جلب المهارات من GET /skills
- عرضها مصنفة حسب category
- لكل مهارة: slider (1-5) لمستوى الإجادة
- زر حفظ → POST /user/skills
- بعد الحفظ → الانتقال للـ Dashboard
```

#### 3.4 Dashboard (يوم 6-7)
```
- جلب التوصيات من GET /recommendations
- عرض قائمة المشاريع الموصى بها
- لكل مشروع:
  - عنوان + وصف مختصر
  - شارة نسبة التطابق (match_percentage) بألوان
    - أخضر: > 75%
    - أصفر: 50-75%
    - أحمر: < 50%
  - نوع المشروع + مستوى الصعوبة
- النقر على مشروع → ProjectDetail
```

### المرحلة 4: الشاشات المتقدمة (يوم 8-12)

#### 4.1 Project Detail (يوم 8)
```
- معلومات المشروع الكاملة
- المهارات المطلوبة مع أوزانها
- زر "عرض خطة العمل" → Sandbox
- زر "تقدير النجاح" → Estimation
- زر "إنشاء فريق" → Team
```

#### 4.2 Sandbox - خطة العمل (يوم 9)
```
- عرض Milestones كـ Timeline أفقي/عمودي
- لكل مرحلة: عنوان + وصف + مدة تقديرية
- عرض تواريخ البدء والانتهاء المحسوبة
- عرض المخاطر (Risks) كبطاقات
  - وصف المخاطر
  - مستوى التأثير (low/medium/high) بألوان
  - خطة التخفيف
- إجمالي الأيام المقدرة
```

#### 4.3 Success Estimator (يوم 10)
```
- مؤشر دائري كبير (Gauge) لاحتمالية النجاح %
- تفصيل العوامل:
  - Skill Coverage: XX%
  - Team Balance: XX%
  - Difficulty Factor: XX%
- مستوى الصعوبة للمشروع
- ألوان حسب النسبة:
  - أخضر: > 70%
  - أصفر: 40-70%
  - أحمر: < 40%
```

#### 4.4 Team Management (يوم 11)
```
- قائمة الفرق المتاحة
- إنشاء فريق جديد (اختيار مشروع)
- الانضمام لفريق موجود
- عرض تفاصيل الفريق:
  - الأعضاء + أدوارهم
  - المشروع المرتبط
  - تقدير نجاح الفريق (استدعاء estimateTeam)
```

#### 4.5 Profile (يوم 12)
```
- بيانات المستخدم الأساسية
- التخصص والمستوى الأكاديمي
- المهارات مع مستوياتها
- إمكانية تعديل المهارات
```

### المرحلة 5: الربط والتحسين (يوم 13-15)

#### 5.1 اختبار الربط الكامل
```
- اختبار جميع الـ APIs من التطبيق
- معالجة الأخطاء (network error, timeout, 4xx, 5xx)
- التأكد من عمل Token (login → use → logout → redirect)
```

#### 5.2 تحسين UI/UX
```
- Animations للانتقالات
- Loading states لكل شاشة
- Error states مع إمكانية إعادة المحاولة
- Empty states (لا توجد توصيات، لا توجد فرق)
- Pull to refresh
```

#### 5.3 الـ Theme
```
- ألوان أساسية: Primary (#2196F3), Secondary (#FF9800)
- Dark mode (اختياري)
- دعم RTL (العربية)
- خطوط مقروءة
```

---

## 4. ملخص الجدول الزمني

| الأسبوع | المهام | المخرجات |
|---------|--------|----------|
| **الأسبوع 1** | إصلاح P0 + Flutter تأسيس + بنية تحتية + Auth + Survey | Backend جاهز + Flutter login/register/survey |
| **الأسبوع 2** | Dashboard + ProjectDetail + Sandbox + Estimator | الشاشات الأساسية متصلة بالـ API |
| **الأسبوع 3** | Teams + Profile + اختبار + تحسين + APK | تطبيق كامل جاهز للعرض |

---

## 5. أوامر التشغيل

### Laravel Backend
```bash
cd backend
php artisan serve                    # تشغيل الخادم على port 8000
php artisan migrate:fresh --seed     # إعادة إنشاء قاعدة البيانات مع البيانات
```

### Flutter Frontend
```bash
cd projectforge_app
flutter pub get                      # تثبيت الحزم
flutter run                          # تشغيل على emulator/device
flutter build apk                    # بناء APK لل Android
```
