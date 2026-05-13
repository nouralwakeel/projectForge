@echo off
chcp 65001 >nul
echo ============================================
echo   ProjectForge - Laravel Server
echo   Starting on 0.0.0.0:8000
echo ============================================
echo.
cd /d "%~dp0backend"
if not exist artisan (
    echo [ERROR] artisan file not found in backend directory!
    pause
    exit /b 1
)
echo [INFO] Running: php artisan serve --host=0.0.0.0 --port=8000
echo [INFO] Press Ctrl+C to stop the server
echo.
php artisan serve --host=0.0.0.0 --port=8000
pause
