<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProjectResource;
use App\Http\Resources\TeamResource;
use App\Models\Project;
use App\Models\Team;
use App\Models\UserNotification;
use Illuminate\Http\Request;

class AdvisorController extends Controller
{
    public function dashboard()
    {
        $advisor = auth()->user();

        $projects = Project::where('supervisor_id', $advisor->id)
            ->with(['type', 'teams.members.user', 'skills'])
            ->orderBy('created_at', 'desc')
            ->get();

        $totalProjects = $projects->count();
        $totalTeams = $projects->sum(fn ($p) => $p->teams->count());
        $pendingRequests = Team::whereHas('project', fn ($q) => $q->where('supervisor_id', $advisor->id))
            ->where('supervisor_status', 'pending')
            ->count();

        $statusCounts = $projects->groupBy('status')
            ->map(fn ($items) => $items->count())
            ->toArray();

        return response()->json([
            'success' => true,
            'data' => [
                'stats' => [
                    'projects_count' => $totalProjects,
                    'teams_count' => $totalTeams,
                    'pending_requests_count' => $pendingRequests,
                    'status_counts' => $statusCounts,
                ],
                'projects' => ProjectResource::collection($projects),
            ],
        ]);
    }

    public function teamRequests(Request $request)
    {
        $advisor = auth()->user();
        $status = $request->get('status', 'pending');

        $query = Team::whereHas('project', fn ($q) => $q->where('supervisor_id', $advisor->id));

        if ($status && in_array($status, ['pending', 'approved', 'rejected'])) {
            $query->where('supervisor_status', $status);
        }

        $teams = $query->with(['project', 'members.user'])
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => TeamResource::collection($teams),
        ]);
    }

    public function approveTeamRequest($id)
    {
        $advisor = auth()->user();

        $team = Team::whereHas('project', fn ($q) => $q->where('supervisor_id', $advisor->id))
            ->find($id);

        if (! $team) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم العثور على الفريق',
            ], 404);
        }

        if ($team->supervisor_status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'تم معالجة هذا الطلب مسبقاً',
            ], 400);
        }

        $team->update([
            'supervisor_status' => 'approved',
            'is_approved' => true,
        ]);

        $team->load(['project', 'members.user']);

        foreach ($team->members as $member) {
            UserNotification::createFor(
                $member->user_id,
                'team_approved',
                'تمت الموافقة على فريقك',
                "تمت الموافقة على إشراف الفريق «{$team->name}» لمشروع: ".($team->project?->title ?? ''),
                ['team_id' => $team->id, 'project_id' => $team->project_id],
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'تم قبول الفريق بنجاح',
            'data' => new TeamResource($team),
        ]);
    }

    public function rejectTeamRequest(Request $request, $id)
    {
        $advisor = auth()->user();

        $validated = $request->validate([
            'rejection_reason' => 'required|string|max:1000',
        ]);

        $team = Team::whereHas('project', fn ($q) => $q->where('supervisor_id', $advisor->id))
            ->find($id);

        if (! $team) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم العثور على الفريق',
            ], 404);
        }

        if ($team->supervisor_status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'تم معالجة هذا الطلب مسبقاً',
            ], 400);
        }

        $team->update([
            'supervisor_status' => 'rejected',
            'is_approved' => false,
            'rejection_reason' => $validated['rejection_reason'],
        ]);

        $team->load(['project', 'members.user']);

        foreach ($team->members as $member) {
            UserNotification::createFor(
                $member->user_id,
                'team_rejected',
                'تم رفض طلب الإشراف',
                "تم رفض إشراف الفريق «{$team->name}». السبب: ".$validated['rejection_reason'],
                ['team_id' => $team->id, 'project_id' => $team->project_id],
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'تم رفض الفريق',
            'data' => new TeamResource($team),
        ]);
    }
}
