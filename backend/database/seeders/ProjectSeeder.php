<?php

namespace Database\Seeders;

use App\Models\Project;
use App\Models\ProjectSkill;
use App\Models\ProjectType;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProjectSeeder extends Seeder
{
    public function run(): void
    {
        $advisor = User::where('role', 'advisor')->first();

        if (!$advisor) {
            $advisor = User::create([
                'email' => 'advisor@example.com',
                'password' => bcrypt('password'),
                'role' => 'advisor',
            ]);
        }

        $typeMap = ProjectType::pluck('id', 'name');

        $projects = [
            [
                'title' => 'تطبيق إدارة المهام اليومية',
                'description' => 'تطبيق موبايل لإدارة المهام اليومية مع إشعارات وتقارير إحصائية',
                'type_name' => 'mobile_app',
                'difficulty_level' => 3,
                'skills' => [
                    ['name' => 'Flutter', 'weight' => 0.4],
                    ['name' => 'Dart', 'weight' => 0.3],
                    ['name' => 'Firebase', 'weight' => 0.3],
                ]
            ],
            [
                'title' => 'منصة تعليمية تفاعلية',
                'description' => 'منصة ويب للتعليم الإلكتروني مع محتوى تفاعلي واختبارات',
                'type_name' => 'web_application',
                'difficulty_level' => 4,
                'skills' => [
                    ['name' => 'React.js', 'weight' => 0.3],
                    ['name' => 'Node.js', 'weight' => 0.3],
                    ['name' => 'MongoDB', 'weight' => 0.2],
                    ['name' => 'UI/UX Design', 'weight' => 0.2],
                ]
            ],
            [
                'title' => 'نظام توصية ذكي للمطاعم',
                'description' => 'نظام توصية باستخدام التعلم الآلي لاقتراح المطاعم للمستخدمين',
                'type_name' => 'ai_system',
                'difficulty_level' => 5,
                'skills' => [
                    ['name' => 'Python', 'weight' => 0.3],
                    ['name' => 'Machine Learning', 'weight' => 0.3],
                    ['name' => 'TensorFlow', 'weight' => 0.2],
                    ['name' => 'Django', 'weight' => 0.2],
                ]
            ],
            [
                'title' => 'نظام إدارة المستشفى',
                'description' => 'نظام متكامل لإدارة المواعيد والسجلات الطبية والفواتير',
                'type_name' => 'web_application',
                'difficulty_level' => 4,
                'skills' => [
                    ['name' => 'Laravel', 'weight' => 0.35],
                    ['name' => 'Vue.js', 'weight' => 0.35],
                    ['name' => 'MySQL', 'weight' => 0.3],
                ]
            ],
            [
                'title' => 'تطبيق توصيل طعام',
                'description' => 'تطبيق موبايل لتوصيل الطعام مع تتبع الطلبات والدفع الإلكتروني',
                'type_name' => 'mobile_app',
                'difficulty_level' => 4,
                'skills' => [
                    ['name' => 'React Native', 'weight' => 0.35],
                    ['name' => 'Node.js', 'weight' => 0.3],
                    ['name' => 'MongoDB', 'weight' => 0.2],
                    ['name' => 'REST API Design', 'weight' => 0.15],
                ]
            ],
            [
                'title' => 'نظام تحليل المشاعر',
                'description' => 'نظام ذكاء اصطناعي لتحليل مشاعر النصوص والتعليقات',
                'type_name' => 'ai_system',
                'difficulty_level' => 5,
                'skills' => [
                    ['name' => 'Python', 'weight' => 0.3],
                    ['name' => 'Natural Language Processing', 'weight' => 0.3],
                    ['name' => 'Deep Learning', 'weight' => 0.2],
                    ['name' => 'PyTorch', 'weight' => 0.2],
                ]
            ],
            [
                'title' => 'منصة تجارة إلكترونية',
                'description' => 'متجر إلكتروني متكامل مع سلة التسوق وإدارة المنتجات',
                'type_name' => 'web_application',
                'difficulty_level' => 4,
                'skills' => [
                    ['name' => 'Laravel', 'weight' => 0.3],
                    ['name' => 'React.js', 'weight' => 0.3],
                    ['name' => 'MySQL', 'weight' => 0.2],
                    ['name' => 'UI/UX Design', 'weight' => 0.2],
                ]
            ],
            [
                'title' => 'تطبيق تتبع اللياقة البدنية',
                'description' => 'تطبيق موبايل لتتبع التمارين والسعرات الحرارية',
                'type_name' => 'mobile_app',
                'difficulty_level' => 3,
                'skills' => [
                    ['name' => 'Flutter', 'weight' => 0.4],
                    ['name' => 'Firebase', 'weight' => 0.3],
                    ['name' => 'Dart', 'weight' => 0.3],
                ]
            ],
            [
                'title' => 'نظام التعرف على الوجوه',
                'description' => 'نظام ذكاء اصطناعي للتعرف على الوجوه للأمن والتحقق',
                'type_name' => 'ai_system',
                'difficulty_level' => 5,
                'skills' => [
                    ['name' => 'Python', 'weight' => 0.25],
                    ['name' => 'Computer Vision', 'weight' => 0.3],
                    ['name' => 'Deep Learning', 'weight' => 0.25],
                    ['name' => 'OpenCV', 'weight' => 0.2],
                ]
            ],
            [
                'title' => 'نظام إدارة المكتبة',
                'description' => 'نظام لإدارة الكتب والاستعارات والأعضاء في المكتبة',
                'type_name' => 'web_application',
                'difficulty_level' => 3,
                'skills' => [
                    ['name' => 'PHP', 'weight' => 0.3],
                    ['name' => 'MySQL', 'weight' => 0.3],
                    ['name' => 'HTML/CSS', 'weight' => 0.2],
                    ['name' => 'JavaScript', 'weight' => 0.2],
                ]
            ],
        ];

        foreach ($projects as $projectData) {
            $project = Project::create([
                'title' => $projectData['title'],
                'description' => $projectData['description'],
                'type_id' => $typeMap[$projectData['type_name']] ?? null,
                'difficulty_level' => $projectData['difficulty_level'],
                'supervisor_id' => $advisor->id,
                'status' => 'available',
            ]);

            foreach ($projectData['skills'] as $skillData) {
                $skill = DB::table('skills')->where('name', $skillData['name'])->first();

                if ($skill) {
                    ProjectSkill::create([
                        'project_id' => $project->id,
                        'skill_id' => $skill->id,
                        'weight' => $skillData['weight'],
                    ]);
                }
            }
        }
    }
}
