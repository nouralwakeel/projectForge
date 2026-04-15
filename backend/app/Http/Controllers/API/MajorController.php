<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Major;
use Illuminate\Http\Request;

class MajorController extends Controller
{
    public function index()
    {
        $majors = Major::all();
        return response()->json([
            'success' => true,
            'data' => $majors
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|unique:majors,code'
        ]);

        $major = Major::create($request->only(['name', 'code']));

        return response()->json([
            'success' => true,
            'message' => 'Major created successfully',
            'data' => $major
        ], 201);
    }

    public function show(string $id)
    {
        $major = Major::with('users')->find($id);

        if (!$major) {
            return response()->json([
                'success' => false,
                'message' => 'Major not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $major
        ]);
    }

    public function update(Request $request, string $id)
    {
        $major = Major::find($id);

        if (!$major) {
            return response()->json([
                'success' => false,
                'message' => 'Major not found'
            ], 404);
        }

        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'code' => 'sometimes|required|string|unique:majors,code,' . $id
        ]);

        $major->update($request->only(['name', 'code']));

        return response()->json([
            'success' => true,
            'message' => 'Major updated successfully',
            'data' => $major
        ]);
    }

    public function destroy(string $id)
    {
        $major = Major::find($id);

        if (!$major) {
            return response()->json([
                'success' => false,
                'message' => 'Major not found'
            ], 404);
        }

        $major->delete();

        return response()->json([
            'success' => true,
            'message' => 'Major deleted successfully'
        ]);
    }
}
