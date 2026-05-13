<?php

namespace App\Http\Controllers\API;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Routing\Controller;

class HealthController extends Controller
{
    public function checkDb(): JsonResponse
    {
        try {
            DB::connection()->getPdo();
            $driver = DB::connection()->getDriverName();
            $database = DB::connection()->getDatabaseName();

            return response()->json([
                'success' => true,
                'message' => 'Database connection successful',
                'data' => [
                    'driver' => $driver,
                    'database' => $database,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Database connection failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
