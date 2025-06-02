<?php

namespace App\Http\Controllers;

use App\Models\Employeur;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;

class EmployeurController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'employer_type' => 'required|in:entreprise,recruteur',
            'company_name' => 'nullable|string|max:255',
            'company_description' => 'nullable|string',
            'company_website' => 'nullable|url',

            'category_job_id' => 'nullable|exists:category_jobs,id',
            'job_title' => 'required|string|max:255',
            'job_description' => 'required|string',
            'job_location_type' => 'required|in:sur site,téletravail,hybride',
            'job_location' => 'required|string|max:255',
            'salary' => 'nullable|numeric',
            'job_type' => 'required|in:Temps plein,Temps partiel,Contrat,Travail journalier',
            'application_deadline' => 'required|date|after_or_equal:today',
            'contact_email' => 'required|email',

        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        $userId = auth('sanctum')->user()->id;
        $employeur = Employeur::create([
            'employer_type' => $request->employer_type,
            'user_id' => $userId,

            'company_name' => $request->company_name,
            'company_description' => $request->company_description,
            'company_website' => $request->company_website,

            'category_job_id' => $request->category_job_id,
            'job_title' => $request->job_title,
            'job_description' => $request->job_description,
            'job_location_type' => $request->job_location_type,
            'job_location' => $request->job_location,
            'salary' => $request->salary,
            'job_type' => $request->job_type,
            'application_deadline' => $request->application_deadline,
            'contact_email' => $request->contact_email,
        ]);


        return response()->json([
            'message' => 'Job posted successfully.',
            'data' => $employeur
        ], 201);
    }
public function index()
{
    $userId = auth('sanctum')->user()->id;

    $offers = Employeur::with('category')
        ->where('user_id', $userId)
        ->orderByRaw("CASE WHEN status = 'accented' THEN 0 ELSE 1 END")
        ->orderBy('created_at', 'desc')
        ->get();

    if ($offers->isEmpty()) {
        return response()->json([
            'message' => 'Aucune offre trouvée.',
            'data' => []
        ], 200);
    }

    return response()->json([
        'message' => 'Offres récupérées avec succès.',
        'data' => $offers->map(function ($offer) {
            return [
                'id' => $offer->id,
                'job_title' => $offer->job_title,
                'job_type' => $offer->job_type,
                'salary' => $offer->salary,
                'category_name' => $offer->category->name ?? 'Inconnu',
                'application_deadline' => $offer->application_deadline,
                'job_location_type' => $offer->job_location_type,
                'job_location' => $offer->job_location,
                'status' => $offer->status,
                'employer_type' => $offer->employer_type,
                'company_name' => $offer->company_name,
                'company_description' => $offer->company_description,
                'company_website' => $offer->company_website,
                'note' => $offer->note,
                'contact_email' => $offer->contact_email,
                'job_description' => $offer->job_description,
            ];
        })
    ], 200);
}

    public function destroy($id)
    {
        // Check if the offer exists and belongs to the authenticated user
        $userId = auth('sanctum')->user()->id;
        $offer = Employeur::where('id', $id)->where('user_id', $userId)->first();

        if (!$offer) {
            return response()->json([
                'message' => 'Offre introuvable ou non autorisée à supprimer.',
            ], 404);
        }
        $offer->delete();

        return response()->json([
            'message' => 'Offre supprimée avec succès.',
        ], 200);
    }
public function close($id)
{
    $userId = auth('sanctum')->user()->id;
    $offer = Employeur::where('id', $id)
                ->where('user_id', $userId)
                ->first();

    if (!$offer) {
        return response()->json([
            'message' => 'Offre introuvable ou non autorisée à fermer.',
        ], 404);
    }

    $offer->update(['status' => 'closed']);

    return response()->json([
        'message' => 'Offre fermée avec succès.',
    ], 200);
}

public function reopen($id, Request $request)
{
    $userId = auth('sanctum')->user()->id;
    $offer = Employeur::where('id', $id)
                ->where('user_id', $userId)
                ->first();

    if (!$offer) {
        return response()->json([
            'message' => 'Offre introuvable ou non autorisée à réouvrir.',
        ], 404);
    }

    $validator = Validator::make($request->all(), [
        'application_deadline' => 'required|date|after_or_equal:today',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 422);
    }

    $offer->update([
        'status' => 'pending',
        'application_deadline' => $request->application_deadline,
    ]);

    return response()->json([
        'message' => 'Offre réouverte avec succès.',
        'data' => $offer
    ], 200);
}

public function update(Request $request, $id)
{
    $userId = auth('sanctum')->user()->id;

    $offer = Employeur::where('id', $id)
        ->where('user_id', $userId)
        ->first();

    if (!$offer) {
        return response()->json([
            'message' => 'Offre introuvable ou non autorisée à mettre à jour.',
        ], 404);
    }

    $validator = Validator::make($request->all(), [
        'employer_type' => 'required|in:entreprise,recruteur',
        'company_name' => 'nullable|string|max:255',
        'company_description' => 'nullable|string',
        'company_website' => 'nullable|url',

        'category_job_id' => 'nullable|exists:category_jobs,id',
        'job_title' => 'required|string|max:255',
        'job_description' => 'required|string',
        'job_location_type' => 'required|in:sur site,téletravail,hybride',
        'job_location' => 'required|string|max:255',
        'salary' => 'nullable|numeric',
        'job_type' => 'required|in:Temps plein,Temps partiel,Contrat,Travail journalier',
        'application_deadline' => 'required|date|after_or_equal:today',
        'contact_email' => 'required|email',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 422);
    }

    $offer->update([
        'employer_type' => $request->employer_type,
        'company_name' => $request->company_name,
        'company_description' => $request->company_description,
        'company_website' => $request->company_website,
        'category_job_id' => $request->category_job_id,
        'job_title' => $request->job_title,
        'job_description' => $request->job_description,
        'job_location_type' => $request->job_location_type,
        'job_location' => $request->job_location,
        'salary' => $request->salary,
        'job_type' => $request->job_type,
        'application_deadline' => $request->application_deadline,
        'contact_email' => $request->contact_email,
        'status' => 'pending',
    ]);

    return response()->json([
        'message' => 'Offre mise à jour avec succès.',
        'data' => $offer
    ], 200);
}

}
