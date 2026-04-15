<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\MajorController;
use App\Http\Controllers\API\ProjectController;
use App\Http\Controllers\API\RecommendationController;
use App\Http\Controllers\API\SandboxController;
use App\Http\Controllers\API\SkillController;
use App\Http\Controllers\API\SuccessEstimationController;
use App\Http\Controllers\API\TeamController;
use App\Http\Controllers\API\UserController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/majors', [MajorController::class, 'index']);
    Route::get('/majors/{id}', [MajorController::class, 'show']);
    Route::get('/skills', [SkillController::class, 'index']);
    Route::get('/skills/{id}', [SkillController::class, 'show']);
    Route::get('/projects', [ProjectController::class, 'index']);
    Route::get('/projects/{id}', [ProjectController::class, 'show']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/user/skills', [UserController::class, 'updateSkills']);
        Route::get('/user/skills', [UserController::class, 'getSkills']);
        Route::post('/projects', [ProjectController::class, 'store']);
        Route::put('/projects/{id}', [ProjectController::class, 'update']);
        Route::delete('/projects/{id}', [ProjectController::class, 'destroy']);
        Route::get('/recommendations', [RecommendationController::class, 'getRecommendations']);
        Route::apiResource('teams', TeamController::class);
        Route::post('/teams/{id}/join', [TeamController::class, 'join']);
        Route::get('/projects/{id}/sandbox', [SandboxController::class, 'getSandbox']);
        Route::get('/projects/{projectId}/estimate', [SuccessEstimationController::class, 'estimate']);
        Route::get('/teams/{teamId}/estimate', [SuccessEstimationController::class, 'estimateTeam']);

        Route::middleware('role:admin')->group(function () {
            Route::post('/majors', [MajorController::class, 'store']);
            Route::put('/majors/{id}', [MajorController::class, 'update']);
            Route::delete('/majors/{id}', [MajorController::class, 'destroy']);
            Route::post('/skills', [SkillController::class, 'store']);
            Route::put('/skills/{id}', [SkillController::class, 'update']);
            Route::delete('/skills/{id}', [SkillController::class, 'destroy']);
        });
    });
});
