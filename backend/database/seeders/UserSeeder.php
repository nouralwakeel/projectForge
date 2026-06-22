<?php

namespace Database\Seeders;

use App\Models\Major;
use App\Models\Skill;
use App\Models\Student;
use App\Models\StudentSkill;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $majors = Major::all();
        $skills = Skill::all();

        if ($majors->isEmpty() || $skills->isEmpty()) {
            $this->command->warn('UserSeeder: No majors or skills found. Skipping.');

            return;
        }

        Student::factory()->count(80)->create([
            'major_id' => fn () => $majors->random()->id,
        ])->each(function ($student) use ($skills) {
            $randomSkills = $skills->random(rand(3, 8));
            foreach ($randomSkills as $skill) {
                StudentSkill::create([
                    'student_id' => $student->id,
                    'skill_id' => $skill->id,
                    'proficiency_level' => rand(1, 5),
                ]);
            }
        });

        $adminUser = User::create([
            'name' => 'مدير النظام',
            'email' => 'admin@projectforge.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
        ]);

        // Advisor account used to supervise the seeded projects (ProjectSeeder
        // picks up the first advisor) and to test the team-request flow.
        $advisorUser = User::create([
            'name' => 'مشرف تجريبي',
            'email' => 'advisor@projectforge.com',
            'password' => Hash::make('password'),
            'role' => 'advisor',
        ]);

        // Known student account (with skills) for manual testing of the student
        // flow: survey, recommendations, joining a team.
        $studentUser = User::create([
            'name' => 'طالب تجريبي',
            'email' => 'student@projectforge.com',
            'password' => Hash::make('password'),
            'role' => 'student',
        ]);
        $studentProfile = Student::create([
            'user_id' => $studentUser->id,
            'stud_num' => 'STU-10001',
            'first_name' => 'طالب',
            'last_name' => 'تجريبي',
            'gender' => 'male',
            'date_of_birth' => '2001-05-15',
            'major_id' => $majors->random()->id,
        ]);
        foreach ($skills->random(min(6, $skills->count())) as $skill) {
            StudentSkill::create([
                'student_id' => $studentProfile->id,
                'skill_id' => $skill->id,
                'proficiency_level' => rand(3, 5),
            ]);
        }

        $this->command->info('UserSeeder: Created 80 students + 1 admin + 1 advisor + 1 test student.');
    }
}
