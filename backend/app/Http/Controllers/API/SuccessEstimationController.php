<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Models\SuccessEstimation;
use App\Models\Team;
use App\Models\UserSkill;
use Carbon\Carbon;
use Illuminate\Http\Request;

class SuccessEstimationController extends Controller
{
    public function estimate($projectId)
    {
        $user = auth()->user();
        $project = Project::with('skills')->find($projectId);

        if (!$project) {
            return response()->json([
                'success' => false,
                'message' => 'Project not found'
            ], 404);
        }

        $userSkills = UserSkill::where('user_id', $user->id)
            ->get()
            ->keyBy('skill_id');

        $skillCoverage = $this->calculateSkillCoverage($project, $userSkills);
        $difficultyFactor = (6 - $project->difficulty_level) / 5;
        $teamBalance = 1.0;

        $successProbability = ($skillCoverage * 0.5) + ($teamBalance * 0.2) + ($difficultyFactor * 0.3);

        $successProbability = min($successProbability, 1.0);

        $estimation = SuccessEstimation::create([
            'user_id' => $user->id,
            'project_id' => $project->id,
            'success_probability' => $successProbability,
            'calculated_at' => Carbon::now(),
            'factors_log' => json_encode([
                'skill_coverage' => round($skillCoverage * 100, 2),
                'team_balance' => round($teamBalance * 100, 2),
                'difficulty_factor' => round($difficultyFactor * 100, 2)
            ])
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'success_probability' => round($successProbability * 100, 2),
                'factors' => [
                    'skill_coverage' => round($skillCoverage * 100, 2),
                    'team_balance' => round($teamBalance * 100, 2),
                    'difficulty_factor' => round($difficultyFactor * 100, 2)
                ],
                'difficulty_level' => $project->difficulty_level,
                'estimation_id' => $estimation->id
            ]
        ]);
    }

    public function estimateTeam($teamId)
    {
        $team = Team::with(['members.user.skills', 'project.skills'])->find($teamId);

        if (!$team) {
            return response()->json([
                'success' => false,
                'message' => 'Team not found'
            ], 404);
        }

        $project = $team->project;

        if (!$project) {
            return response()->json([
                'success' => false,
                'message' => 'Team has no project assigned'
            ], 400);
        }

        $teamSkills = collect();
        foreach ($team->members as $member) {
            $memberSkills = UserSkill::where('user_id', $member->user_id)
                ->get();
            foreach ($memberSkills as $skill) {
                if ($teamSkills->has($skill->skill_id)) {
                    $teamSkills[$skill->skill_id] = max(
                        $teamSkills[$skill->skill_id],
                        $skill->proficiency_level
                    );
                } else {
                    $teamSkills[$skill->skill_id] = $skill->proficiency_level;
                }
            }
        }

        $skillCoverage = $this->calculateTeamSkillCoverage($project, $teamSkills);
        $teamBalance = $this->calculateTeamBalance($team);
        $difficultyFactor = (6 - $project->difficulty_level) / 5;

        $successProbability = ($skillCoverage * 0.5) + ($teamBalance * 0.2) + ($difficultyFactor * 0.3);
        $successProbability = min($successProbability, 1.0);

        $estimation = SuccessEstimation::create([
            'team_id' => $team->id,
            'project_id' => $project->id,
            'success_probability' => $successProbability,
            'calculated_at' => Carbon::now(),
            'factors_log' => json_encode([
                'skill_coverage' => round($skillCoverage * 100, 2),
                'team_balance' => round($teamBalance * 100, 2),
                'difficulty_factor' => round($difficultyFactor * 100, 2)
            ])
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'success_probability' => round($successProbability * 100, 2),
                'factors' => [
                    'skill_coverage' => round($skillCoverage * 100, 2),
                    'team_balance' => round($teamBalance * 100, 2),
                    'difficulty_factor' => round($difficultyFactor * 100, 2)
                ],
                'team_size' => $team->members->count(),
                'difficulty_level' => $project->difficulty_level,
                'estimation_id' => $estimation->id
            ]
        ]);
    }

    private function calculateSkillCoverage($project, $userSkills)
    {
        $projectSkills = $project->skills;

        if ($projectSkills->isEmpty()) {
            return 1.0;
        }

        $totalWeight = 0;
        $coveredWeight = 0;

        foreach ($projectSkills as $projectSkill) {
            $weight = $projectSkill->pivot->weight;
            $totalWeight += $weight;

            if ($userSkills->has($projectSkill->id)) {
                $proficiency = $userSkills[$projectSkill->id]->proficiency_level;
                $coveredWeight += $weight * ($proficiency / 5);
            }
        }

        return $totalWeight > 0 ? $coveredWeight / $totalWeight : 0;
    }

    private function calculateTeamSkillCoverage($project, $teamSkills)
    {
        $projectSkills = $project->skills;

        if ($projectSkills->isEmpty()) {
            return 1.0;
        }

        $totalWeight = 0;
        $coveredWeight = 0;

        foreach ($projectSkills as $projectSkill) {
            $weight = $projectSkill->pivot->weight;
            $totalWeight += $weight;

            if ($teamSkills->has($projectSkill->id)) {
                $proficiency = $teamSkills[$projectSkill->id];
                $coveredWeight += $weight * ($proficiency / 5);
            }
        }

        return $totalWeight > 0 ? $coveredWeight / $totalWeight : 0;
    }

    private function calculateTeamBalance($team)
    {
        $members = $team->members;

        if ($members->count() <= 1) {
            return 1.0;
        }

        $skillCounts = collect();
        foreach ($members as $member) {
            $userSkills = UserSkill::where('user_id', $member->user_id)->get();
            foreach ($userSkills as $skill) {
                $skillCounts[$skill->skill_id] = ($skillCounts[$skill->skill_id] ?? 0) + 1;
            }
        }

        if ($skillCounts->isEmpty()) {
            return 0.5;
        }

        $avgOccurrences = $members->count() > 0 ? $skillCounts->sum() / $members->count() : 0;
        $variance = 0;
        foreach ($skillCounts as $count) {
            $variance += pow($count - $avgOccurrences, 2);
        }
        $stdDev = sqrt($variance / $skillCounts->count());

        $balance = 1 - ($stdDev / max($members->count(), 1));

        return max($balance, 0.5);
    }
}
