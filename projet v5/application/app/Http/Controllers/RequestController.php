<?php

namespace App\Http\Controllers;

use App\Models\candidat;
use Illuminate\Http\Request;
use App\Models\Request as JobRequest;
use App\Models\Conversation;
use App\Models\Employeur;
use App\Models\Message;

class RequestController extends Controller
{
public function store(Request $request)
{
    $validated = $request->validate([
        'job_id' => 'required|exists:employeurs,id',
        'employer_id' => 'required|exists:users,id',
        'message' => 'required|string',
    ]);

    $user = auth('sanctum')->user();
    $jobId = $validated['job_id'];
    $messageContent = $validated['message'];
    $idEmployer = $validated['employer_id'];

    $job = Employeur::with('category')->findOrFail($jobId);

    $candidateCategories = candidat::where('user_id', $user->id)->pluck('category_id');

    if ($candidateCategories->isEmpty() || !$candidateCategories->contains($job->category_job_id)) {
        return response()->json(['message' => 'Votre profil ne correspond pas à la catégorie de cette offre.'], 403);
    }

    $existingRequest = JobRequest::where('user_id', $user->id)
        ->where('job_id', $jobId)
        ->first();

    if ($existingRequest) {
        return response()->json(['message' => 'Vous avez déjà postulé à cette offre.'], 400);
    }

    // Create job request
    $jobRequest = JobRequest::create([
        'user_id' => $user->id,
        'job_id' => $jobId,
        'employer_id' => $idEmployer,
        'status' => 'pending',
    ]);

    // ✅ Send notification to employer
    \App\Models\Notification::create([
        'user_id' => $idEmployer,
        'title'   => 'Nouvelle demande d\'emploi',
        'body'    => $user->name . ' a postulé pour votre offre "' . $job->job_title . '".',
        'type'    => 'job_request',
        'data'    => json_encode([
            'job_id'     => $jobId,
            'request_id' => $jobRequest->id,
            'candidate_id' => $user->id,
        ]),
    ]);

    // Normalize conversation direction
    $userOne = min($user->id, $idEmployer);
    $userTwo = max($user->id, $idEmployer);

    $conversation = Conversation::where('user_id', $userOne)
        ->where('employer_id', $userTwo)
        ->first();

    if (!$conversation) {
        $conversation = Conversation::create([
            'user_id' => $userOne,
            'employer_id' => $userTwo,
        ]);
    }

    // Save the message
    Message::create([
        'conversation_id' => $conversation->id,
        'sender_id' => $user->id,
        'content' => $messageContent,
    ]);

    return response()->json(['message' => 'Demande envoyée avec succès.'], 201);
}




public function userRequests()
{
    $user = auth('sanctum')->user();

    $requests = JobRequest::with([
            'job.category',
            'job.user',
        ])
        ->where('user_id', $user->id)
        ->where(function($query) {
            $query->whereHas('job', function($q) {
                $q->where('status', '=', 'accepted');
                //->where('status', '!=', 'pending');
            })
            ->orWhere('status', 'accepted');
        })
        ->latest()
        ->get();

    return response()->json($requests);
}


    public function checkIfApplied($jobId)
    {
        $user = auth('sanctum')->user();

        // Check if the user has already applied for the job
        $existingRequest = JobRequest::where('user_id', $user->id)
            ->where('job_id', $jobId)
            ->first();

        if ($existingRequest) {
            return response()->json(['status' => 'applied'], 200);
        } else {
            return response()->json(['status' => 'not_applied'], 200);
        }
    }

    public function destroy($jobId)
    {
        $user = auth('sanctum')->user();

        $jobRequest = JobRequest::where('user_id', $user->id)
            ->where('job_id', $jobId)
            ->first();

        if (!$jobRequest) {
            return response()->json(['message' => 'Candidature non trouvée.'], 404);
        }

        $jobRequest->delete();

        return response()->json(['message' => 'Votre candidature a été annulée avec succès.'], 200);
    }
    public function requestsForJob($jobId)
    {
        $authUser = auth('sanctum')->user();

        // Check if the authenticated user is the employer who owns the job
        $job = Employeur::where('id', $jobId)
            ->where('user_id', $authUser->id)
            ->first();

        if (!$job) {
            return response()->json(['message' => 'Offre non trouvée ou non autorisée.'], 403);
        }

        // Get all requests with user and message
        $requests = JobRequest::where('job_id', $jobId)
            ->with(['user', 'conversationBase.messages' => function ($q) {
                $q->latest()->limit(1);
            }])

            ->get()
            ->map(function ($req) use ($jobId) {
                $firstName = $req->user->first_name ?? '';
                $lastName = $req->user->last_name ?? '';
                $fullName = trim($firstName . ' ' . $lastName);

                $latestMessage = $req->conversationBase
                    && $req->conversationBase->employer_id == $req->employer_id
                    ? $req->conversationBase->messages->first()->content ?? null
                    : null;

                return [
                    'req'=>$req,
                    'user_id' => $req->user->id ?? '',
                    'user_name' => $fullName ?: 'Inconnu',
                    'message' => $latestMessage ?? 'Pas de message',
                    'created_at' =>$req->created_at,
                ];
            });



        return response()->json(['data' => $requests], 200);
    }

    /**
 * Respond to a job request (accept or reject)
 */
public function respondToRequest($requestId, Request $request)
{
    $validated = $request->validate([
        'status' => 'required|in:accepted,rejected'
    ]);

    $user = auth('sanctum')->user();
    $status = $validated['status'];

    $jobRequest = JobRequest::with(['job', 'user'])
        ->where('id', $requestId)
        ->firstOrFail();

    if ($jobRequest->job->user_id != $user->id) {
        return response()->json(['message' => 'Unauthorized action'], 403);
    }

    $jobRequest->update(['status' => $status]);

    // Create a conversation if accepted
    if ($status === 'accepted') {
        Conversation::firstOrCreate([
            'user_id' => $jobRequest->user_id,
            'employer_id' => $jobRequest->employer_id,
        ]);
    }

    \App\Models\Notification::create([
        'user_id' => $jobRequest->user_id,
        'title'   => 'Réponse à votre demande d\'emploi',
        'body'    => 'Votre demande pour le poste "' . $jobRequest->job->job_title . '" a été ' . ($status === 'accepted' ? 'acceptée' : 'rejetée') . '.',
        'type'    => 'job_request',
        'data'    => json_encode([
            'job_id' => $jobRequest->job->id,
            'status' => $status,
            'request_id' => $jobRequest->id,
        ]),
    ]);

    return response()->json([
        'message' => "Demande $status avec succès",
        'request' => [
            'id' => $jobRequest->id,
            'status' => $jobRequest->status,
            'updated_at' => $jobRequest->updated_at
        ]
    ], 200);
}

}
