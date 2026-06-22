<?php

use App\Http\Controllers\API\AdminController;
use App\Http\Controllers\API\AdvisorController;
use App\Http\Controllers\API\AssistantController;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\HealthController;
use App\Http\Controllers\API\MajorController;
use App\Http\Controllers\API\McpController;
use App\Http\Controllers\API\NotificationController;
use App\Http\Controllers\API\PasswordResetController;
use App\Http\Controllers\API\ProjectController;
use App\Http\Controllers\API\ProjectTodoController;
use App\Http\Controllers\API\RecommendationController;
use App\Http\Controllers\API\SandboxController;
use App\Http\Controllers\API\SkillController;
use App\Http\Controllers\API\SuccessEstimationController;
use App\Http\Controllers\API\TeamController;
use App\Http\Controllers\API\UserController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('/health/db', [HealthController::class, 'checkDb']);
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/password/forgot', [PasswordResetController::class, 'forgot']);
    Route::post('/password/reset', [PasswordResetController::class, 'reset']);
    Route::get('/majors', [MajorController::class, 'index']);
    Route::get('/majors/{id}', [MajorController::class, 'show']);
    Route::get('/skills', [SkillController::class, 'index']);
    Route::get('/skills/{id}', [SkillController::class, 'show']);
    Route::get('/projects', [ProjectController::class, 'index']);
    Route::get('/projects/{id}', [ProjectController::class, 'show']);

    // MCP server (JSON-RPC 2.0) — guarded by a static token, used by external MCP clients.
    Route::middleware('mcp.auth')->post('/mcp', [McpController::class, 'handle']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);

        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
        Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
        Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
        Route::post('/user/skills', [UserController::class, 'updateSkills']);
        Route::get('/user/skills', [UserController::class, 'getSkills']);
        Route::post('/projects', [ProjectController::class, 'store']);
        Route::put('/projects/{id}', [ProjectController::class, 'update']);
        Route::delete('/projects/{id}', [ProjectController::class, 'destroy']);
        Route::get('/recommendations', [RecommendationController::class, 'getRecommendations']);
        Route::apiResource('teams', TeamController::class);
        Route::post('/teams/{id}/join', [TeamController::class, 'join']);
        Route::get('/projects/{id}/sandbox', [SandboxController::class, 'getSandbox']);
        Route::get('/projects/{id}/todos', [ProjectTodoController::class, 'index']);
        Route::post('/projects/{id}/todos/{todoId}/toggle', [ProjectTodoController::class, 'toggle']);
        Route::get('/projects/{projectId}/estimate', [SuccessEstimationController::class, 'estimate']);
        Route::get('/teams/{teamId}/estimate', [SuccessEstimationController::class, 'estimateTeam']);

        // AI assistant — admins and advisors only.
        Route::middleware('role:admin,advisor')->post('/assistant/chat', [AssistantController::class, 'chat']);

        Route::middleware('role:advisor')->group(function () {
            Route::get('/advisor/dashboard', [AdvisorController::class, 'dashboard']);
            Route::get('/advisor/team-requests', [AdvisorController::class, 'teamRequests']);
            Route::put('/advisor/team-requests/{id}/approve', [AdvisorController::class, 'approveTeamRequest']);
            Route::put('/advisor/team-requests/{id}/reject', [AdvisorController::class, 'rejectTeamRequest']);
        });

        Route::middleware('role:admin')->group(function () {
            Route::post('/majors', [MajorController::class, 'store']);
            Route::put('/majors/{id}', [MajorController::class, 'update']);
            Route::delete('/majors/{id}', [MajorController::class, 'destroy']);
            Route::post('/skills', [SkillController::class, 'store']);
            Route::put('/skills/{id}', [SkillController::class, 'update']);
            Route::delete('/skills/{id}', [SkillController::class, 'destroy']);

            Route::get('/admin/dashboard', [AdminController::class, 'dashboard']);
            Route::get('/admin/users', [AdminController::class, 'users']);
            Route::get('/admin/projects', [AdminController::class, 'projects']);
            Route::delete('/admin/users/{id}', [AdminController::class, 'deleteUser']);
            Route::put('/admin/users/{id}/restore', [AdminController::class, 'restoreUser']);
            Route::put('/admin/projects/{id}/status', [AdminController::class, 'updateProjectStatus']);
        });
    });
});
