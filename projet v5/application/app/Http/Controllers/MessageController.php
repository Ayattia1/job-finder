<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Message;
use App\Models\Conversation;
use Illuminate\Support\Facades\Auth;

class MessageController extends Controller
{
public function index(Request $request)
{
    $userId = auth('sanctum')->id();
    $employerId = $request->query('employer_id');

    $conversation = Conversation::where(function ($query) use ($userId, $employerId) {
        $query->where('user_id', $userId)
              ->where('employer_id', $employerId);
    })->orWhere(function ($query) use ($userId, $employerId) {
        $query->where('user_id', $employerId)
              ->where('employer_id', $userId);
    })->with(['messages.sender'])->first();

    if (!$conversation) {
        return response()->json(['messages' => []]);
    }

    $messages = $conversation->messages;

    return response()->json([
        'messages' => $messages->map(function ($msg) use ($userId) {
            return [
                'id' => $msg->id,
                'sender_id' => $msg->sender_id,
                'content' => $msg->content,
                'created_at' => $msg->created_at->toIso8601String(),
                'is_mine' => $msg->sender_id === $userId,
            ];
        }),
    ]);
}


public function store(Request $request)
{
    $userId = auth('sanctum')->id();

    $validated = $request->validate([
        'employer_id' => 'required|integer',
        'content' => 'required|string',
    ]);

    $otherPartyId = $validated['employer_id'];

    // Try to find an existing conversation (regardless of who initiated it)
    $conversation = Conversation::where(function ($query) use ($userId, $otherPartyId) {
        $query->where('user_id', $userId)
              ->where('employer_id', $otherPartyId);
    })->orWhere(function ($query) use ($userId, $otherPartyId) {
        $query->where('user_id', $otherPartyId)
              ->where('employer_id', $userId);
    })->first();

    if (!$conversation) {
        $conversation = Conversation::create([
            'user_id' => min($userId, $otherPartyId),
            'employer_id' => max($userId, $otherPartyId),
        ]);
    }

    // Save message
    $message = $conversation->messages()->create([
        'sender_id' => $userId,
        'content' => $validated['content'],
    ]);

    return response()->json([
        'message' => 'Message sent successfully.',
        'data' => [
            'id' => $message->id,
            'sender_id' => $message->sender_id,
            'content' => $message->content,
            'created_at' => $message->created_at->toIso8601String(),
            'is_mine' => true,
        ],
    ], 201);
}
public function conversations()
{
    $userId = auth('sanctum')->id();

    $conversations = Conversation::where('user_id', $userId)
        ->orWhere('employer_id', $userId)
        ->with(['latestMessage', 'latestMessage.sender', 'user', 'employer'])
        ->get();

    // Sort by latest message created_at descending
    $sorted = $conversations->sortByDesc(function ($conv) {
        return optional($conv->latestMessage)->created_at;
    });

    $result = $sorted->map(function ($conv) use ($userId) {
        $isUser = $conv->user_id === $userId;
        $otherId = $isUser ? $conv->employer_id : $conv->user_id;
        $otherName = $isUser ? optional($conv->employer)->first_name : optional($conv->user)->first_name;

        return [
            'conversation_id' => $conv->id,
            'other_id' => $otherId,
            'other_name' => $otherName,
            'latest_message' => $conv->latestMessage ? [
                'content' => $conv->latestMessage->content,
                'created_at' => $conv->latestMessage->created_at->diffForHumans(),
                'sender_id' => $conv->latestMessage->sender_id,
            ] : null,
        ];
    });

    return response()->json(['conversations' => $result->values()]);
}


}
