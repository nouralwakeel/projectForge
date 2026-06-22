<?php

namespace App\Services\Assistant;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

/**
 * Thin client over the Google Generative Language API (generateContent) that
 * drives a function-calling loop: it sends the conversation together with the
 * tool declarations from ToolRegistry, executes any functionCall the model
 * requests against the database, feeds the result back, and repeats until the
 * model produces a final text answer.
 */
class GeminiService
{
    public function __construct(private ToolRegistry $registry) {}

    public function isConfigured(): bool
    {
        return ! empty(config('services.gemini.key'));
    }

    /**
     * Run a chat turn.
     *
     * @param  string  $message  The new user message.
     * @param  array<int, array{role?: string, content?: string}>  $history  Prior turns.
     * @return array{reply: string, tool_calls: array<int, array<string, mixed>>}
     */
    public function chat(string $message, array $history = []): array
    {
        if (! $this->isConfigured()) {
            throw new RuntimeException('GEMINI_API_KEY غير مضبوط في ملف البيئة.');
        }

        $contents = $this->buildHistory($history);
        $contents[] = ['role' => 'user', 'parts' => [['text' => $message]]];

        $toolCalls = [];
        $maxTurns = (int) config('services.gemini.max_tool_turns', 5);

        for ($turn = 0; $turn < $maxTurns; $turn++) {
            $candidate = $this->generateContent($contents);
            $parts = $candidate['content']['parts'] ?? [];

            $functionCalls = array_values(array_filter(
                $parts,
                fn ($part) => isset($part['functionCall'])
            ));

            // No tool calls -> the model produced its final answer.
            if (empty($functionCalls)) {
                return [
                    'reply' => $this->extractText($parts),
                    'tool_calls' => $toolCalls,
                ];
            }

            // Echo the model's function-call turn back into the conversation.
            $contents[] = ['role' => 'model', 'parts' => $parts];

            // Execute every requested tool and collect the responses.
            $responseParts = [];
            foreach ($functionCalls as $part) {
                $call = $part['functionCall'];
                $name = $call['name'] ?? '';
                $args = (array) ($call['args'] ?? []);

                $result = $this->runTool($name, $args);

                $toolCalls[] = [
                    'name' => $name,
                    'arguments' => $args,
                    'result' => $result,
                ];

                $responsePart = [
                    'functionResponse' => [
                        'name' => $name,
                        'response' => $result,
                    ],
                ];
                if (! empty($call['id'])) {
                    $responsePart['functionResponse']['id'] = $call['id'];
                }

                $responseParts[] = $responsePart;
            }

            $contents[] = ['role' => 'user', 'parts' => $responseParts];
        }

        // Tool-turn budget exhausted without a final text answer.
        return [
            'reply' => 'تعذّر إنهاء الإجابة ضمن عدد الخطوات المسموح. حاول إعادة صياغة سؤالك.',
            'tool_calls' => $toolCalls,
        ];
    }

    /**
     * Call generateContent once and return the first candidate.
     *
     * @param  array<int, mixed>  $contents
     * @return array<string, mixed>
     */
    private function generateContent(array $contents): array
    {
        $baseUrl = rtrim((string) config('services.gemini.base_url'), '/');
        $model = (string) config('services.gemini.model');
        $url = "{$baseUrl}/models/{$model}:generateContent";

        $payload = [
            'systemInstruction' => [
                'parts' => [['text' => $this->systemInstruction()]],
            ],
            'contents' => $contents,
            'tools' => [
                ['functionDeclarations' => $this->registry->geminiDeclarations()],
            ],
        ];

        $response = Http::withHeaders([
            'X-goog-api-key' => (string) config('services.gemini.key'),
            'Content-Type' => 'application/json',
        ])
            ->timeout((int) config('services.gemini.timeout', 60))
            ->post($url, $payload);

        if ($response->failed()) {
            $detail = $response->json('error.message') ?? $response->body();
            Log::warning('Gemini API request failed', ['status' => $response->status(), 'detail' => $detail]);

            throw new RuntimeException("فشل الاتصال بـ Gemini (HTTP {$response->status()}): {$detail}");
        }

        $candidate = $response->json('candidates.0');

        if (! is_array($candidate)) {
            throw new RuntimeException('استجابة غير متوقعة من Gemini (لا يوجد candidates).');
        }

        return $candidate;
    }

    /**
     * Execute a tool, converting failures into a structured error the model can
     * read instead of aborting the whole turn.
     *
     * @param  array<string, mixed>  $args
     * @return array<string, mixed>
     */
    private function runTool(string $name, array $args): array
    {
        if (! $this->registry->has($name)) {
            return ['error' => "أداة غير معروفة: {$name}"];
        }

        try {
            return $this->registry->call($name, $args);
        } catch (\Throwable $e) {
            Log::warning('Assistant tool failed', ['tool' => $name, 'error' => $e->getMessage()]);

            return ['error' => 'تعذّر تنفيذ الأداة: '.$e->getMessage()];
        }
    }

    /**
     * Map prior turns to Gemini content objects. Only user/model roles are kept.
     *
     * @param  array<int, array{role?: string, content?: string}>  $history
     * @return array<int, array<string, mixed>>
     */
    private function buildHistory(array $history): array
    {
        $contents = [];

        foreach ($history as $turn) {
            $text = trim((string) ($turn['content'] ?? ''));
            if ($text === '') {
                continue;
            }

            $role = ($turn['role'] ?? 'user') === 'model' || ($turn['role'] ?? '') === 'assistant'
                ? 'model'
                : 'user';

            $contents[] = ['role' => $role, 'parts' => [['text' => $text]]];
        }

        return $contents;
    }

    /** Concatenate all text parts of a candidate's content. */
    private function extractText(array $parts): string
    {
        $texts = array_map(
            fn ($part) => $part['text'] ?? '',
            array_filter($parts, fn ($part) => isset($part['text']))
        );

        $reply = trim(implode("\n", array_filter($texts)));

        return $reply !== '' ? $reply : 'لم أتمكن من توليد إجابة.';
    }

    private function systemInstruction(): string
    {
        return <<<'PROMPT'
أنت مساعد ذكي لنظام "ProjectForge" لإدارة مشاريع التخرج الأكاديمية. تخدم المدير والمشرف.
مهمتك مساعدتهم في الاستعلام عن الطلاب والمشاريع والمجموعات وأرشيف المشاريع.

قواعد:
- استخدم الأدوات المتاحة دائماً لجلب المعلومات من قاعدة البيانات؛ لا تخترع بيانات أو أسماء أو عناوين.
- إن لم تجد الأداة نتيجة، أخبر المستخدم بوضوح أنه لا توجد بيانات مطابقة.
- لمعرفة مشروع طالب أو عنوان مشروعه استخدم get_student_work. لاكتشاف تشابه العناوين استخدم find_similar_projects.
- أجب باللغة العربية باختصار ووضوح، ونسّق القوائم والعناوين بشكل مقروء.
PROMPT;
    }
}
