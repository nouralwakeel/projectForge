<?php

namespace App\Services\Assistant\Tools;

use App\Models\Student;

/**
 * Given a student (name / student number / email), return what they are working
 * on: their team(s), the project(s) those teams belong to, the project title(s),
 * their role in the team and the project supervisor.
 *
 * Answers the manager questions: "شو مشروع الطالب فلان؟"، "شو عنوان مشروع الطالب
 * صاحب الرقم الجامعي 123؟".
 */
class GetStudentWorkTool extends Tool
{
    public function name(): string
    {
        return 'get_student_work';
    }

    public function description(): string
    {
        return 'معرفة ما يعمل عليه طالب محدد: فِرَقه ومشاريعها وعناوينها ودوره في الفريق والمشرف على المشروع. يُحدَّد الطالب بالاسم أو الرقم الجامعي أو البريد. هذه الأداة هي الأنسب لأسئلة "ما مشروع الطالب فلان" و"ما عنوان مشروعه".';
    }

    public function parameters(): array
    {
        return [
            'type' => 'object',
            'properties' => [
                'student_query' => [
                    'type' => 'string',
                    'description' => 'تعريف الطالب: اسم كامل أو جزء منه، أو رقم جامعي، أو بريد إلكتروني.',
                ],
            ],
            'required' => ['student_query'],
        ];
    }

    public function handle(array $args): array
    {
        $term = trim((string) ($args['student_query'] ?? ''));

        if ($term === '') {
            return ['error' => 'تعريف الطالب (student_query) مطلوب.'];
        }

        $tokens = array_filter(preg_split('/\s+/', $term));

        $students = Student::query()
            ->with([
                'major',
                'user',
                'teams.project.supervisor',
                'teams.project.type',
            ])
            ->where(function ($q) use ($term, $tokens) {
                $q->where('stud_num', 'like', "%{$term}%")
                    ->orWhere('first_name', 'like', "%{$term}%")
                    ->orWhere('last_name', 'like', "%{$term}%")
                    ->orWhereHas('user', fn ($u) => $u->where('email', 'like', "%{$term}%"));

                if (count($tokens) > 1) {
                    $q->orWhere(function ($sub) use ($tokens) {
                        foreach ($tokens as $token) {
                            $sub->where(function ($inner) use ($token) {
                                $inner->where('first_name', 'like', "%{$token}%")
                                    ->orWhere('last_name', 'like', "%{$token}%");
                            });
                        }
                    });
                }
            })
            ->limit(10)
            ->get();

        if ($students->isEmpty()) {
            return ['error' => "لم يُعثر على طالب مطابق لـ \"{$term}\"."];
        }

        $matches = $students->map(function (Student $student) {
            $teams = $student->teams->map(function ($team) {
                $project = $team->project;

                return [
                    'team_id' => $team->id,
                    'team_name' => $team->name,
                    'role_in_team' => $team->pivot->role_in_team,
                    'project' => $project ? [
                        'id' => $project->id,
                        'title' => $project->title,
                        'status' => $project->status,
                        'type' => $project->type?->name,
                        'supervisor' => $project->supervisor?->name,
                    ] : null,
                ];
            })->all();

            return $this->formatStudentSummary($student) + [
                'email' => $student->user?->email,
                'is_working_on_project' => count($teams) > 0,
                'teams' => $teams,
            ];
        })->all();

        return [
            'count' => count($matches),
            'students' => $matches,
        ];
    }
}
