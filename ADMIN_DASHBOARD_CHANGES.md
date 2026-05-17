# تغييرات لوحة تحكم المدير - Admin Dashboard Changes

## المشكلة
عند تسجيل الدخول كأدمن على تطبيق Flutter، كان يتم توجيه المستخدم إلى نفس واجهة الطالب (الرئيسية/الاستبيان) بدلاً من لوحة تحكم خاصة بالمدير.

## التغييرات المنفذة

### 1. Backend - Laravel

#### ملف جديد: `app/Http/Controllers/API/AdminController.php`
- **`dashboard()`**: نقطة نهاية تجمع إحصائيات النظام (عدد الطلاب، المشاريع، الفرق، التخصصات، المهارات) + آخر 5 مستخدمين + آخر 5 مشاريع
- **`users()`**: عرض قائمة المستخدمين مع دعم الفلترة حسب الدور والبحث
- **`projects()`**: عرض قائمة المشاريع مع دعم الفلترة حسب الحالة
- **`deleteUser($id)`**: حذف مستخدم (مع حماية حسابات المدير من الحذف)
- **`updateProjectStatus()`**: تحديث حالة المشروع

#### تعديل: `routes/api.php`
إضافة مسارات API خاصة بالمدير ضمن middleware `role:admin`:
- `GET /admin/dashboard` → `AdminController@dashboard`
- `GET /admin/users` → `AdminController@users`
- `GET /admin/projects` → `AdminController@projects`
- `DELETE /admin/users/{id}` → `AdminController@deleteUser`
- `PUT /admin/projects/{id}/status` → `AdminController@updateProjectStatus`

#### تعديل: `app/Models/User.php`
- إضافة `name` إلى `$fillable`

#### ملف جديد: `database/migrations/2026_05_13_000001_add_name_to_users_table.php`
- إضافة عمود `name` لجدول `users` (كان مفقوداً بعد ترحيل إزالة حقول الطالب)

---

### 2. Flutter - التطبيق

#### تعديل: `lib/models/user_model.dart`
- تحديث `fromJson` لمعالجة حالة المستخدمين غير الطلاب (admin/advisor) حيث لا يوجد سجل `student` مرتبط:
  - قراءة `firstName` و `lastName` من `json['student']` إذا كان موجوداً، وإلا من المستوى الأعلى أو قيمة فارغة
  - قراءة `gender` و `dateOfBirth` و `majorId` و `academicLevel` و `studentId` من `json['student']` إذا كان موجوداً

#### تعديل: `lib/controllers/auth_controller.dart`
- إضافة دالة `_routeForUser()` تعيد المسار المناسب حسب الدور:
  - `admin` → `/admin-dashboard`
  - طالب بدون مهارات → `/survey`
  - طالب لديه مهارات → `/home`
  - مستخدم فارغ → `/login`
- تحديث `login()` ليستخدم `_routeForUser()` بدلاً من التحقق من المهارات فقط

#### تعديل: `lib/views/splash/splash_screen.dart`
- تحديث `_navigate()` للتحقق من دور المستخدم:
  - إذا `role == 'admin'` → توجيه إلى `/admin-dashboard`
  - طالب لديه مهارات → `/home`
  - طالب بدون مهارات → `/survey`
  - غير مسجل الدخول → `/login`

#### تعديل: `lib/services/auth_service.dart`
- تصحيح `logout()` لتوجيه دائماً إلى `/login` بدلاً من `/home`

#### ملف جديد: `lib/controllers/admin_dashboard_controller.dart`
- جلب بيانات لوحة التحكم من `/admin/dashboard`
- إدارة قوائم المستخدمين والمشاريع الأخيرة
- دوال الحذف للمستخدمين والمشاريع
- دوال التنقل لأقسام الإدارة

#### ملف جديد: `lib/views/admin/admin_dashboard_screen.dart`
- شاشة لوحة تحكم كاملة للمدير تتضمن:
  - رأس ترحيبي مع شارة "مدير النظام"
  - شبكة إحصائيات (الطلاب، المشاريع، الفرق، التخصصات)
  - قسم إجراءات سريعة (إدارة المستخدمين، المشاريع، التخصصات، المهارات)
  - قائمة آخر المستخدمين المسجلين مع عرض الدور والحالة
  - قائمة آخر المشاريع مع عرض حالة كل مشروع
  - دعم RTL كامل
  - تصميم متجاوب (شبكة أفقية على الشاشات الواسعة)

#### تعديل: `lib/app/routes/app_routes.dart`
- إضافة مسار `adminDashboard = '/admin-dashboard'`

#### تعديل: `lib/app/routes/app_pages.dart`
- إضافة صفحة `AdminDashboardScreen` مع `AdminDashboardController` كـ binding

#### تعديل: `lib/config/api_config.dart`
- إضافة نقاط النهاية: `adminDashboard`، `adminUsers`، `adminProjects`

#### ملفات جديدة: شاشات إدارة المدير
- **`lib/views/admin/admin_users_screen.dart`**: إدارة المستخدمين - عرض قائمة المستخدمين مع فلترة حسب الدور (طلاب/مشرفين/مديرين)، وحذف المستخدمين
- **`lib/views/admin/admin_projects_screen.dart`**: إدارة المشاريع - عرض المشاريع مع تغيير الحالة (متاح/قيد التنفيذ/مكتمل/ملغي) وحذف المشاريع
- **`lib/views/admin/admin_majors_screen.dart`**: إدارة التخصصات - عرض التخصصات مع إضافة وحذف تخصصات جديدة
- **`lib/views/admin/admin_skills_screen.dart`**: إدارة المهارات - عرض المهارات مع إضافة وحذف مهارات جديدة

#### تعديل: `lib/app/routes/app_routes.dart`
- إضافة مسارات: `adminUsers`، `adminProjects`، `adminMajors`، `adminSkills`

#### تعديل: `lib/app/routes/app_pages.dart`
- إضافة 4 صفحات GetPage جديدة لشاشات إدارة المدير

#### إصلاح تخطيط بطاقات الإجراءات السريعة
- تغيير تخطيط `_ActionCard` من أفقي (Row) إلى عمودي (Column) لمنع تداخل النصوص
- تصغير حجم الخط (label: 13, subtitle: 11)

---

## كيف يعمل التدفق الآن

1. **تسجيل دخول الأدمن**: بعد تسجيل الدخول بنجاح، يتحقق `AuthController` من `user.role`:
   - إذا `admin` → ينتقل إلى `/admin-dashboard`
   - إذا `student` بدون مهارات → ينتقل إلى `/survey`
   - إذا `student` لديه مهارات → ينتقل إلى `/home`

2. **فتح التطبيق (Splash)**: عند إعادة فتح التطبيق، يتحقق `SplashScreen` من الدور المخزن:
   - أدمن → لوحة التحكم
   - طالب → الرئيسية أو الاستبيان

3. **لوحة التحكم**: تعرض إحصائيات النظام، آخر المستخدمين والمشاريع، وإجراءات إدارية سريعة

4. **تسجيل الخروج**: يعيد المستخدم دائماً إلى شاشة تسجيل الدخول