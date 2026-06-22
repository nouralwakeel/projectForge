<?php

namespace App\Services\Assistant\Tools;

use App\Models\Project;

/**
 * List/search projects with optional filters. Used for general questions like
 * "ما هي المشاريع المتاحة؟" or "أعطني مشاريع المشرف فلان".
 */
class ListProjectsTool extends Tool
{
    public function name(): string
    {
        return 'list_projects';
    }

    public function description(): string
    {
        return 'إرجاع قائمة المشاريع مع إمكانية التصفية حسب الحالة أو نوع المشروع أو اسم المشرف، أو البحث بكلمة في العنوان/الوصف. مناسب للأسئلة العامة عن المشاريع الموجودة في النظام.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'object',
            'properties' => [
                'status' => [
                    'type' => 'string',
                    'enum' => ['available', 'in_progress', 'completed', 'cancelled'],
                    'description' => 'تصفية حسب حالة المشروع.',
                ],
                'project_type' => [
                    'type' => 'string',
                    'description' => 'اسم نوع المشروع (مثل: mobile_app, web_application, ai_system).',
                ],
                'supervisor' => [
                    'type' => 'string',
                    'description' => 'اسم المشرف (مطابقة جزئية).',
                ],
                'query' => [
                    'type' => 'string',
                    'description' => 'كلمة بحث في عنوان المشروع أو وصفه.',
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
        $query = Project::query()
            ->with(['type', 'supervisor'])
            ->withCount('teams');

        if (! empty($args['status'])) {
            $query->where('status', $args['status']);
        }

        if (! empty($args['project_type'])) {
            $query->whereHas('type', fn ($q) => $q->where('name', 'like', '%'.$args['project_type'].'%'));
        }

        if (! empty($args['supervisor'])) {
            $query->whereHas('supervisor', fn ($q) => $q->where('name', 'like', '%'.$args['supervisor'].'%'));
        }

        if (! empty($args['query'])) {
            $q = $args['query'];
            $query->where(function ($sub) use ($q) {
                $sub->where('title', 'like', "%{$q}%")
                    ->orWhere('description', 'like', "%{$q}%");
            });
        }

        $projects = $query->orderByDesc('created_at')
            ->limit($this->limit($args))
            ->get();

        return [
            'count' => $projects->count(),
            'projects' => $projects->map(fn ($p) => $this->formatProjectSummary($p))->all(),
        ];
    }
}
