<?php

namespace App\Http\Controllers;

use App\Models\candidat;
use App\Models\Employeur;
use Illuminate\Http\Request;

class JobController extends Controller
{
    public function index()
    {
        $user = auth('sanctum')->user();
        $userCity = $user->city;

        $jobs = Employeur::with(['category', 'user'])
            ->where('status', 'accepted')
            ->where('user_id', '!=', $user->id)
            ->get()
            ->sortByDesc(function ($job) use ($userCity) {
                return $job->user->city === $userCity ? 1 : 0;
            })
            ->values();

        return response()->json([
            'message' => 'Liste des offres d\'emploi.',
            'data' => $jobs
        ], 200);
    }

    public function forYou()
    {
        $user = auth('sanctum')->user();
        $userCity = $user->city;

        $preferences = candidat::where('user_id', $user->id)->pluck('category_id');

        if ($preferences->isEmpty()) {
            return response()->json([
                'message' => 'Aucune préférence d\'emploi trouvée.',
                'data' => []
            ], 200);
        }

        $jobs = Employeur::with(['category', 'user'])
            ->whereIn('category_job_id', $preferences)
            ->where('status', 'accepted')
            ->where('user_id', '!=', $user->id)
            ->get()
            ->sortByDesc(function ($job) use ($userCity) {
                return $job->user->city === $userCity ? 1 : 0;
            })
            ->values();

        return response()->json([
            'message' => 'Offres correspondant à vos préférences.',
            'data' => $jobs
        ], 200);
    }

    // In your JobController.php
public function search(Request $request)
{
    $query = $request->input('query');

    if (empty($query)) {
        return response()->json(['data' => []]);
    }

    $jobs = Employeur::with(['category', 'user'])
        ->where('status', 'accepted') // Only accepted jobs
        ->where(function ($q) use ($query) {
            $q->where('job_title', 'like', "%$query%")
              ->orWhere('job_description', 'like', "%$query%")
              ->orWhere('company_name', 'like', "%$query%")
              ->orWhere('job_location', 'like', "%$query%")
              ->orWhere('job_type', 'like', "%$query%");
        })
        ->get();

    return response()->json(['data' => $jobs]);
}
}
