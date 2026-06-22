<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateSkillsRequest;
use App\Models\StudentSkill;
use App\Models\User;

class UserController extends Controller
{
    public function index()
    {
        $users = User::with(['student.major', 'student.skills'])->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    public function show(string $id)
    {
        $user = User::with(['student.major', 'student.skills', 'student.teams.project'])->find($id);

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $user,
        ]);
    }

    public function updateSkills(UpdateSkillsRequest $request)
    {
        $user = auth()->user();
        $student = $user->student;

        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Student profile not found',
            ], 404);
        }

        StudentSkill::where('student_id', $student->id)->delete();

        foreach ($request->skills as $skillData) {
            StudentSkill::create([
                'student_id' => $student->id,
                'skill_id' => $skillData['skill_id'],
                'proficiency_level' => $skillData['proficiency_level'],
                'interest_level' => $skillData['interest_level'],
            ]);
        }

        $student->load('skills');

        return response()->json([
            'success' => true,
            'message' => 'Skills updated successfully',
            'data' => $student->skills,
        ]);
    }

    public function getSkills()
    {
        $user = auth()->user();
        $student = $user->student;

        if (! $student) {
            return response()->json([
                'success' => false,
                'message' => 'Student profile not found',
            ], 404);
        }

        $student->load('skills');

        return response()->json([
            'success' => true,
            'data' => $student->skills,
        ]);
    }
}
