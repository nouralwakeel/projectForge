<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\UserNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /** Latest notifications for the authenticated user + unread count. */
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $notifications = UserNotification::where('user_id', $userId)
            ->orderByDesc('created_at')
            ->limit(100)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'notifications' => $notifications,
                'unread_count' => $notifications->whereNull('read_at')->count(),
            ],
        ]);
    }

    public function unreadCount(Request $request)
    {
        $count = UserNotification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->count();

        return response()->json([
            'success' => true,
            'data' => ['unread_count' => $count],
        ]);
    }

    public function markAsRead(Request $request, $id)
    {
        $notification = UserNotification::where('user_id', $request->user()->id)
            ->find($id);

        if (! $notification) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم العثور على الإشعار',
            ], 404);
        }

        if ($notification->read_at === null) {
            $notification->update(['read_at' => now()]);
        }

        return response()->json([
            'success' => true,
            'data' => $notification,
        ]);
    }

    public function markAllAsRead(Request $request)
    {
        UserNotification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'تم تعليم كل الإشعارات كمقروءة',
        ]);
    }
}
