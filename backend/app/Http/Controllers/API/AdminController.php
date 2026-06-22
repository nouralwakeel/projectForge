<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Major;
use App\Models\Project;
use App\Models\Skill;
use App\Models\Student;
use App\Models\Team;
use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function dashboard()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'stats' => [
                    'students_count' => Student::count(),
                    'projects_count' => Project::count(),
                    'teams_count' => Team::count(),
                    'majors_count' => Major::count(),
                    'skills_count' => Skill::count(),
                    'users_count' => User::count(),
                ],
                'recent_users' => User::with('student.major')
                    ->orderBy('created_at', 'desc')
                    ->take(5)
                    ->get(),
                'recent_projects' => Project::with('supervisor')
                    ->orderBy('created_at', 'desc')
                    ->take(5)
                    ->get(),
            ],
        ]);
    }

    public function stats()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'users_count' => User::count(),
                'students_count' => Student::count(),
                'projects_count' => Project::count(),
                'teams_count' => Team::count(),
                'majors_count' => Major::count(),
                'skills_count' => Skill::count(),
                'admins_count' => User::where('role', 'admin')->count(),
                'advisors_count' => User::where('role', 'advisor')->count(),
            ],
        ]);
    }

    public function users(Request $request)
    {
        $query = User::with(['student.major', 'student.skills']);

        // Archived (soft-deleted) accounts are returned only when explicitly requested.
        if ($request->boolean('archived')) {
            $query->onlyTrashed();
        }

        if ($request->has('role')) {
            $query->where('role', $request->role);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%");
            });
        }

        $users = $query->orderBy('created_at', 'desc')->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    public function projects(Request $request)
    {
        $query = Project::with(['supervisor', 'type', 'skills', 'teams.members.user']);

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('type_id')) {
            $query->where('type_id', $request->type_id);
        }

        if ($request->filled('academic_year')) {
            $query->where('academic_year', $request->academic_year);
        }

        if ($request->filled('semester')) {
            $query->where('semester', $request->semester);
        }

        $projects = $query->orderBy('created_at', 'desc')->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $projects,
        ]);
    }

    public function deleteUser($id)
    {
        $user = User::find($id);

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم العثور على المستخدم',
            ], 404);
        }

        if ($user->role === 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن أرشفة حسابات المدراء',
            ], 403);
        }

        // Archive instead of hard delete: revoke active tokens, then soft delete.
        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'تمت أرشفة الحساب بنجاح',
        ]);
    }

    public function restoreUser($id)
    {
        $user = User::withTrashed()->find($id);

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم العثور على المستخدم',
            ], 404);
        }

        if (! $user->trashed()) {
            return response()->json([
                'success' => false,
                'message' => 'الحساب غير مؤرشف',
            ], 400);
        }

        $user->restore();

        return response()->json([
            'success' => true,
            'message' => 'تمت استعادة الحساب بنجاح',
            'data' => $user->load(['student.major', 'student.skills']),
        ]);
    }

    public function updateProjectStatus(Request $request, $id)
    {
        $project = Project::find($id);

        if (! $project) {
            return response()->json([
                'success' => false,
                'message' => 'Project not found',
            ], 404);
        }

        $request->validate([
            'status' => 'required|in:available,in_progress,completed,cancelled',
        ]);

        $project->update(['status' => $request->status]);

        return response()->json([
            'success' => true,
            'message' => 'Project status updated successfully',
            'data' => $project->load(['supervisor', 'type', 'skills']),
        ]);
    }
}
