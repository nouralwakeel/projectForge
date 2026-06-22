<?php

namespace App\Services\Assistant\Tools;

use App\Models\Major;
use App\Models\Project;
use App\Models\Skill;
use App\Models\Student;
use App\Models\Team;
use App\Models\User;

/**
 * High-level counts overview of the system. Useful for "كم عدد الطلاب/المشاريع؟"
 * and dashboard-style questions.
 */
class GetStatisticsTool extends Tool
{
    public function name(): string
    {
        return 'get_statistics';
    }

    public function description(): string
    {
        return 'إحصائيات عامة عن النظام: أعداد الطلاب والمشاريع (حسب الحالة) والمجموعات والتخصصات والمهارات والمستخدمين.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'object',
            'properties' => [],
            'required' => [],
        ];
    }

    public function handle(array $args): array
    {
        return [
            'students' => Student::count(),
            'users' => User::count(),
            'advisors' => User::where('role', 'advisor')->count(),
            'admins' => User::where('role', 'admin')->count(),
            'teams' => Team::count(),
            'majors' => Major::count(),
            'skills' => Skill::count(),
            'projects' => [
                'total' => Project::count(),
                'available' => Project::where('status', 'available')->count(),
                'in_progress' => Project::where('status', 'in_progress')->count(),
                'completed' => Project::where('status', 'completed')->count(),
                'cancelled' => Project::where('status', 'cancelled')->count(),
            ],
        ];
    }
}
