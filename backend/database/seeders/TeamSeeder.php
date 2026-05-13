<?php

namespace Database\Seeders;

use App\Models\Project;
use App\Models\Student;
use App\Models\Team;
use App\Models\TeamMember;
use Illuminate\Database\Seeder;

class TeamSeeder extends Seeder
{
    public function run(): void
    {
        $projects = Project::all();
        $students = Student::all();

        if ($projects->isEmpty() || $students->count() < 4) {
            $this->command->warn('TeamSeeder: Not enough projects or students. Skipping.');
            return;
        }

        $teamNames = [
            'Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon',
            'Zeta', 'Eta', 'Theta', 'Iota', 'Kappa',
        ];

        $usedStudents = collect();

        foreach ($projects->take(10) as $index => $project) {
            $availableStudents = $students->filter(
                fn($s) => !$usedStudents->contains($s->id)
            );

            $teamSize = rand(3, 5);

            if ($availableStudents->count() < $teamSize) {
                break;
            }

            $teamMembers = $availableStudents->random($teamSize);
            $usedStudents = $usedStudents->merge($teamMembers->pluck('id'));

            $team = Team::create([
                'name' => 'Team ' . ($teamNames[$index] ?? ($index + 1)),
                'project_id' => $project->id,
                'is_approved' => (bool) rand(0, 1),
            ]);

            foreach ($teamMembers as $memberIndex => $student) {
                TeamMember::create([
                    'team_id' => $team->id,
                    'student_id' => $student->id,
                    'role_in_team' => $memberIndex === 0 ? 'leader' : 'member',
                ]);
            }
        }

        $this->command->info('TeamSeeder: Created teams with members.');
    }
}
