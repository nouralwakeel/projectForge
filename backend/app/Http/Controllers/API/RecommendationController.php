<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Models\StudentSkill;
use Illuminate\Http\Request;

class RecommendationController extends Controller
{
    public function getRecommendations(Request $request)
    {
        $user = auth()->user();
        $student = $user->student;

        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Student profile not found'
            ], 404);
        }

        $studentSkills = StudentSkill::where('student_id', $student->id)
            ->with('skill')
            ->get()
            ->keyBy('skill_id');

        if ($studentSkills->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Please complete your skills survey first'
            ], 400);
        }

        $projects = Project::with(['skills', 'supervisor'])
            ->where('status', 'available')
            ->get();

        $recommendations = [];

        foreach ($projects as $project) {
            $matchScore = $this->calculateMatchScore($project, $studentSkills);
            
            if ($matchScore > 0) {
                $recommendations[] = [
                    'project' => $project,
                    'match_score' => $matchScore,
                    'match_percentage' => round($matchScore * 100, 2)
                ];
            }
        }

        usort($recommendations, function ($a, $b) {
            return $b['match_score'] <=> $a['match_score'];
        });

        $recommendations = array_slice($recommendations, 0, 10);

        return response()->json([
            'success' => true,
            'data' => $recommendations
        ]);
    }

    private function calculateMatchScore($project, $studentSkills)
    {
        $projectSkills = $project->skills;

        if ($projectSkills->isEmpty()) {
            return 0;
        }

        $numerator = 0;
        $denominator = 0;
        $maxProficiency = 5;

        foreach ($projectSkills as $projectSkill) {
            $weight = $projectSkill->pivot->weight;
            $skillId = $projectSkill->id;

            $studentProficiency = $studentSkills->has($skillId)
                ? $studentSkills[$skillId]->proficiency_level
                : 0;

            $numerator += ($studentProficiency * $weight);
            $denominator += ($maxProficiency * $weight);
        }

        return $denominator > 0 ? $numerator / $denominator : 0;
    }
}
