# ProjectForge Backend API

## المشروع

نظام إدارة مشاريع التخرج الجامعية باستخدام Laravel و Flutter

## الحالة الحالية

### ✅ ما تم إنجازه:

#### 1. قاعدة البيانات (Database)
- ✅ إنشاء جميع المايقريشنز (Migrations) بالترتيب الصحيح:
  - `majors` - التخصصات الأكاديمية
  - `users` - المستخدمين (الطلاب والمشرفين)
  - `skills` - المهارات
  - `projects` - المشاريع
  - `teams` - الفرق
  - `milestones` - المراحل التنفيذية
  - `risks` - المخاطر
  - `success_estimations` - تقييمات النجاح
  - `user_skills` - مهارات المستخدمين (Project-DNA)
  - `project_skills` - مهارات المشاريع
  - `team_members` - أعضاء الفرق

- ✅ إنشاء جميع الجداول في قاعدة البيانات

#### 2. الموديلز (Models)
- ✅ إنشاء جميع الموديلز مع العلاقات:
  - `User` - مع علاقات (Major, Skills, Teams, Projects, SuccessEstimations)
  - `Major` - مع علاقات (Users)
  - `Skill` - مع علاقات (Users, Projects)
  - `Project` - مع علاقات (Advisor, Skills, Teams, Milestones, Risks, SuccessEstimations)
  - `Team` - مع علاقات (Project, Members, SuccessEstimations)
  - `Milestone` - مع علاقات (Project)
  - `Risk` - مع علاقات (Project)
  - `SuccessEstimation` - مع علاقات (Team, User, Project)
  - `UserSkill` - مع علاقات (User, Skill)
  - `ProjectSkill` - مع علاقات (Project, Skill)
  - `TeamMember` - مع علاقات (Team, User)

#### 3. المصادقة (Authentication)
- ✅ تثبيت Laravel Sanctum
- ✅ نشر ملفات Sanctum
- ✅ تشغيل migration الخاص بـ personal_access_tokens
- ✅ إضافة HasApiTokens trait إلى User model

#### 4. Controllers
- ✅ إنشاء جميع Controllers الأساسية:
  - `AuthController` - التسجيل والدخول والخروج
  - `UserController` - إدارة المستخدمين
  - `ProjectController` - إدارة المشاريع
  - `TeamController` - إدارة الفرق
  - `SkillController` - إدارة المهارات
  - `MajorController` - إدارة التخصصات
  - `RecommendationController` - نظام التوصيات
  - `SandboxController` - نظام Sandbox
  - `SuccessEstimationController` - مقيّم النجاح

- ✅ إنشاء Form Requests:
  - `RegisterRequest`
  - `LoginRequest`
  - `UpdateSkillsRequest`
  - `StoreProjectRequest`

- ✅ تنفيذ `AuthController` بالكامل:
  - `register()` - تسجيل مستخدم جديد
  - `login()` - تسجيل الدخول
  - `logout()` - تسجيل الخروج
  - `me()` - معلومات المستخدم الحالي

### 🚧 ما يحتاج إلى إكمال:

#### 1. Controllers (محتاج إكمال)
- 🔄 إكمال تنفيذ جميع Controllers
- 🔄 إضافة المنطق البرمجي لكل endpoint

#### 2. خوارزمية التوصية (Recommendation Engine)
- ⏳ بناء نظام مطابقة المهارات مع المشاريع
- ⏳ حساب درجة التطابق (Match Score)
- ⏳ ترتيب المشاريع المقترحة

#### 3. مقيّم النجاح (Success Estimator)
- ⏳ بناء خوارزمية حساب احتمالية النجاح
- ⏳ معادلة رياضية تعتمد على:
  - مهارات الفريق
  - صعوبة المشروع
  - تغطية المهارات المطلوبة

#### 4. نظام Sandbox
- ⏳ إنشاء خطط العمل (Milestones)
- ⏳ تحديد المخاطر المحتملة (Risks)
- ⏳ توليد JSON منظم حسب نوع المشروع

#### 5. Seeders و Factories
- ⏳ إنشاء بيانات تجريبية (Mock Data):
  - تخصصات أكاديمية
  - مهارات متنوعة
  - مشاريع افتراضية
  - طلاب وهميين

#### 6. API Routes
- ⏳ تعريف جميع المسارات في `routes/api.php`

#### 7. الاختبارات
- ⏳ اختبار جميع APIs
- ⏳ التحقق من صحة البيانات

## هيكل المشروع

```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── API/
│   │   │       ├── AuthController.php ✅
│   │   │       ├── UserController.php 🔄
│   │   │       ├── ProjectController.php 🔄
│   │   │       ├── TeamController.php 🔄
│   │   │       ├── SkillController.php 🔄
│   │   │       ├── MajorController.php 🔄
│   │   │       ├── RecommendationController.php 🔄
│   │   │       ├── SandboxController.php 🔄
│   │   │       └── SuccessEstimationController.php 🔄
│   │   └── Requests/
│   │       ├── RegisterRequest.php 🔄
│   │       ├── LoginRequest.php 🔄
│   │       ├── UpdateSkillsRequest.php 🔄
│   │       └── StoreProjectRequest.php 🔄
│   └── Models/
│       ├── User.php ✅
│       ├── Major.php ✅
│       ├── Skill.php ✅
│       ├── Project.php ✅
│       ├── Team.php ✅
│       ├── Milestone.php ✅
│       ├── Risk.php ✅
│       ├── SuccessEstimation.php ✅
│       ├── UserSkill.php ✅
│       ├── ProjectSkill.php ✅
│       └── TeamMember.php ✅
├── database/
│   └── migrations/ ✅ (جميع المايقريشنز)
└── routes/
    └── api.php 🔄

Legend:
✅ = مكتمل
🔄 = يحتاج إكمال
⏳ = لم يبدأ
```

## التالي

لإكمال المشروع، يجب:

1. **إكمال Controllers**: إضافة المنطق البرمجي لكل controller
2. **بناء خوارزمية التوصية**: تنفيذ نظام المطابقة
3. **بناء مقيّم النجاح**: تنفيذ معادلة الحساب
4. **إنشاء Sandbox**: توليد خطط العمل
5. **إنشاء Seeders**: بيانات تجريبية
6. **تعريف Routes**: جميع المسارات
7. **الاختبار**: التحقق من عمل APIs

## قاعدة البيانات

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=projectforge
DB_USERNAME=root
DB_PASSWORD=
```

## التشغيل

```bash
cd backend
php artisan serve
```

## الترخيص

مشروع تخرج - ProjectForge
