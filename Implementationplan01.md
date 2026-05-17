# خطة إصلاح مشاكل شاشة "إنشاء حساب"

## 1) الأعراض الملاحظة

- في شاشة `إنشاء حساب جديد` فقط (وليس في `تسجيل الدخول`):
  - الضغط على أي حقل نصي يفتح لوحة المفاتيح ثم تُغلق فوراً.
  - لا يمكن الاختيار من القوائم المنسدلة (الجنس، التخصص).
- في إصدار GitHub القديم لم تكن هذه المشاكل موجودة، أي أن السبب **انحدار حديث** أُدخل بعد آخر دفعة.

## 2) السبب الجذري (Root Cause)

`projectforge_app/lib/views/auth/register_screen.dart` معرّفة كـ **`StatelessWidget`**، لكنها تُنشئ كل حالة الفورم *داخل* دالة `build()` نفسها (الأسطر 18–25):

```dart
final formKey = GlobalKey<FormState>();
final fullNameCtrl = TextEditingController();
final studNumCtrl = TextEditingController();
final emailCtrl = TextEditingController();
final passwordCtrl = TextEditingController();
final passwordConfirmCtrl = TextEditingController();
final selectedGender = RxnString();
final selectedDateOfBirth = Rxn<DateTime>();
```

ماذا يحدث عند الضغط على أي حقل:

1. تظهر لوحة المفاتيح → يتغير `MediaQuery.viewInsets.bottom`.
2. `build()` تعتمد على `MediaQuery.of(context).viewInsets.bottom` (السطر 42)، لذا تُعاد طباعة الواجهة من جديد.
3. كل المتحكمات أعلاه تُنشأ **مرة ثانية كنُسخ جديدة** — يضيع التركيز، يُستبدل `TextField` الحالي بآخر له `controller` جديد، فتُغلق لوحة المفاتيح.
4. الأمر نفسه ينطبق على القوائم المنسدلة: `selectedGender` و `selectedDateOfBirth` تُستبدل بـ Rx جديدة، فيُلغى المرجع الذي كان `Obx` يستمع له، وأي اختيار يضيع فوراً.
5. `GlobalKey<FormState>()` تُنشأ هي الأخرى كل إعادة بناء → `formKey.currentState` يصبح غير صالح.

لماذا تعمل شاشة [login_screen.dart](projectforge_app/lib/views/auth/login_screen.dart)؟ لأنها `StatefulWidget`، والمتحكمات هي حقول في `_LoginScreenState` تبقى ثابتة عبر `build()`.

سبب الانحدار: التعديلات الأخيرة في الكوميت `3b810e4 fix 01 flutter` و `888e6b9 Refactor...` أعادت كتابة شاشة التسجيل بنمط StatelessWidget دون نقل الحالة إلى State.

## 3) الحل المقترح (مختصر)

تحويل `RegisterScreen` إلى `StatefulWidget` ونقل كل الحالة إلى `_RegisterScreenState`، مع `dispose` للمتحكمات.

## 4) خطوات التنفيذ بالتفصيل

### الخطوة 1 — تحويل `RegisterScreen` إلى `StatefulWidget`

في [register_screen.dart](projectforge_app/lib/views/auth/register_screen.dart):

```dart
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController controller = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>();

  final fullNameCtrl = TextEditingController();
  final studNumCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordConfirmCtrl = TextEditingController();
  final dobDisplayCtrl = TextEditingController(); // متحكم ثابت لعرض التاريخ

  String? selectedGender;
  DateTime? selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    if (controller.majors.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadMajors());
    }
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    studNumCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    passwordConfirmCtrl.dispose();
    dobDisplayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { /* ... */ }
}
```

**أهم النقاط:**
- نقل كل `TextEditingController` و `GlobalKey` لتكون حقولاً ثابتة في `State`.
- استبدال `RxnString` و `Rxn<DateTime>` بمتغيرات `String?` و `DateTime?` عاديّة (الحالة محلية للنموذج، لا حاجة لـ Rx).
- استدعاء `loadMajors()` من `initState` بعد `addPostFrameCallback` لتفادي تعديل Rx أثناء `build`.
- إضافة `dispose()` لجميع المتحكمات.

### الخطوة 2 — تعديل القوائم المنسدلة لاستخدام `setState`

استبدال `Obx(() => DropdownButtonFormField<String>(...))` الخاصة بالجنس بـ:

```dart
DropdownButtonFormField<String>(
  value: selectedGender,
  decoration: _inputDecoration(hint: 'اختر الجنس', icon: Icons.person_outline),
  items: const [
    DropdownMenuItem(value: 'male', child: Text('ذكر')),
    DropdownMenuItem(value: 'female', child: Text('أنثى')),
  ],
  onChanged: (v) => setState(() => selectedGender = v),
  validator: (_) => selectedGender == null ? 'مطلوب' : null,
),
```

أما قائمة التخصص، فتبقى ضمن `Obx` لأن `controller.majors` و `controller.selectedMajor` فعلاً مصدرها GetxController، ومراجع الـ Rx الآن ثابتة (لأنها على الـ controller الـ permanent):

