<?php

namespace App\Services\Assistant\Tools;

use App\Models\Project;

/**
 * Browse the project archive — completed (and cancelled) projects from past
 * terms — optionally filtered by a keyword. Useful for "ما المشاريع السابقة
 * المشابهة؟" and reviewing historical work.
 */
class SearchArchiveTool extends Tool
{
    public function name(): string
    {
        return 'search_archive';
    }

    public function description(): string
    {
        return 'تصفّح أرشيف المشاريع (المشاريع المكتملة أو الملغاة) مع إمكانية البحث بكلمة في العنوان أو الوصف. مفيد للاطلاع على المشاريع السابقة.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'object',
            'properties' => [
                'query' => [
                    'type' => 'string',
                    'description' => 'كلمة بحث في عنوان المشروع أو وصفه.',
                ],
                'include_cancelled' => [
                    'type' => 'boolean',
                    'description' => 'تضمين المشاريع الملغاة أيضاً (افتراضي false: المكتملة فقط).',
                ],
                'limit' => [
                    'type' => 'integer',
                    'description' => 'أقصى عدد نتائج (افتراضي 20).',
                ],
            ],
            'required' => [],
        ];
    }

    public function handle(array $args): array
    {
        $statuses = ! empty($args['include_cancelled'])
            ? ['completed', 'cancelled']
            : ['completed'];

        $query = Project::query()
            ->with(['type', 'supervisor'])
            ->withCount('teams')
            ->whereIn('status', $statuses);

        if (! empty($args['query'])) {
            $kw = $args['query'];
            $query->where(function ($sub) use ($kw) {
                $sub->where('title', 'like', "%{$kw}%")
                    ->orWhere('description', 'like', "%{$kw}%");
            });
        }

        $projects = $query->orderByDesc('updated_at')
            ->limit($this->limit($args))
            ->get();

        return [
            'count' => $projects->count(),
            'archived_projects' => $projects->map(fn ($p) => $this->formatProjectSummary($p))->all(),
        ];
    }
}
