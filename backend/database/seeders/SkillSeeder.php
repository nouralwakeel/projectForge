<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SkillSeeder extends Seeder
{
    public function run(): void
    {
        $skills = [
            ['name' => 'Flutter', 'category' => 'Frontend'],
            ['name' => 'Dart', 'category' => 'Programming Languages'],
            ['name' => 'React Native', 'category' => 'Frontend'],
            ['name' => 'React.js', 'category' => 'Frontend'],
            ['name' => 'Vue.js', 'category' => 'Frontend'],
            ['name' => 'Angular', 'category' => 'Frontend'],
            ['name' => 'HTML/CSS', 'category' => 'Frontend'],
            ['name' => 'JavaScript', 'category' => 'Programming Languages'],
            ['name' => 'TypeScript', 'category' => 'Programming Languages'],
            ['name' => 'Python', 'category' => 'Programming Languages'],
            ['name' => 'Java', 'category' => 'Programming Languages'],
            ['name' => 'PHP', 'category' => 'Backend'],
            ['name' => 'Laravel', 'category' => 'Backend'],
            ['name' => 'Node.js', 'category' => 'Backend'],
            ['name' => 'Express.js', 'category' => 'Backend'],
            ['name' => 'Django', 'category' => 'Backend'],
            ['name' => 'Spring Boot', 'category' => 'Backend'],
            ['name' => 'MySQL', 'category' => 'Databases'],
            ['name' => 'PostgreSQL', 'category' => 'Databases'],
            ['name' => 'MongoDB', 'category' => 'Databases'],
            ['name' => 'Redis', 'category' => 'Databases'],
            ['name' => 'Firebase', 'category' => 'Backend'],
            ['name' => 'TensorFlow', 'category' => 'AI/ML'],
            ['name' => 'PyTorch', 'category' => 'AI/ML'],
            ['name' => 'Machine Learning', 'category' => 'AI/ML'],
            ['name' => 'Deep Learning', 'category' => 'AI/ML'],
            ['name' => 'Natural Language Processing', 'category' => 'AI/ML'],
            ['name' => 'Computer Vision', 'category' => 'AI/ML'],
            ['name' => 'Git', 'category' => 'Tools'],
            ['name' => 'Docker', 'category' => 'Tools'],
            ['name' => 'Kubernetes', 'category' => 'Tools'],
            ['name' => 'AWS', 'category' => 'Cloud'],
            ['name' => 'Azure', 'category' => 'Cloud'],
            ['name' => 'Google Cloud', 'category' => 'Cloud'],
            ['name' => 'REST API Design', 'category' => 'Backend'],
            ['name' => 'GraphQL', 'category' => 'Backend'],
            ['name' => 'UI/UX Design', 'category' => 'Design'],
            ['name' => 'Figma', 'category' => 'Design'],
            ['name' => 'Agile/Scrum', 'category' => 'Soft Skills'],
            ['name' => 'Problem Solving', 'category' => 'Soft Skills'],
        ];

        foreach ($skills as $skill) {
            DB::table('skills')->updateOrInsert(
                ['name' => $skill['name']],
                ['category' => $skill['category'], 'created_at' => now(), 'updated_at' => now()]
            );
        }
    }
}