```dart
Obx(() {
  final items = controller.majors
      .map((m) => DropdownMenuItem<int>(value: m.id, child: Text(m.name)))
      .toList();
  return DropdownButtonFormField<int>(
    value: controller.selectedMajor.value,
    decoration: _inputDecoration(hint: 'هندسة البرمجيات', icon: Icons.school_outlined),
    items: items,
    onChanged: items.isEmpty ? null : (v) => controller.selectedMajor.value = v,
    validator: (_) => controller.selectedMajor.value == null ? 'مطلوب' : null,
  );
}),
```

### الخطوة 3 — معالجة حقل تاريخ الميلاد

استخدام `dobDisplayCtrl` الثابت بدلاً من إنشاء `TextEditingController` جديد كل بناء:

```dart
GestureDetector(
  onTap: () async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 22, now.month, now.day),
      firstDate: DateTime(now.year - 60),
      lastDate: DateTime(now.year - 16),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        selectedDateOfBirth = picked;
        dobDisplayCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  },
  child: AbsorbPointer(
    child: TextFormField(
      controller: dobDisplayCtrl,
      decoration: _inputDecoration(hint: '2000-01-01', icon: Icons.cake_outlined),
      validator: (_) => selectedDateOfBirth == null ? 'مطلوب' : null,
    ),
  ),
),
```

### الخطوة 4 — تعديل زر إرسال الفورم

داخل `onTap` لزر "إنشاء حساب": استخدم `selectedGender`, `selectedDateOfBirth` كحقول الحالة بدلاً من `.value`:

```dart
onTap: controller.isLoading.value
    ? null
    : () {
        if (formKey.currentState!.validate()) {
          final nameParts = fullNameCtrl.text.trim().split(' ');
          final dob = selectedDateOfBirth;
          controller.register({
            'first_name': nameParts.first,
            'last_name': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            'email': emailCtrl.text,
            'password': passwordCtrl.text,
            'password_confirmation': passwordConfirmCtrl.text,
            'stud_num': studNumCtrl.text,
            'gender': selectedGender,
            'date_of_birth': dob != null
                ? '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}'
                : '',
            'major_id': controller.selectedMajor.value,
          });
        }
      },
```

### الخطوة 5 — تنظيف اختياري

- إبقاء `Obx` على زر "إنشاء حساب" يراقب `controller.isLoading` فقط — هذا صحيح.
- لا حاجة لتعديل `_inputDecoration` ولا `_buildLabel` ولا `_buildTextField`.
- إزالة `import 'package:flutter/material.dart'` غير الضرورية إن وُجدت (لا توجد حالياً).
- التأكد أن `controller.selectedMajor.value` يُعاد ضبطه عند نجاح التسجيل أو الخروج من الشاشة (تحسين مستقبلي).

## 5) خطة الاختبار

بعد التعديل، تشغيل التطبيق و:

1. الضغط على كل حقل نصي → لوحة المفاتيح تبقى مفتوحة وتسمح بالكتابة العادية.
2. الكتابة في الاسم/الرقم الجامعي/الإيميل/كلمة المرور → القيم تبقى محفوظة بعد الانتقال بين الحقول.
3. فتح قائمة الجنس → اختيار "ذكر" أو "أنثى" يُحفظ ويظهر في الحقل.
4. فتح قائمة التخصص → الاختيار يُحفظ.
5. فتح منتقي تاريخ الميلاد → التاريخ المختار يظهر في الحقل.
6. الضغط على "إنشاء حساب" بدون ملء أي حقل → تظهر رسائل التحقق "مطلوب".
7. ملء كل الحقول والضغط → الطلب يصل للـ backend بالقيم الصحيحة.
8. الانتقال من تسجيل الدخول إلى التسجيل والعودة → لا تسريب في الذاكرة (المتحكمات تُتلف).
9. تدوير الجهاز / تغيير حجم النافذة → القيم المدخلة لا تضيع.

## 6) ملفات ستُعدّل

| الملف | نوع التعديل |
|---|---|
| [projectforge_app/lib/views/auth/register_screen.dart](projectforge_app/lib/views/auth/register_screen.dart) | إعادة هيكلة من StatelessWidget إلى StatefulWidget |

لا تعديل على [auth_controller.dart](projectforge_app/lib/controllers/auth_controller.dart)، ولا على [api_service.dart](projectforge_app/lib/services/api_service.dart)، ولا على Backend — المشكلة في طبقة الواجهة فقط.

## 7) المخاطر والاعتبارات

- **لا تأثير** على الـ backend أو على واجهات API.
- **لا كسر** لأي شاشة أخرى (التعديل محصور بشاشة التسجيل).
- يجب الانتباه أن `controller.selectedMajor` Rx على `AuthController` (permanent)، أي قيمتها قد تبقى من جلسة سابقة. يُفضّل إعادة ضبطها إلى `null` في `initState` لشاشة التسجيل:

```dart
@override
void initState() {
  super.initState();
  controller.selectedMajor.value = null;
  if (controller.majors.isEmpty) {
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadMajors());
  }
}
```

## 8) ملخص قاعدة عامة

> **لا تنشئ `TextEditingController` أو `GlobalKey` داخل دالة `build()` لـ `StatelessWidget`.**
> أي ويدجِت يحتوي على إدخال نصي يجب أن يكون `StatefulWidget` تُحفظ متحكماته كحقول في `State` وتُتلف في `dispose()`.
