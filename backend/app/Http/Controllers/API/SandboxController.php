<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Milestone;
use App\Models\Project;
use App\Models\Risk;
use Illuminate\Http\Request;

class SandboxController extends Controller
{
    public function getSandbox($projectId)
    {
        $project = Project::with(['milestones', 'risks', 'skills'])->find($projectId);

        if (!$project) {
            return response()->json([
                'success' => false,
                'message' => 'Project not found'
            ], 404);
        }

        if ($project->milestones->isEmpty()) {
            $this->generateMilestones($project);
            $project->load('milestones');
        }

        if ($project->risks->isEmpty()) {
            $this->generateRisks($project);
            $project->load('risks');
        }

        $timeline = $this->buildTimeline($project);

        return response()->json([
            'success' => true,
            'data' => [
                'project' => $project,
                'timeline' => $timeline,
                'total_estimated_days' => $project->milestones->sum('estimated_days')
            ]
        ]);
    }

    private function generateMilestones($project)
    {
        $milestonesData = $this->getMilestonesTemplate($project->type);

        foreach ($milestonesData as $index => $milestoneData) {
            Milestone::create([
                'project_id' => $project->id,
                'title' => $milestoneData['title'],
                'description' => $milestoneData['description'],
                'estimated_days' => $milestoneData['estimated_days'],
                'order_sequence' => $index + 1
            ]);
        }
    }

    private function generateRisks($project)
    {
        $risksData = $this->getRisksTemplate($project->type, $project->difficulty_level);

        foreach ($risksData as $riskData) {
            Risk::create([
                'project_id' => $project->id,
                'risk_description' => $riskData['description'],
                'impact_level' => $riskData['impact'],
                'mitigation_plan' => $riskData['mitigation']
            ]);
        }
    }

    private function getMilestonesTemplate($type)
    {
        $templates = [
            'mobile_app' => [
                ['title' => 'تحليل المتطلبات', 'description' => 'تحديد متطلبات التطبيق والوظائف الأساسية', 'estimated_days' => 7],
                ['title' => 'تصميم UI/UX', 'description' => 'تصميم واجهات المستخدم وتجربة المستخدم', 'estimated_days' => 10],
                ['title' => 'بناء الواجهات الأمامية', 'description' => 'تطوير شاشات وواجهات التطبيق', 'estimated_days' => 14],
                ['title' => 'بناء Backend API', 'description' => 'تطوير الخادم والواجهات البرمجية', 'estimated_days' => 14],
                ['title' => 'الربط والاختبار', 'description' => 'ربط الواجهات بالخادم واختبار التطبيق', 'estimated_days' => 7],
                ['title' => 'النشر', 'description' => 'نشر التطبيق على المتاجر', 'estimated_days' => 3],
            ],
            'web_application' => [
                ['title' => 'تحليل المتطلبات', 'description' => 'تحديد متطلبات الموقع والوظائف', 'estimated_days' => 5],
                ['title' => 'تصميم الموقع', 'description' => 'تصميم واجهات وصفحات الموقع', 'estimated_days' => 7],
                ['title' => 'برمجة Frontend', 'description' => 'تطوير الواجهة الأمامية للموقع', 'estimated_days' => 12],
                ['title' => 'برمجة Backend', 'description' => 'تطوير الخادم وقاعدة البيانات', 'estimated_days' => 12],
                ['title' => 'اختبار وتحسين', 'description' => 'اختبار الموقع وإصلاح الأخطاء', 'estimated_days' => 5],
                ['title' => 'النشر', 'description' => 'رفع الموقع على الخادم', 'estimated_days' => 2],
            ],
            'ai_system' => [
                ['title' => 'جمع البيانات', 'description' => 'جمع وتجهيز البيانات المطلوبة', 'estimated_days' => 10],
                ['title' => 'تحليل واستكشاف البيانات', 'description' => 'تحليل البيانات وتنظيفها', 'estimated_days' => 7],
                ['title' => 'بناء النموذج', 'description' => 'تطوير نموذج الذكاء الاصطناعي', 'estimated_days' => 14],
                ['title' => 'تدريب وتقييم', 'description' => 'تدريب النموذج وتقييم أدائه', 'estimated_days' => 10],
                ['title' => 'بناء واجهة المستخدم', 'description' => 'تطوير واجهة للتفاعل مع النظام', 'estimated_days' => 10],
                ['title' => 'النشر', 'description' => 'نشر النظام ودمجه', 'estimated_days' => 5],
            ],
            'default' => [
                ['title' => 'التخطيط والتحليل', 'description' => 'تحليل المتطلبات والتخطيط', 'estimated_days' => 7],
                ['title' => 'التصميم', 'description' => 'تصميم الحلول والهيكلة', 'estimated_days' => 10],
                ['title' => 'التطوير', 'description' => 'بناء وتطوير النظام', 'estimated_days' => 21],
                ['title' => 'الاختبار', 'description' => 'اختبار النظام وإصلاح الأخطاء', 'estimated_days' => 7],
                ['title' => 'النشر والتوثيق', 'description' => 'نشر النظام وتوثيق المشروع', 'estimated_days' => 5],
            ]
        ];

        return $templates[$type] ?? $templates['default'];
    }

