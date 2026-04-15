<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Team;
use App\Models\TeamMember;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index()
    {
        $teams = Team::with(['project', 'members'])->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $teams
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'project_id' => 'required|exists:projects,id'
        ]);

        $team = Team::create([
            'name' => $request->name,
            'project_id' => $request->project_id,
            'is_approved' => false
        ]);

        TeamMember::create([
            'team_id' => $team->id,
            'user_id' => auth()->id(),
            'role_in_team' => 'leader'
        ]);

        $team->load(['project', 'members']);

        return response()->json([
            'success' => true,
            'message' => 'Team created successfully',
            'data' => $team
        ], 201);
    }

    public function show(string $id)
    {
        $team = Team::with(['project', 'members.user'])->find($id);

        if (!$team) {
            return response()->json([
                'success' => false,
                'message' => 'Team not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $team
        ]);
    }

    public function update(Request $request, string $id)
    {
        $team = Team::find($id);

        if (!$team) {
            return response()->json([
                'success' => false,
                'message' => 'Team not found'
            ], 404);
        }

        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'is_approved' => 'sometimes|required|boolean'
        ]);

        $team->update($request->only(['name', 'is_approved']));

        $team->load(['project', 'members']);

        return response()->json([
            'success' => true,
            'message' => 'Team updated successfully',
            'data' => $team
        ]);
    }

    public function destroy(string $id)
    {
        $team = Team::find($id);

        if (!$team) {
            return response()->json([
                'success' => false,
                'message' => 'Team not found'
            ], 404);
        }

        $team->delete();

        return response()->json([
            'success' => true,
            'message' => 'Team deleted successfully'
        ]);
    }

    public function join(string $id)
    {
        $team = Team::find($id);

        if (!$team) {
            return response()->json([
                'success' => false,
                'message' => 'Team not found'
            ], 404);
        }

        $existingMember = TeamMember::where('team_id', $id)
            ->where('user_id', auth()->id())
            ->first();

        if ($existingMember) {
            return response()->json([
                'success' => false,
                'message' => 'You are already a member of this team'
            ], 400);
        }

        TeamMember::create([
            'team_id' => $team->id,
            'user_id' => auth()->id(),
            'role_in_team' => 'member'
        ]);

        $team->load(['project', 'members']);

        return response()->json([
            'success' => true,
            'message' => 'Successfully joined the team',
            'data' => $team
        ]);
    }
}
