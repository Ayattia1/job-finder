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

    // Filter only accepted employeurs
    $jobs = Employeur::with(['category', 'user'])
        ->where('status', 'accepted') // or ->where('status', 1) if it's an integer
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

    // Filter accepted employeurs and matching preferences
    $jobs = Employeur::with(['category', 'user'])
        ->whereIn('category_job_id', $preferences)
        ->where('status', 'accepted') // or ->where('status', 1)
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

}
