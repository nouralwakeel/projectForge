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
            'major_id' => fn() => $majors->random()->id,
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
            'email' => 'admin@projectforge.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
        ]);

        $this->command->info('UserSeeder: Created 80 students + 1 admin.');
    }
}
