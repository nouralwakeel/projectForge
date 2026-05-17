# خطة إصلاح مشكلة التسجيل (Registration 422)

## 1. ملخص المشكلة

عند الضغط على "إنشاء حساب" في تطبيق Flutter يرجع الـ backend الخطأ `422 Unprocessable Entity` بدون رسالة validation واضحة، أو يفشل لاحقاً عند محاولة إنشاء سجل `Student` ببيانات ناقصة.

## 2. التشخيص

السبب الجذري في تضارب بين عقد البيانات بين الطرفين:

### أ) ما يرسله Flutter

في [register_screen.dart:316-345](projectforge_app/lib/views/auth/register_screen.dart#L316-L345) الحقول المرسلة هي:

```dart
{
  'first_name', 'last_name', 'email', 'password',
  'password_confirmation', 'stud_num', 'gender',
  'date_of_birth', 'major_id'
}
```

**ملاحظة:** لا يُرسل حقل `role` إطلاقاً.

### ب) ما يتوقعه Backend

في [RegisterRequest.php:22-27](backend/app/Http/Requests/RegisterRequest.php#L22-L27):

```php
'stud_num'      => 'required_if:role,student|...',
'first_name'    => 'required_if:role,student|...',
'last_name'     => 'required_if:role,student|...',
'gender'        => 'required_if:role,student|in:male,female',
'date_of_birth' => 'required_if:role,student|date',
'major_id'      => 'required_if:role,student|exists:majors,id',
```

### ج) كيف تتسلسل الأخطاء

1. لأن `role` غير موجود في الـ payload، شرط `required_if:role,student` **لا يتحقق** — Laravel يعتبر أن قيمة `role` لا تساوي `student`، فيتخطى التحقق ويسمح بمرور الطلب حتى لو كانت الحقول فارغة.
2. ثم في [AuthController.php:18](backend/app/Http/Controllers/API/AuthController.php#L18):
   ```php
   $role = $request->role ?? 'student';  // fallback to student
   ```
3. ثم في [AuthController.php:30-40](backend/app/Http/Controllers/API/AuthController.php#L30-L40) يحاول إنشاء `Student` ببيانات لم يتم التحقق منها → فشل في DB (NOT NULL / foreign key / unique) → 422 أو 500.
4. حقل `name` في [RegisterRequest.php:18](backend/app/Http/Requests/RegisterRequest.php#L18) معرّف كـ `required_unless:role,student` — يطلبه فقط للأدوار الأخرى، لكن المنطق غير منسجم مع باقي القواعد.

### د) إضافة: قاعدة `name`

التطبيق لا يرسل `name` بل يبنيه الـ controller من `first_name + last_name` ([AuthController.php:19-21](backend/app/Http/Controllers/API/AuthController.php#L19-L21))، فالقاعدة الحالية `required_unless:role,student` غير مؤذية الآن لكنها مربكة ولا داعي لها على هذا الـ endpoint.

## 3. القرار

الـ API هذا (`POST /v1/register`) مخصص حصراً لتسجيل **الطلاب** من تطبيق Flutter. إنشاء المشرفين والإداريين يتم من لوحة الإدارة لاحقاً عبر endpoint منفصل (أو seeder). إذن:

- **نختار الحل B (الذي اقترحته):** نزيل `required_if:role,student` ونجعل الحقول `required` ثابتة.
- لا نضيف `role` إلى payload الـ Flutter (نُبقي السلوك الحالي حيث `AuthController` يفترض `student` افتراضياً).
- نُبقي `role` كحقل `sometimes|in:...` للسماح بالتوسعة المستقبلية إذا أُضيف endpoint إداري يستخدم نفس الـ FormRequest، لكن لو ظهر هذا السيناريو لاحقاً يجب فصل `AdminRegisterRequest` بدل إعادة إدخال `required_if`.

## 4. التعديلات المطلوبة

### تعديل واحد فقط: [backend/app/Http/Requests/RegisterRequest.php](backend/app/Http/Requests/RegisterRequest.php)

استبدل دالة `rules()` بالكامل:

```php
public function rules(): array
{
    return [
        'email'                 => 'required|email|unique:users,email',
        'password'              => 'required|string|min:8|confirmed',
        'role'                  => 'sometimes|in:student,advisor,admin',
        'stud_num'              => 'required|string|unique:students,stud_num',
        'first_name'            => 'required|string|max:255',
        'last_name'             => 'required|string|max:255',
        'gender'                => 'required|in:male,female',
        'date_of_birth'         => 'required|date|before:today',
        'major_id'              => 'required|exists:majors,id',
    ];
}
```

**ما الذي تغيّر:**

| الحقل | قبل | بعد |
|------|-----|-----|
| `name` | `required_unless:role,student\|...` | **محذوف** (الـ controller يبنيه من first/last) |
| `stud_num` | `required_if:role,student\|...` | `required\|...` |
| `first_name` | `required_if:role,student\|...` | `required\|...` |
| `last_name` | `required_if:role,student\|...` | `required\|...` |
| `gender` | `required_if:role,student\|in:...` | `required\|in:...` |
| `date_of_birth` | `required_if:role,student\|date` | `required\|date\|before:today` |
| `major_id` | `required_if:role,student\|exists:...` | `required\|exists:...` |
| `role` | `sometimes\|in:...` | بدون تغيير |
| `email`, `password` | بدون تغيير | بدون تغيير |

> إضافة `before:today` لـ `date_of_birth` حماية إضافية لمنع تواريخ مستقبلية (Flutter بالفعل يقيّد عبر `lastDate` لكن نضمنها على الـ backend).

### لا تعديل على Flutter

[register_screen.dart](projectforge_app/lib/views/auth/register_screen.dart) و[auth_controller.dart](projectforge_app/lib/controllers/auth_controller.dart) لا تحتاج أي تغيير — الـ payload الحالي مطابق للقواعد الجديدة.

### لا تعديل على AuthController

[AuthController.php](backend/app/Http/Controllers/API/AuthController.php) يبقى كما هو. منطق `$role = $request->role ?? 'student'` يظل صحيحاً ويعمل مع القواعد الجديدة.

## 5. خطة التحقق

### أ) اختبار يدوي

1. تشغيل الخادم: `php artisan serve --host=0.0.0.0 --port=8000` من [backend/](backend/).
2. تشغيل Flutter: `flutter run` من [projectforge_app/](projectforge_app/).
3. **حالة النجاح (الطريق الذهبي):**
   - فتح شاشة التسجيل، تعبئة كل الحقول ببيانات صحيحة، الضغط على إنشاء حساب.
   - متوقع: `201 Created` + إنشاء `User` بـ `role=student` + سجل `Student` مرتبط + token.
4. **حالات الفشل المتوقعة (يجب أن يرد 422 برسائل واضحة):**
   - بريد مكرر → `email has already been taken`.
   - رقم جامعي مكرر → `stud_num has already been taken`.
   - `major_id` غير موجود → `selected major_id is invalid`.
   - كلمة مرور أقل من 8 أحرف → رسالة الحد الأدنى.
   - `password_confirmation` لا يطابق `password` → رسالة `confirmed`.
   - حذف أي حقل مطلوب من خلال curl/Postman → `field is required` (هذا هو الإصلاح الفعلي — قبلاً كان يمرّ).

### ب) فحص curl للـ regression

```bash
# يجب أن يفشل بـ 422 (قبل الإصلاح كان يمرّ ويفشل لاحقاً في DB)
curl -X POST http://localhost:8000/api/v1/register \
  -H "Content-Type: application/json" \
  -d '{"email":"a@b.com","password":"12345678","password_confirmation":"12345678"}'

# يجب أن ينجح
curl -X POST http://localhost:8000/api/v1/register \
  -H "Content-Type: application/json" \
  -d '{
    "email":"new@uni.edu","password":"12345678","password_confirmation":"12345678",
    "stud_num":"20260999","first_name":"أحمد","last_name":"المحمد",
    "gender":"male","date_of_birth":"2002-05-10","major_id":1
  }'
```

> تأكد قبل التشغيل أن البذور تمت: `php artisan migrate:fresh --seed` لضمان وجود majors بـ id=1.

## 6. مخاطر وملاحظات

- **هل يكسر هذا أي مستهلك آخر للـ endpoint؟** لا — الـ endpoint مستخدم فقط من Flutter app الذي يرسل بالفعل كل الحقول المطلوبة. لا يوجد admin/advisor registration حالياً (تحقق من [routes/api.php](backend/routes/api.php) — مسار `/register` واحد عام).
- **إذا أُضيف لاحقاً endpoint لتسجيل المشرفين/الإداريين:** أنشئ `AdminCreateUserRequest` منفصلاً بدل إعادة `required_if` هنا — هذا يحافظ على وضوح كل request بمسؤوليته.
- **لا تغيير على الـ migrations أو الـ models** — الـ schema سليم، المشكلة كانت في طبقة الـ validation فقط.

## 7. ملخص الخطوات للتنفيذ

1. تعديل [backend/app/Http/Requests/RegisterRequest.php](backend/app/Http/Requests/RegisterRequest.php) كما في القسم 4.
2. (اختياري) تشغيل `./vendor/bin/pint` لتنسيق الملف.
3. اختبار يدوي عبر Flutter + curl كما في القسم 5.
4. عمل commit برسالة: `fix(auth): make student registration fields strictly required`.
