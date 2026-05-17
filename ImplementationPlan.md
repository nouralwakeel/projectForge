# ImplementationPlan.md — خطة إصلاح شاملة لتطبيق ProjectForge (Flutter)

> هذه الخطة تعالج جميع الأخطاء التي بلّغ عنها المستخدم وأخطاء أخرى تم اكتشافها أثناء التدقيق الكامل لشاشات الواجهة الـ 18 و9 من Controllers في `projectforge_app/`.

## ملخص المشاكل المُبلَّغ عنها مباشرة من المستخدم

| # | المشكلة | السبب الجذري | المكان |
|---|---|---|---|
| A | حقل **التخصص** فارغ ولا يعرض شيئاً | `loadMajors()` يُستدعى داخل `build()` لـ `StatelessWidget` + timeouts قصيرة جداً (5s) + رتبة تهيئة `SettingsService` (async) مقابل `ApiService` (sync) | [register_screen.dart:15-17](projectforge_app/lib/views/auth/register_screen.dart#L15-L17) ، [auth_controller.dart:18-27](projectforge_app/lib/controllers/auth_controller.dart#L18-L27) ، [api_service.dart:11-23](projectforge_app/lib/services/api_service.dart#L11-L23) |
| B | **تاريخ الميلاد** يُظهر شاشة حمراء كبيرة | `showDatePicker(locale: Locale('ar'))` يتطلب `flutter_localizations` غير مُضاف في `pubspec.yaml`، فيرمي `No MaterialLocalizations found` | [register_screen.dart:165-171](projectforge_app/lib/views/auth/register_screen.dart#L165-L171) ، [pubspec.yaml:9-32](projectforge_app/pubspec.yaml#L9-L32) |
| C | **البيانات لا تُرسل** رغم أن السيرفر يعمل | (1) خطأ التاريخ يمنع `formKey.currentState.validate()` من النجاح. (2) Timeouts 5s قصيرة على شبكة Wi-Fi محلية. (3) IP افتراضي ثابت `10.204.231.62` للـ Android. (4) `fullNameCtrl` يُقسم بـ `.split(' ')` بشكل ساذج فيكسر بعض الأسماء العربية | [api_service.dart:17-18](projectforge_app/lib/services/api_service.dart#L17-L18) ، [settings_service.dart:28](projectforge_app/lib/services/settings_service.dart#L28) ، [register_screen.dart:288-301](projectforge_app/lib/views/auth/register_screen.dart#L288-L301) |
| D | **Overflow** أسفل شاشة تسجيل الدخول | عند ظهور الكيبورد، `ConstrainedBox(minHeight: constraints.maxHeight - 32)` داخل `SingleChildScrollView` يفرض ارتفاعاً أكبر من المساحة المتاحة + `padding: EdgeInsets.all(48)` كبيرة جداً على شاشات الجوال + زر الإعدادات العائم يغطي محتوى | [login_screen.dart:42-50, 90-91](projectforge_app/lib/views/auth/login_screen.dart#L42-L91) |

---

## الإصلاحات بالترتيب — كل بند فيه: **ماذا** + **لماذا** + **كيف** + **ملف:سطر**

> اتبع الإصلاحات بالترتيب من المرحلة 0 إلى المرحلة 5. كل مرحلة قابلة للاختبار باستقلالية.

---

## المرحلة 0 — إصلاحات حرجة (15 دقيقة، تحل 80% من المشاكل المُبلَّغة)

### 0.1 إضافة `flutter_localizations` لإصلاح خطأ تاريخ الميلاد الأحمر

**لماذا:** أي استخدام لـ `showDatePicker` مع `locale: Locale('ar')` يحتاج `MaterialLocalizations` و`CupertinoLocalizations` و`GlobalLocalizations`. غياب هذه الحزمة هو السبب المباشر للشاشة الحمراء الكبيرة في حقل تاريخ الميلاد.

**كيف:**

1. عدّل [pubspec.yaml](projectforge_app/pubspec.yaml) — أضف ضمن `dependencies`:
   ```yaml
   flutter_localizations:
     sdk: flutter
   ```
2. عدّل [main.dart](projectforge_app/lib/main.dart) — أضف الاستيراد والإعدادات داخل `GetMaterialApp`:
   ```dart
   import 'package:flutter_localizations/flutter_localizations.dart';
   // ...
   GetMaterialApp(
     // ... existing props
     localizationsDelegates: const [
       GlobalMaterialLocalizations.delegate,
       GlobalCupertinoLocalizations.delegate,
       GlobalWidgetsLocalizations.delegate,
     ],
     supportedLocales: const [Locale('ar'), Locale('en')],
   )
   ```
3. شغّل `flutter pub get` من `projectforge_app/`.

**اختبار:** افتح شاشة التسجيل → اضغط حقل تاريخ الميلاد → يجب أن يفتح Date Picker بدون شاشة حمراء.

---

### 0.2 إصلاح نطاق تاريخ الميلاد

**لماذا:** الحدود الحالية `firstDate: DateTime(1970), lastDate: DateTime(2010)` تمنع أي طالب يصغر سنه عن 16 سنة من اختيار تاريخه، ولا تستخدم سنة فعلية حالية.

**كيف:** في [register_screen.dart:165-171](projectforge_app/lib/views/auth/register_screen.dart#L165-L171):
```dart
final now = DateTime.now();
final picked = await showDatePicker(
  context: context,
  initialDate: DateTime(now.year - 22, now.month, now.day),
  firstDate: DateTime(now.year - 60),
  lastDate: DateTime(now.year - 16),
  locale: const Locale('ar'),
);
```

---

### 0.3 إصلاح overflow في شاشة تسجيل الدخول

**لماذا:** عند ظهور الكيبورد على جهاز جوال:
- `ConstrainedBox(minHeight: constraints.maxHeight - 32)` يفرض ارتفاعاً مساوياً لكل الشاشة بينما الكيبورد يأخذ نصفها.
- `padding: EdgeInsets.all(48)` كبيرة جداً.
- لا يوجد `resizeToAvoidBottomInset` صريح.

**كيف:** في [login_screen.dart:31-50](projectforge_app/lib/views/auth/login_screen.dart#L31-L50) و [login_screen.dart:91](projectforge_app/lib/views/auth/login_screen.dart#L91):

```dart
return Scaffold(
  backgroundColor: AppTheme.lightColor,
  resizeToAvoidBottomInset: true,  // أضف هذا
  // ...
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          // ❌ احذف LayoutBuilder و ConstrainedBox(minHeight: ...)
          child: Stack(/* ... */)
        ),
      ),
    ),
  ),
);
```

ثم في الحاوية الرئيسية (السطر 91) قلّل padding ليتكيف:
```dart
padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 24 : 48),
```

طبّق نفس الإصلاح على [register_screen.dart:36-46](projectforge_app/lib/views/auth/register_screen.dart#L36-L46).

---

### 0.4 إصلاح ترتيب تهيئة الـ Services

**لماذا:** في [initial_binding.dart](projectforge_app/lib/app/bindings/initial_binding.dart)، `SettingsService.onInit()` يستدعي `_loadSettings()` بشكل غير متزامن (async)، لكن `ApiService.onInit()` يقرأ `settings.getBaseUrl()` فوراً قبل اكتمال التحميل من `SharedPreferences`. النتيجة: في المرات الأولى، `ApiService` يبدأ بـ IP افتراضي ثابت بدلاً من المخزّن.

**كيف:** غيّر [main.dart:8-15](projectforge_app/lib/main.dart#L8-L15) لتهيئة async قبل `runApp`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  // تأكد من تحميل الإعدادات قبل تشغيل التطبيق
  Get.put<StorageService>(StorageService(), permanent: true);
  final settings = SettingsService();
  Get.put<SettingsService>(settings, permanent: true);
  await settings.ensureLoaded();   // طريقة جديدة (أضفها للـ service)
  Get.put<ApiService>(ApiService(), permanent: true);
  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);

  runApp(const ProjectForgeApp());
}
```

ثم في [settings_service.dart](projectforge_app/lib/services/settings_service.dart):

```dart
class SettingsService extends GetxService {
  // ... existing fields
  final _loaded = Completer<void>();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> ensureLoaded() => _loaded.future;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    apiIp.value = prefs.getString(_ipKey) ?? _defaultIp();
    apiPort.value = prefs.getString(_portKey) ?? '8000';
    if (!_loaded.isCompleted) _loaded.complete();
  }
  // ...
}
```

وعدّل [initial_binding.dart](projectforge_app/lib/app/bindings/initial_binding.dart) ليكون فارغاً (التهيئة انتقلت لـ main):

```dart
class InitialBinding extends Bindings {
  @override
  void dependencies() {} // تمت التهيئة في main()
}
```

**اختبار:** غيّر IP من شاشة الإعدادات → اضغط حفظ → أعد تشغيل التطبيق → يجب أن يبقى الـ IP الجديد ويستخدم في الطلبات الأولى.

---

### 0.5 رفع timeouts الشبكة

**لماذا:** `5 seconds` غير كافية للسيرفر المحلي على شبكة WiFi بطيئة، وعند فشل أول طلب (`loadMajors`)، تبقى القائمة فارغة بدون أي رسالة للمستخدم.

**كيف:** في [api_config.dart:2-3](projectforge_app/lib/config/api_config.dart#L2-L3):

```dart
static const Duration connectTimeout = Duration(seconds: 15);
static const Duration receiveTimeout = Duration(seconds: 20);
```

---

## المرحلة 1 — إصلاح تدفق التسجيل والـ Dropdowns

### 1.1 تحويل `RegisterScreen` إلى `StatefulWidget` + نقل `loadMajors()` إلى `initState`

**لماذا:** الحالي يستخدم `StatelessWidget` ويستدعي `loadMajors()` داخل `build()`. هذا:
- يعيد إنشاء جميع `TextEditingController`s و`Rxn`s في كل rebuild → فقدان البيانات المُدخلة.
- يستدعي API call غير مرغوبة عند كل rebuild إذا كانت القائمة فارغة (بسبب فشل سابق).
- لا يستطيع dispose الـ controllers → تسريب ذاكرة.

**كيف:** أعد كتابة [register_screen.dart](projectforge_app/lib/views/auth/register_screen.dart):

```dart
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController controller = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>();
  final firstNameCtrl = TextEditingController();   // ← غيّرها لاسمين منفصلين
  final lastNameCtrl = TextEditingController();
  final studNumCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordConfirmCtrl = TextEditingController();
  final RxnString selectedGender = RxnString();
  final Rxn<DateTime> selectedDateOfBirth = Rxn<DateTime>();

  @override
  void initState() {
    super.initState();
    // استدعِ مرة واحدة، خارج build
    if (controller.majors.isEmpty) controller.loadMajors();
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    studNumCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    passwordConfirmCtrl.dispose();
    super.dispose();
  }
  // ...
}
```

### 1.2 فصل حقل "الاسم الكامل" لحقلين

**لماذا:** السطر [register_screen.dart:288-301](projectforge_app/lib/views/auth/register_screen.dart#L288-L301) يقسم `fullNameCtrl.text.trim().split(' ')` لاستخراج `first_name` و`last_name`، لكن لاسم مكون من 3 كلمات (مثل "أحمد محمد العلي") يصبح `last_name = "محمد العلي"` بشكل غير مرغوب. الباكند يتوقع حقلين منفصلين أصلاً (`required_if:role,student`).

**كيف:** غيّر `_buildLabel('الاسم الكامل')` لحقلين متتاليين: "الاسم الأول" و"الاسم الأخير". في `onTap` الزر، أرسل القيم مباشرة:

```dart
controller.register({
  'first_name': firstNameCtrl.text.trim(),
  'last_name': lastNameCtrl.text.trim(),
  'name': '${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}',
  // ... باقي الحقول
});
```

### 1.3 معالجة فشل تحميل التخصصات في الـ Controller

**لماذا:** [auth_controller.dart:24-26](projectforge_app/lib/controllers/auth_controller.dart#L24-L26) يبتلع الخطأ بـ `catch (e) { majors.clear(); }` — المستخدم لا يعرف لماذا القائمة فارغة.

**كيف:**

```dart
RxBool isMajorsLoading = false.obs;
RxString majorsError = ''.obs;

Future<void> loadMajors() async {
  isMajorsLoading.value = true;
  majorsError.value = '';
  try {
    final res = await _apiService.get(ApiConfig.majors);
    if (res.data['success'] == true) {
      majors.value = (res.data['data'] as List)
          .map((e) => MajorModel.fromJson(e)).toList();
    } else {
      majorsError.value = 'تعذر تحميل قائمة التخصصات';
    }
  } on DioException catch (e) {
    majorsError.value = e.type == DioExceptionType.connectionTimeout
        ? 'انتهت مهلة الاتصال بالخادم'
        : 'فشل الاتصال بالخادم — تحقق من الإعدادات';
  } catch (_) {
    majorsError.value = 'حدث خطأ غير متوقع';
  } finally {
    isMajorsLoading.value = false;
  }
}
```

ثم في الـ Dropdown اعرض الحالات الثلاث (تحميل، خطأ، قائمة):

```dart
Obx(() {
  if (controller.isMajorsLoading.value) {
    return const Center(child: CircularProgressIndicator());
  }
  if (controller.majorsError.isNotEmpty) {
    return Column(children: [
      Text(controller.majorsError.value, style: TextStyle(color: AppTheme.errorColor)),
      TextButton.icon(
        onPressed: controller.loadMajors,
        icon: const Icon(Icons.refresh),
        label: const Text('إعادة المحاولة'),
      ),
    ]);
  }
  return DropdownButtonFormField<int>(/* ... كما هو ... */);
})
```

### 1.4 إصلاح validator لحقل `gender`

**لماذا:** [register_screen.dart:151-156](projectforge_app/lib/views/auth/register_screen.dart#L151-L156) — الـ validator يفحص `selectedGender.value` لكنه ليس داخل `Obx` ولا داخل `Form` يُعيد التشغيل عند تغيير القيمة. عند الضغط على "إنشاء حساب"، إذا لم يختر الجنس، الـ Form قد يكون validate لكن البيانات ترسل null.

**كيف:** غيّر القيمة الافتراضية حتى يكون validator ثابتاً:

```dart
// عند بدء التسجيل، اضبط validator: (v) => v == null ? 'مطلوب' : null,
// والحقل يستخدم value: selectedGender.value داخل Obx (موجود حالياً ✓)
```

الكود الحالي صحيح من حيث المنطق لكن تحقّق أن الـ DropdownButtonFormField يستقبل `value: selectedGender.value` (إصلاح بسيط: استخدم `onChanged` + التحقق من القيمة قبل الإرسال).

---

## المرحلة 2 — إصلاح الأخطاء التي تسبب Crash (Null safety)

### 2.1 الـ Initials في `team_list_screen` و`profile_screen` و`team_detail_screen`

**لماذا:** الكود يأخذ `team.name[0]` أو `user.fullName[0]` بدون التحقق من كون النص فارغاً. إذا أعاد الباكند اسماً فارغاً (وارد جداً إذا قاعدة البيانات فيها seed data ناقصة)، التطبيق يرمي `RangeError`.

**كيف:** أنشئ helper بسيط في [lib/widgets/](projectforge_app/lib/widgets/) باسم `text_helpers.dart`:

```dart
String initials(String s) => s.trim().isEmpty ? '?' : s.trim()[0];
```

ثم استبدل في:
- [team_list_screen.dart:39](projectforge_app/lib/views/team/team_list_screen.dart#L39)
- [profile_screen.dart:31](projectforge_app/lib/views/profile/profile_screen.dart#L31)
- [team_detail_screen.dart:58-67](projectforge_app/lib/views/team/team_detail_screen.dart#L58-L67)

### 2.2 إصلاح TeamMemberModel ليطابق الـ schema الجديد

**لماذا:** [team_model.dart](projectforge_app/lib/models/team_model.dart) يحتوي `userId`، `user`، `MemberUserModel.firstName`. لكن الباكند بعد التغييرات في `migrations/2026_05_02_*` أصبح يستخدم `student_id` في جدول `team_members`، والـ relationship هو `student()` لا `user()`. حالياً [TeamController](backend/app/Http/Controllers/API/TeamController.php) قد يُرجع `members.student.first_name` بدلاً من `members.user.first_name`.

**كيف:**

1. تحقق من [TeamController](backend/app/Http/Controllers/API/TeamController.php) ماذا يُرجع فعلاً (`with('members.student')` أو `with('members.user')`).
2. عدّل [team_model.dart](projectforge_app/lib/models/team_model.dart) لتطابق الواقع:
   ```dart
   class TeamMemberModel {
     final int id;
     final int studentId;       // ← بدل userId
     final int teamId;
     final String roleInTeam;
     final MemberStudentModel? student;   // ← بدل user

     factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
       return TeamMemberModel(
         id: json['id'],
         studentId: json['student_id'] ?? 0,
         teamId: json['team_id'] ?? 0,
         roleInTeam: json['role_in_team'] ?? 'member',
         student: json['student'] != null
             ? MemberStudentModel.fromJson(json['student'])
             : null,
       );
     }
   }
   ```
3. عدّل [team_detail_screen.dart](projectforge_app/lib/views/team/team_detail_screen.dart) لاستخدام `m.student?.firstName`.

### 2.3 إصلاح الـ unsafe casts في الـ controllers

**لماذا:** الباكند يستخدم `paginate()` في `UserController::index()` (يُرجع `{data: [...], links: ..., meta: ...}`) لكن endpoints أخرى تُرجع `data` مباشرة كقائمة. النتيجة: `(data['data'] ?? data) as List` في [team_controller.dart:27](projectforge_app/lib/controllers/team_controller.dart#L27) و[project_controller.dart](projectforge_app/lib/controllers/project_controller.dart) يفشل في حالات معينة.

**كيف:** أنشئ helper في `lib/services/`:

```dart
List<Map<String, dynamic>> extractList(dynamic body) {
  if (body is List) return body.cast<Map<String, dynamic>>();
  if (body is Map) {
    if (body['data'] is List) return (body['data'] as List).cast<Map<String, dynamic>>();
    if (body['data'] is Map && body['data']['data'] is List) {
      return (body['data']['data'] as List).cast<Map<String, dynamic>>();
    }
  }
  return [];
}
```

استخدمه في كل من: [team_controller.dart:24-29](projectforge_app/lib/controllers/team_controller.dart#L24-L29)، [project_controller.dart:35](projectforge_app/lib/controllers/project_controller.dart#L35)، [skill_controller.dart:49](projectforge_app/lib/controllers/skill_controller.dart#L49)، [admin_users_screen.dart](projectforge_app/lib/views/admin/admin_users_screen.dart).

---

## المرحلة 3 — إصلاح بنية DI و State Management

### 3.1 إزالة `Get.put()` من داخل `build()` في شاشات Admin

**لماذا:** [admin_dashboard_screen.dart:14](projectforge_app/lib/views/admin/admin_dashboard_screen.dart#L14) و[admin_projects_screen.dart:11](projectforge_app/lib/views/admin/admin_projects_screen.dart#L11) ينشئون `AdminDashboardController` بـ `Get.put()` داخل `build()`. هذا ينشئ instance جديد عند كل rebuild → استدعاء `fetchDashboardData()` مرات لا حصر لها وتسريب ذاكرة.

**كيف:**

1. في [app_pages.dart](projectforge_app/lib/app/routes/app_pages.dart) — الـ binding موجود فعلاً للـ `adminDashboard` ✓. أضفه أيضاً لـ `adminProjects` و`adminUsers`:
   ```dart
   GetPage(
     name: AppRoutes.adminProjects,
     page: () => const AdminProjectsScreen(),
     binding: BindingsBuilder.put(() => AdminDashboardController()),  // مشترك
   ),
   ```
2. غيّر داخل الشاشات `Get.put(AdminDashboardController())` إلى `Get.find<AdminDashboardController>()`.

### 3.2 إصلاح race condition في `deleteUser/deleteProject`

**لماذا:** [admin_dashboard_controller.dart:42-44](projectforge_app/lib/controllers/admin_dashboard_controller.dart#L42-L44) ينفذ:
```dart
recentUsers.removeWhere(...);   // تحديث متفائل
fetchDashboardData();            // إعادة جلب يكتب فوقه
```
يسبب وميض (flicker).

**كيف:** اختر **واحداً** فقط:
```dart
await _apiService.delete('${ApiConfig.adminUsers}/$userId');
await fetchDashboardData();   // استبعد removeWhere
Get.snackbar('نجاح', 'تم حذف المستخدم');
```

### 3.3 dispose للـ TextEditingControllers في الـ dialogs

**لماذا:** [team_list_screen.dart:54](projectforge_app/lib/views/team/team_list_screen.dart#L54) ينشئ `nameCtrl` و`projectIdCtrl` داخل `showDialog` بدون dispose → تسريب ذاكرة عند فتح الـ dialog عدة مرات.

**كيف:** استخدم `StatefulBuilder` أو widget مخصص يدير الـ lifecycle:

```dart
showDialog(
  context: context,
  builder: (_) => _CreateTeamDialog(onCreate: controller.createTeam),
);

// في class مستقل:
class _CreateTeamDialog extends StatefulWidget {
  final Future<bool> Function(String, int) onCreate;
  const _CreateTeamDialog({required this.onCreate});
  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  final nameCtrl = TextEditingController();
  final projectIdCtrl = TextEditingController();
  @override
  void dispose() { nameCtrl.dispose(); projectIdCtrl.dispose(); super.dispose(); }
  // ... build
}
```

---

## المرحلة 4 — إصلاح شاشات بها mock data أو منطق ناقص

### 4.1 شاشة Home — استبدال الترحيب الثابت

**لماذا:** [dashboard_screen.dart:39](projectforge_app/lib/views/dashboard/dashboard_screen.dart#L39) يعرض `'مرحباً بك'` كنص ثابت بدلاً من اسم المستخدم.

**كيف:**
```dart
final user = Get.find<AuthService>().currentUser.value;
final greeting = user != null ? 'مرحباً، ${user.firstName}' : 'مرحباً بك';
```
وضعه داخل `Obx` لإعادة التحديث.

### 4.2 صفحة "المطابقة" في الـ HomeScreen — استبدال البيانات الوهمية

**لماذا:** [home_screen.dart:248-269](projectforge_app/lib/views/dashboard/home_screen.dart#L248-L269) يحوي `_mockSkillDemand` و`_mockTopTeam` ثابتة. الباكند يدعم endpoints حقيقية: `GET /recommendations` و`GET /teams`.

**كيف:** اربطها بـ `RecommendationController.recommendations.first` و`TeamController.teams` (موجودان فعلاً). احذف الحقول `_mockSkillDemand`/`_mockTopTeam`.

### 4.3 شاشة Success Estimator — زر "عرض التفاصيل" فارغ

**لماذا:** [success_estimator_screen.dart:338](projectforge_app/lib/views/estimation/success_estimator_screen.dart#L338) — `onPressed: () {}`.

**كيف:** اربطه بـ `Get.toNamed(AppRoutes.projectDetail.replaceAll(':id', '$projectId'))`.

### 4.4 معالجة `RecommendationController` للحالة 400 (لا توجد مهارات)

**لماذا:** [recommendation_controller.dart:30](projectforge_app/lib/controllers/recommendation_controller.dart#L30) يفحص `e.toString().contains('400')` — هش جداً، أي خطأ آخر فيه "400" يطابق.

**كيف:**
```dart
on DioException catch (e) {
  if (e.response?.statusCode == 400) {
    error.value = 'no_skills';
    Get.offAllNamed(AppRoutes.survey);
  } else {
    error.value = 'فشل في تحميل التوصيات';
  }
}
```

---

## المرحلة 5 — تحسينات UX إضافية (اختيارية)

### 5.1 إضافة `Directionality(textDirection: TextDirection.rtl)` على مستوى التطبيق

**لماذا:** بعض الشاشات تضع `Directionality` يدوياً ([home_screen.dart:137](projectforge_app/lib/views/dashboard/home_screen.dart#L137)) لكن الشاشات الأخرى (Login/Register) لا تستخدمه. النتيجة: تخطيط مختلط.

**كيف:** في [main.dart](projectforge_app/lib/main.dart):
```dart
GetMaterialApp(
  // ...
  builder: (context, child) => Directionality(
    textDirection: TextDirection.rtl,
    child: child!,
  ),
)
```
ثم احذف `Directionality` اليدوية من الشاشات الفردية.

### 5.2 إضافة `auto-fill` و`textInputAction` للحقول

في حقول البريد وكلمة المرور أضف:
```dart
TextField(
  // ...
  textInputAction: TextInputAction.next, // أو .done للأخير
  autofillHints: const [AutofillHints.email],
)
```

### 5.3 إضافة Skeleton/Shimmer أثناء التحميل بدل CircularProgressIndicator العادي

استخدم package `shimmer` أو `skeletonizer` لإعطاء شعور مهني أثناء انتظار البيانات في:
- Home → Teams Discovery
- Dashboard → Recommendations
- Project Detail

---

## خطة الاختبار (Test Plan)

نفّذها بالترتيب بعد كل مرحلة:

| # | السيناريو | المتوقع |
|---|---|---|
| T1 | افتح Register → اضغط حقل تاريخ الميلاد | يفتح Date Picker بالعربية بدون شاشة حمراء |
| T2 | افتح Register → انتظر 3 ثواني | قائمة التخصصات تظهر فيها العناصر |
| T3 | افتح Register → اقطع الـ WiFi → ادخل للشاشة | تظهر رسالة "تعذر الاتصال" + زر إعادة المحاولة بدلاً من dropdown فارغ |
| T4 | افتح Login على جوال → اضغط على حقل البريد | لا يظهر `RenderFlex overflowed by X pixels` |
| T5 | في Login → دوّر الشاشة لـ landscape | لا overflow |
| T6 | سجّل حساب جديد بنجاح | الانتقال للـ Survey بدون أخطاء |
| T7 | في Settings → غيّر IP → احفظ → أعد فتح التطبيق | يستخدم IP الجديد للطلبات الأولى (مثل loadMajors) |
| T8 | في Team List → حاول الانضمام لفريق برقم غير موجود | رسالة خطأ واضحة |
| T9 | في Admin Dashboard → احذف مستخدم | يختفي من القائمة بدون وميض |
| T10 | افتح Home → افتح Profile → ارجع | لا تكرار في استدعاءات API |

---

## ملحق: ملفات يجب تعديلها (Checklist)

- [ ] [projectforge_app/pubspec.yaml](projectforge_app/pubspec.yaml) — إضافة `flutter_localizations`
- [ ] [projectforge_app/lib/main.dart](projectforge_app/lib/main.dart) — localizations + DI سليم + Directionality
- [ ] [projectforge_app/lib/app/bindings/initial_binding.dart](projectforge_app/lib/app/bindings/initial_binding.dart) — تفريغها
- [ ] [projectforge_app/lib/services/settings_service.dart](projectforge_app/lib/services/settings_service.dart) — `ensureLoaded()`
- [ ] [projectforge_app/lib/config/api_config.dart](projectforge_app/lib/config/api_config.dart) — رفع timeouts
- [ ] [projectforge_app/lib/views/auth/register_screen.dart](projectforge_app/lib/views/auth/register_screen.dart) — Stateful + dispose + date range + first/last name
- [ ] [projectforge_app/lib/views/auth/login_screen.dart](projectforge_app/lib/views/auth/login_screen.dart) — resizeToAvoidBottomInset + padding متجاوب
- [ ] [projectforge_app/lib/controllers/auth_controller.dart](projectforge_app/lib/controllers/auth_controller.dart) — `isMajorsLoading` + `majorsError`
- [ ] [projectforge_app/lib/controllers/admin_dashboard_controller.dart](projectforge_app/lib/controllers/admin_dashboard_controller.dart) — حذف race condition
- [ ] [projectforge_app/lib/views/admin/admin_dashboard_screen.dart](projectforge_app/lib/views/admin/admin_dashboard_screen.dart) — `Get.find` بدل `Get.put`
- [ ] [projectforge_app/lib/views/admin/admin_projects_screen.dart](projectforge_app/lib/views/admin/admin_projects_screen.dart) — نفس الشيء
- [ ] [projectforge_app/lib/views/team/team_list_screen.dart](projectforge_app/lib/views/team/team_list_screen.dart) — `initials()` + dispose في dialog
- [ ] [projectforge_app/lib/views/team/team_detail_screen.dart](projectforge_app/lib/views/team/team_detail_screen.dart) — `m.student?.firstName` + `initials()`
- [ ] [projectforge_app/lib/views/profile/profile_screen.dart](projectforge_app/lib/views/profile/profile_screen.dart) — `initials()`
- [ ] [projectforge_app/lib/models/team_model.dart](projectforge_app/lib/models/team_model.dart) — `studentId` بدل `userId`
- [ ] [projectforge_app/lib/controllers/recommendation_controller.dart](projectforge_app/lib/controllers/recommendation_controller.dart) — استخدام `e.response?.statusCode`
- [ ] [projectforge_app/lib/views/dashboard/home_screen.dart](projectforge_app/lib/views/dashboard/home_screen.dart) — استبدال mock data
- [ ] [projectforge_app/lib/views/estimation/success_estimator_screen.dart](projectforge_app/lib/views/estimation/success_estimator_screen.dart) — تفعيل زر التفاصيل
- [ ] إضافة [projectforge_app/lib/widgets/text_helpers.dart](projectforge_app/lib/widgets/text_helpers.dart) — `initials()` helper

---

## ترتيب التنفيذ المقترح

1. **اليوم 1 (1 ساعة):** المرحلة 0 كاملة → اختبر T1–T3
2. **اليوم 1 (1 ساعة):** المرحلة 1 → اختبر T6
3. **اليوم 2 (1 ساعة):** المرحلة 2 → اختبر T8
4. **اليوم 2 (30 دقيقة):** المرحلة 3 → اختبر T9, T10
5. **اليوم 3 (1.5 ساعة):** المرحلة 4 + المرحلة 5 → اختبر السيناريوهات الكاملة

**الإجمالي: ~5 ساعات عمل لإصلاح كل المشاكل المُبلَّغ عنها + 15 مشكلة إضافية مكتشفة.**
