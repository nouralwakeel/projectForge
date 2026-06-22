<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\Assistant\GeminiService;
use Illuminate\Http\Request;
use RuntimeException;

/**
 * In-app AI assistant for admins/advisors. Forwards the question to Gemini with
 * function-calling enabled so the model can query projects, students, teams and
 * the archive through the shared ToolRegistry.
 */
class AssistantController extends Controller
{
    public function chat(Request $request, GeminiService $gemini)
    {
        $validated = $request->validate([
            'message' => 'required|string|max:2000',
            'history' => 'nullable|array|max:20',
            'history.*.role' => 'nullable|string|in:user,model,assistant',
            'history.*.content' => 'required_with:history|string',
        ]);

        if (! $gemini->isConfigured()) {
            return response()->json([
                'success' => false,
                'message' => 'مساعد الذكاء الاصطناعي غير مُفعّل: لم يتم ضبط GEMINI_API_KEY.',
            ], 503);
        }

        try {
            $result = $gemini->chat($validated['message'], $validated['history'] ?? []);
        } catch (RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 502);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'reply' => $result['reply'],
                'tool_calls' => $result['tool_calls'],
            ],
        ]);
    }
}
