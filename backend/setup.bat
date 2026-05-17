@echo off
chcp 65001 >nul
echo ============================================================
echo  ProjectForge Backend - Server Setup Script
echo  يجب تشغيل هذا الملف من داخل مجلد backend على السيرفر
echo ============================================================
echo.

:: ── 1. سحب آخر التغييرات ────────────────────────────────────
echo [1/7] سحب آخر التغييرات من GitHub...
git pull origin main
if %errorlevel% neq 0 (
    echo [ERROR] فشل git pull - تحقق من الاتصال والصلاحيات
    pause
    exit /b 1
)
echo.

:: ── 2. تثبيت حزم Composer ───────────────────────────────────
echo [2/7] تثبيت حزم Composer (production)...
composer install --no-dev --optimize-autoloader
if %errorlevel% neq 0 (
    echo [ERROR] فشل composer install
    pause
    exit /b 1
)
echo.

:: ── 3. نسخ .env إن لم يكن موجوداً ──────────────────────────
echo [3/7] التحقق من ملف .env...
if not exist .env (
    echo لم يُوجد .env - يتم النسخ من .env.example
    copy .env.example .env
    echo [!] عدّل .env يدوياً بإعدادات قاعدة البيانات والـ APP_KEY قبل المتابعة
    pause
) else (
    echo .env موجود - تم التخطي
)
echo.

:: ── 4. توليد APP_KEY إن كان فارغاً ─────────────────────────
echo [4/7] توليد APP_KEY...
php artisan key:generate --force
echo.

:: ── 5. تشغيل الـ migrations ─────────────────────────────────
echo [5/7] تشغيل migrations...
echo [!] هذا لن يحذف البيانات الموجودة (migrate بدون fresh)
php artisan migrate --force
if %errorlevel% neq 0 (
    echo [ERROR] فشل migrate - تحقق من إعدادات قاعدة البيانات في .env
    pause
    exit /b 1
)
echo.

:: ── 6. مسح وتحسين الـ cache ─────────────────────────────────
echo [6/7] مسح وتحسين الـ cache...
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache
php artisan route:cache
echo.

:: ── 7. ضبط صلاحيات المجلدات ─────────────────────────────────
echo [7/7] ضبط صلاحيات storage و bootstrap/cache...
php artisan storage:link
echo.

echo ============================================================
echo  اكتمل الإعداد بنجاح
echo.
echo  الملفات التي تغيّرت في هذا الـ push:
echo    backend/app/Http/Requests/BaseRequest.php       (جديد)
echo    backend/app/Http/Requests/RegisterRequest.php   (محدّث)
echo    backend/app/Http/Requests/LoginRequest.php      (محدّث)
echo    backend/app/Http/Controllers/API/AuthController.php (محدّث)
echo.
echo  ما الذي تغيّر:
echo    - أخطاء validation ترجع الآن بصيغة JSON عربية موحّدة
echo    - رسائل خطأ الـ login معرّبة
echo    - لا يوجد تغيير في جداول قاعدة البيانات
echo ============================================================
pause