    private function getRisksTemplate($type, $difficultyLevel)
    {
        $baseRisks = [
            'mobile_app' => [
                ['description' => 'تغير المتطلبات أثناء التطوير', 'impact' => 'medium', 'mitigation' => 'الالتزام بمنهجية Agile وإدارة التغيير'],
                ['description' => 'مشاكل التوافق مع الأجهزة المختلفة', 'impact' => 'medium', 'mitigation' => 'اختبار على أجهزة متنوعة'],
                ['description' => 'صعوبة في تكامل APIs خارجية', 'impact' => 'low', 'mitigation' => 'دراسة التوثيق جيداً واختبار مبكر'],
            ],
            'web_application' => [
                ['description' => 'مشاكل أداء الموقع', 'impact' => 'high', 'mitigation' => 'تحسين الاستعلامات واستخدام التخزين المؤقت'],
                ['description' => 'ثغرات أمنية', 'impact' => 'high', 'mitigation' => 'مراجعة أمنية واختبار الاختراق'],
                ['description' => 'مشاكل توافق المتصفحات', 'impact' => 'medium', 'mitigation' => 'اختبار على متصفحات متعددة'],
            ],
            'ai_system' => [
                ['description' => 'جودة البيانات غير كافية', 'impact' => 'high', 'mitigation' => 'تنظيف البيانات واستخدام مصادر موثوقة'],
                ['description' => 'أداء النموذج أقل من المتوقع', 'impact' => 'medium', 'mitigation' => 'تجربة خوارزميات مختلفة وتحسين المعاملات'],
                ['description' => 'صعوبة تفسير النتائج', 'impact' => 'low', 'mitigation' => 'توثيق واضح وواجهة سهلة'],
            ],
            'default' => [
                ['description' => 'تأخر في الجدول الزمني', 'impact' => 'medium', 'mitigation' => 'وضع مخزون زمني ومتابعة مستمرة'],
                ['description' => 'نقص الخبرات المطلوبة', 'impact' => 'medium', 'mitigation' => 'التدريب المبكر والبحث عن موارد بديلة'],
                ['description' => 'مشاكل تقنية غير متوقعة', 'impact' => 'low', 'mitigation' => 'وضع خطط بديلة'],
            ]
        ];

        $risks = $baseRisks[$type] ?? $baseRisks['default'];

        if ($difficultyLevel >= 4) {
            $risks[] = [
                'description' => 'تعقيد المشروع قد يؤدي لتأخير كبير',
                'impact' => 'high',
                'mitigation' => 'تقسيم المشروع لأجزاء أصغر وإدارة دقيقة'
            ];
        }

        if ($difficultyLevel >= 5) {
            $risks[] = [
                'description' => 'احتمالية عدم إكمال المشروع بالكامل',
                'impact' => 'high',
                'mitigation' => 'تحديد MVP والتركيز على الأساسيات'
            ];
        }

        return $risks;
    }

    private function buildTimeline($project)
    {
        $timeline = [];
        $currentDate = now();
        $totalDays = 0;

        foreach ($project->milestones->sortBy('order_sequence') as $milestone) {
            $startDate = $currentDate->copy()->addDays($totalDays);
            $endDate = $startDate->copy()->addDays($milestone->estimated_days);

            $timeline[] = [
                'milestone_id' => $milestone->id,
                'title' => $milestone->title,
                'description' => $milestone->description,
                'estimated_days' => $milestone->estimated_days,
                'start_date' => $startDate->format('Y-m-d'),
                'end_date' => $endDate->format('Y-m-d'),
                'order' => $milestone->order_sequence
            ];

            $totalDays += $milestone->estimated_days;
        }

        return $timeline;
    }
}
