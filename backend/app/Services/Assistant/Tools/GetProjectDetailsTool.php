<?php

namespace App\Services\Assistant\Tools;

use App\Models\Project;

/**
 * Full details for a single project by id or by (partial) title — skills,
 * milestones, risks, teams with members, supervisor and status.
 */
class GetProjectDetailsTool extends Tool
{
    public function name(): string
    {
        return 'get_project_details';
    }

    public function description(): string
    {
        return 'إرجاع التفاصيل الكاملة لمشروع محدد (المهارات المطلوبة، المعالم، المخاطر، الفِرَق وأعضاؤها، المشرف، الحالة) عبر معرّف المشروع أو عنوانه.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'object',
            'properties' => [
                'project_id' => [
                    'type' => 'integer',
                    'description' => 'معرّف المشروع.',
                ],
                'title' => [
                    'type' => 'string',
                    'description' => 'عنوان المشروع أو جزء منه (يُستخدم إذا لم يُمرَّر المعرّف).',
                ],
            ],
            'required' => [],
        ];
    }

    public function handle(array $args): array
    {
        $query = Project::query()->with([
            'type',
            'supervisor',
            'skills',
            'milestones',
            'risks',
            'teams.members',
        ]);

        if (! empty($args['project_id'])) {
            $project = $query->find($args['project_id']);
        } elseif (! empty($args['title'])) {
            $project = $query->where('title', 'like', '%'.$args['title'].'%')->first();
        } else {
            return ['error' => 'يجب تمرير project_id أو title.'];
        }

        if (! $project) {
            return ['error' => 'لم يُعثر على المشروع المطلوب.'];
        }

        return [
            'id' => $project->id,
            'title' => $project->title,
            'description' => $project->description,
            'status' => $project->status,
            'difficulty_level' => $project->difficulty_level,
            'type' => $project->type?->name,
            'supervisor' => $project->supervisor?->name,
            'skills' => $project->skills->map(fn ($s) => [
                'name' => $s->name,
                'weight' => $s->pivot->weight,
            ])->all(),
            'milestones' => $project->milestones->map(fn ($m) => [
                'title' => $m->title,
                'order' => $m->order_sequence,
            ])->all(),
            'risks' => $project->risks->map(fn ($r) => [
                'description' => $r->risk_description,
                'impact_level' => $r->impact_level,
                'mitigation_plan' => $r->mitigation_plan,
            ])->all(),
            'teams' => $project->teams->map(fn ($t) => [
                'id' => $t->id,
                'name' => $t->name,
                'is_approved' => (bool) $t->is_approved,
                'members' => $t->members->map(fn ($s) => $this->formatStudentSummary($s))->all(),
            ])->all(),
        ];
    }
}
