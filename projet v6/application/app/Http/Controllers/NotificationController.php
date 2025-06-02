<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $user = auth('sanctum')->user();

        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $notifications = Notification::where('user_id', $user->id)
            ->latest()
            ->get();

        return response()->json($notifications);
    }
    public function markAsRead($id)
    {
        $notification = Notification::findOrFail($id);

        $notification->update([
            'is_read' => true,
        ]);

        return response()->json(['message' => 'Notification marked as read.']);
    }
    public function unreadCount(Request $request)
{
    $user = auth('sanctum')->user();

    if (!$user) {
        return response()->json(['error' => 'Unauthorized'], 401);
    }

    $count = Notification::where('user_id', $user->id)
                ->where('is_read', false)
                ->count();

    return response()->json(['unread_count' => $count]);
}

}
