<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateSkillsRequest;
use App\Models\User;
use App\Models\UserSkill;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index()
    {
        $users = User::with(['major', 'skills'])->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $users
        ]);
    }

    public function show(string $id)
    {
        $user = User::with(['major', 'skills', 'teams.project'])->find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $user
        ]);
    }

    public function updateSkills(UpdateSkillsRequest $request)
    {
        $user = auth()->user();

        UserSkill::where('user_id', $user->id)->delete();

        foreach ($request->skills as $skillData) {
            UserSkill::create([
                'user_id' => $user->id,
                'skill_id' => $skillData['skill_id'],
                'proficiency_level' => $skillData['proficiency_level']
            ]);
        }

        $user->load('skills');

        return response()->json([
            'success' => true,
            'message' => 'Skills updated successfully',
            'data' => $user->skills
        ]);
    }

    public function getSkills()
    {
        $user = auth()->user();
        $user->load('skills');

        return response()->json([
            'success' => true,
            'data' => $user->skills
        ]);
    }
}
