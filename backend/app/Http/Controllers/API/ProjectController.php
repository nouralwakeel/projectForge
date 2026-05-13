<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreProjectRequest;
use App\Models\Project;
use App\Models\ProjectSkill;
use Illuminate\Http\Request;

class ProjectController extends Controller
{
    public function index(Request $request)
    {
        $query = Project::with(['supervisor', 'type', 'skills']);

        if ($request->has('type_id')) {
            $query->where('type_id', $request->type_id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('difficulty_level')) {
            $query->where('difficulty_level', $request->difficulty_level);
        }

        $projects = $query->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $projects
        ]);
    }

    public function store(StoreProjectRequest $request)
    {
        $project = Project::create([
            'title' => $request->title,
            'description' => $request->description,
            'type_id' => $request->type_id,
            'difficulty_level' => $request->difficulty_level,
            'supervisor_id' => $request->supervisor_id ?? auth()->id(),
            'status' => 'available'
        ]);

        foreach ($request->skills as $skillData) {
            ProjectSkill::create([
                'project_id' => $project->id,
                'skill_id' => $skillData['id'],
                'weight' => $skillData['weight']
            ]);
        }

        $project->load(['supervisor', 'type', 'skills']);

        return response()->json([
            'success' => true,
            'message' => 'Project created successfully',
            'data' => $project
        ], 201);
    }

    public function show(string $id)
    {
        $project = Project::with(['supervisor', 'type', 'skills', 'milestones', 'risks', 'teams.members'])
            ->find($id);

        if (!$project) {
            return response()->json([
                'success' => false,
                'message' => 'Project not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $project
        ]);
    }

    public function update(Request $request, string $id)
    {
        $project = Project::find($id);

        if (!$project) {
            return response()->json([
                'success' => false,
                'message' => 'Project not found'
            ], 404);
        }

        $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'type_id' => 'sometimes|required|exists:project_types,id',
            'difficulty_level' => 'sometimes|required|integer|min:1|max:5',
            'status' => 'sometimes|required|in:available,in_progress,completed,cancelled'
        ]);

        $project->update($request->only([
            'title', 'description', 'type_id', 'difficulty_level', 'status'
        ]));

        if ($request->has('skills')) {
            ProjectSkill::where('project_id', $project->id)->delete();
            foreach ($request->skills as $skillData) {
                ProjectSkill::create([
                    'project_id' => $project->id,
                    'skill_id' => $skillData['id'],
                    'weight' => $skillData['weight']
                ]);
            }
        }

        $project->load(['supervisor', 'type', 'skills']);

        return response()->json([
            'success' => true,
            'message' => 'Project updated successfully',
            'data' => $project
        ]);
    }

    public function destroy(string $id)
    {
        $project = Project::find($id);

        if (!$project) {
            return response()->json([
                'success' => false,
                'message' => 'Project not found'
            ], 404);
        }

        $project->delete();

        return response()->json([
            'success' => true,
            'message' => 'Project deleted successfully'
        ]);
    }
}
