<?php

namespace Database\Seeders;

use App\Models\Major;
use App\Models\Skill;
use App\Models\User;
use App\Models\UserSkill;
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

        User::factory()->count(80)->create([
            'major_id' => fn() => $majors->random()->id,
        ])->each(function ($user) use ($skills) {
            $randomSkills = $skills->random(rand(3, 8));
            foreach ($randomSkills as $skill) {
                UserSkill::create([
                    'user_id' => $user->id,
                    'skill_id' => $skill->id,
                    'proficiency_level' => rand(1, 5),
                ]);
            }
        });

        User::create([
            'student_id' => 'ADMIN-00001',
            'first_name' => 'System',
            'last_name' => 'Admin',
            'email' => 'admin@projectforge.com',
            'password' => Hash::make('password'),
            'gender' => 'male',
            'date_of_birth' => '1990-01-01',
            'major_id' => $majors->first()->id,
            'academic_level' => 10,
            'role' => 'admin',
        ]);

        $this->command->info('UserSeeder: Created 80 students + 1 admin.');
    }
}
