<?php

namespace App\Services\Assistant;

use App\Models\Project;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Produces a project to-do checklist. When a Gemini key is configured it asks
 * the model for a tailored list (strict JSON); otherwise — or on any failure —
 * it falls back to a static template keyed by the project type, mirroring the
 * approach used by SandboxController for milestones/risks.
 *
 * Each item carries a risk_weight: as items are completed the project's risk
 * percentage drops proportionally to the share of weight checked off.
 */
class TodoGenerator
{
    public function isConfigured(): bool
    {
        return ! empty(config('services.gemini.key'));
    }

    /**
     * @return array<int, array{title: string, description: ?string, risk_weight: int}>
     */
    public function generate(Project $project): array
    {
        if ($this->isConfigured()) {
            try {
                $items = $this->generateWithGemini($project);
                if (! empty($items)) {
                    return $items;
                }
            } catch (\Throwable $e) {
                Log::warning('Todo generation via Gemini failed, using template', [
                    'project_id' => $project->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $this->template($project);
    }

    /**
     * @return array<int, array{title: string, description: ?string, risk_weight: int}>
     */
    private function generateWithGemini(Project $project): array
    {
        $baseUrl = rtrim((string) config('services.gemini.base_url'), '/');
        $model = (string) config('services.gemini.model');
        $url = "{$baseUrl}/models/{$model}:generateContent";

        $type = $project->type ? $project->type->name : 'مشروع برمجي';
        $prompt = <<<PROMPT
أنت مساعد لتخطيط مشاريع التخرج. ولّد قائمة مهام عملية (To-Do) لمشروع التخرج التالي.
العنوان: {$project->title}
النوع: {$type}
مستوى الصعوبة (1-5): {$project->difficulty_level}
الوصف: {$project->description}

أعد فقط مصفوفة JSON من 6 إلى 9 عناصر، كل عنصر كائن بالحقول:
- "title": عنوان المهمة بالعربية (قصير).
- "description": شرح موجز بالعربية.
- "risk_weight": عدد صحيح من 1 إلى 5 يمثّل مدى تقليل هذه المهمة لخطورة فشل المشروع (الأهم = أعلى).
رتّب المهام منطقياً من البداية إلى التسليم. لا تكتب أي نص خارج مصفوفة JSON.
PROMPT;

        $response = Http::withHeaders([
            'X-goog-api-key' => (string) config('services.gemini.key'),
            'Content-Type' => 'application/json',
        ])
            ->timeout((int) config('services.gemini.timeout', 60))
            ->post($url, [
                'contents' => [
                    ['role' => 'user', 'parts' => [['text' => $prompt]]],
                ],
                'generationConfig' => [
                    'responseMimeType' => 'application/json',
                ],
            ]);

        if ($response->failed()) {
            $detail = $response->json('error.message') ?? $response->body();
            throw new \RuntimeException("Gemini HTTP {$response->status()}: {$detail}");
        }

        $text = '';
        foreach ($response->json('candidates.0.content.parts', []) as $part) {
            $text .= $part['text'] ?? '';
        }

        $decoded = json_decode(trim($text), true);
        if (! is_array($decoded)) {
            throw new \RuntimeException('تعذّر تحليل استجابة JSON من Gemini.');
        }

        return $this->normalizeItems($decoded);
    }

    /**
     * Coerce a decoded list into clean to-do rows, dropping malformed entries.
     *
     * @param  array<int|string, mixed>  $decoded
     * @return array<int, array{title: string, description: ?string, risk_weight: int}>
     */
    private function normalizeItems(array $decoded): array
    {
        $items = [];

        foreach ($decoded as $row) {
            if (! is_array($row)) {
                continue;
            }

            $title = trim((string) ($row['title'] ?? ''));
            if ($title === '') {
                continue;
            }

            $weight = (int) ($row['risk_weight'] ?? 1);
            $weight = max(1, min(5, $weight));

            $description = isset($row['description']) ? trim((string) $row['description']) : null;

            $items[] = [
                'title' => $title,
                'description' => $description !== '' ? $description : null,
                'risk_weight' => $weight,
            ];
        }

        return $items;
    }

    /**
     * Static fallback checklist keyed by project type.
     *
     * @return array<int, array{title: string, description: ?string, risk_weight: int}>
     */
    private function template(Project $project): array
    {
        $typeName = $project->type ? $project->type->name : 'default';

        $templates = [
            'mobile_app' => [
                ['title' => 'تحديد المتطلبات الوظيفية', 'description' => 'توثيق الوظائف الأساسية والمستخدمين المستهدفين.', 'risk_weight' => 5],
                ['title' => 'تصميم واجهات UI/UX', 'description' => 'رسم نماذج الشاشات وتجربة المستخدم.', 'risk_weight' => 3],
                ['title' => 'إعداد بنية المشروع والبيئة', 'description' => 'تهيئة المستودع والأدوات والاعتماديات.', 'risk_weight' => 2],
                ['title' => 'تطوير الواجهة الأمامية', 'description' => 'بناء الشاشات والتنقّل.', 'risk_weight' => 4],
                ['title' => 'تطوير الـ Backend API', 'description' => 'بناء الخدمات وقاعدة البيانات.', 'risk_weight' => 4],
                ['title' => 'الربط والاختبار', 'description' => 'ربط الواجهات بالـ API واختبار شامل.', 'risk_weight' => 4],
                ['title' => 'النشر والتوثيق', 'description' => 'النشر على المتجر وتوثيق المشروع.', 'risk_weight' => 2],
            ],
            'web_application' => [
                ['title' => 'تحديد المتطلبات', 'description' => 'توثيق متطلبات الموقع والمستخدمين.', 'risk_weight' => 5],
                ['title' => 'تصميم الصفحات', 'description' => 'تصميم واجهات وصفحات الموقع.', 'risk_weight' => 3],
                ['title' => 'تطوير الواجهة الأمامية', 'description' => 'برمجة صفحات الموقع.', 'risk_weight' => 4],
                ['title' => 'تطوير الخادم وقاعدة البيانات', 'description' => 'بناء الـ Backend والـ API.', 'risk_weight' => 4],
                ['title' => 'مراجعة الأمان والأداء', 'description' => 'فحص الثغرات وتحسين الأداء.', 'risk_weight' => 4],
                ['title' => 'الاختبار والنشر', 'description' => 'اختبار الموقع ورفعه على الخادم.', 'risk_weight' => 3],
            ],
            'ai_system' => [
                ['title' => 'جمع وتجهيز البيانات', 'description' => 'تجميع البيانات وتنظيفها.', 'risk_weight' => 5],
                ['title' => 'تحليل واستكشاف البيانات', 'description' => 'فهم البيانات وتحديد الميزات.', 'risk_weight' => 3],
                ['title' => 'بناء النموذج', 'description' => 'تطوير نموذج التعلّم الآلي.', 'risk_weight' => 5],
                ['title' => 'التدريب والتقييم', 'description' => 'تدريب النموذج وقياس دقّته.', 'risk_weight' => 4],
                ['title' => 'بناء واجهة الاستخدام', 'description' => 'واجهة للتفاعل مع النظام.', 'risk_weight' => 3],
                ['title' => 'النشر والدمج', 'description' => 'نشر النظام وتوثيقه.', 'risk_weight' => 2],
            ],
            'default' => [
                ['title' => 'التخطيط وتحليل المتطلبات', 'description' => 'تحديد النطاق والمتطلبات.', 'risk_weight' => 5],
                ['title' => 'التصميم والهيكلة', 'description' => 'تصميم الحل والبنية.', 'risk_weight' => 3],
                ['title' => 'التطوير الأساسي', 'description' => 'بناء الوظائف الرئيسية.', 'risk_weight' => 5],
                ['title' => 'الاختبار وإصلاح الأخطاء', 'description' => 'اختبار النظام ومعالجة المشاكل.', 'risk_weight' => 4],
                ['title' => 'النشر والتوثيق', 'description' => 'تسليم المشروع وتوثيقه.', 'risk_weight' => 2],
            ],
        ];

        return $templates[$typeName] ?? $templates['default'];
    }
}
