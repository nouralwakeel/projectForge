<?php

namespace App\Services\Assistant\Tools;

use App\Models\Team;

/**
 * List teams (groups) with their members and the project each is working on.
 * Optionally filter by approval state or a project keyword.
 */
class ListTeamsTool extends Tool
{
    public function name(): string
    {
        return 'list_teams';
    }

    public function description(): string
    {
        return 'إرجاع قائمة المجموعات (الفِرَق) مع أعضائها والمشروع الذي تعمل عليه كل مجموعة، مع إمكانية التصفية حسب حالة الاعتماد أو كلمة في عنوان المشروع.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'object',
            'properties' => [
                'approved' => [
                    'type' => 'boolean',
                    'description' => 'تصفية المجموعات المعتمدة (true) أو غير المعتمدة (false).',
                ],
                'project_query' => [
                    'type' => 'string',
                    'description' => 'كلمة بحث في عنوان مشروع المجموعة.',
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
        $query = Team::query()->with(['project.supervisor', 'members']);

        if (array_key_exists('approved', $args) && $args['approved'] !== null) {
            $query->where('is_approved', (bool) $args['approved']);
        }

        if (! empty($args['project_query'])) {
            $kw = $args['project_query'];
            $query->whereHas('project', fn ($q) => $q->where('title', 'like', "%{$kw}%"));
        }

        $teams = $query->orderByDesc('created_at')
            ->limit($this->limit($args))
            ->get();

        return [
            'count' => $teams->count(),
            'teams' => $teams->map(fn ($t) => [
                'id' => $t->id,
                'name' => $t->name,
                'is_approved' => (bool) $t->is_approved,
                'supervisor_status' => $t->supervisor_status,
                'project' => $t->project ? [
                    'id' => $t->project->id,
                    'title' => $t->project->title,
                    'status' => $t->project->status,
                    'supervisor' => $t->project->supervisor?->name,
                ] : null,
                'members' => $t->members->map(fn ($s) => $this->formatStudentSummary($s) + [
                    'role_in_team' => $s->pivot->role_in_team,
                ])->all(),
            ])->all(),
        ];
    }
}
