<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Services\Assistant\TodoGenerator;

class ProjectTodoController extends Controller
{
    public function __construct(private TodoGenerator $generator) {}

    /**
     * Return the project's to-do checklist, lazily generating it (AI or template)
     * on first access, together with the current risk percentage.
     */
    public function index($projectId)
    {
        $project = Project::with('todos', 'type')->find($projectId);

        if (! $project) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم العثور على المشروع',
            ], 404);
        }

        if ($project->todos->isEmpty()) {
            $this->seedTodos($project);
            $project->load('todos');
        }

        return response()->json([
            'success' => true,
            'data' => [
                'todos' => $project->todos,
                'risk_percentage' => $this->riskPercentage($project),
                'ai_generated' => $this->generator->isConfigured(),
            ],
        ]);
    }

    /**
     * Toggle a single to-do's done state and return the recomputed risk.
     */
    public function toggle($projectId, $todoId)
    {
        $project = Project::with('todos')->find($projectId);

        if (! $project) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم العثور على المشروع',
            ], 404);
        }

        $todo = $project->todos->firstWhere('id', (int) $todoId);

        if (! $todo) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم العثور على المهمة',
            ], 404);
        }

        $todo->is_done = ! $todo->is_done;
        $todo->save();

        // Reflect the change on the in-memory collection before recomputing.
        $project->setRelation('todos', $project->todos->map(
            fn ($t) => $t->id === $todo->id ? $todo : $t
        ));

        return response()->json([
            'success' => true,
            'data' => [
                'todo' => $todo,
                'risk_percentage' => $this->riskPercentage($project),
            ],
        ]);
    }

    private function seedTodos(Project $project): void
    {
        foreach ($this->generator->generate($project) as $index => $item) {
            $project->todos()->create([
                'title' => $item['title'],
                'description' => $item['description'] ?? null,
                'risk_weight' => $item['risk_weight'] ?? 1,
                'is_done' => false,
                'order_sequence' => $index + 1,
            ]);
        }
    }

    /**
     * Risk drops from a difficulty-based baseline toward 0 as weighted to-dos
     * get completed: risk% = base * (1 - doneWeight/totalWeight) * 100.
     */
    private function riskPercentage(Project $project): int
    {
        $base = max(1, min(5, (int) $project->difficulty_level)) / 5;

        $totalWeight = (int) $project->todos->sum('risk_weight');
        $doneWeight = (int) $project->todos->where('is_done', true)->sum('risk_weight');

        $remaining = $totalWeight > 0 ? 1 - ($doneWeight / $totalWeight) : 1;

        return (int) round($base * $remaining * 100);
    }
}
