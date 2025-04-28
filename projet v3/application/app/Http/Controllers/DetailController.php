<?php

namespace App\Http\Controllers;

use App\Models\Detail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class DetailController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'profile_picture' => 'nullable|image|max:2048',
            'cv' => 'nullable|mimes:pdf|max:5120',
            'bio' => 'nullable|string',

            'professional_experiences' => 'nullable|array',
            'professional_experiences.*.position' => 'required_with:professional_experiences|string',
            'professional_experiences.*.entreprise' => 'required_with:professional_experiences|string',
            'professional_experiences.*.date_p' => 'required_with:professional_experiences|date',
            'professional_experiences.*.date_f' => 'nullable|date',

            'skills' => 'nullable|array',
            'skills.*' => 'string',

            'education' => 'nullable|array',
            'education.*.diplome' => 'required_with:education|string',
            'education.*.etablissement' => 'required_with:education|string',
            'education.*.years' => 'required_with:education|string',
        ]);
        $userId = auth('sanctum')->user()->id;

        $detail = Detail::where('user_id', $userId)->first();

        if ($detail) {
            $detail->profile_picture = $request->file('profile_picture') ? $request->file('profile_picture')->store('profile_pictures', 'public') : $detail->profile_picture;
            $detail->cv = $request->file('cv') ? $request->file('cv')->store('cvs', 'public') : $detail->cv;
            $detail->bio = $request->bio ?? $detail->bio;
            $detail->professional_experiences = $request->professional_experiences ?? $detail->professional_experiences;
            $detail->skills = $request->skills ?? $detail->skills;
            $detail->education = $request->education ?? $detail->education;

            $detail->save();

            return response()->json([
                'message' => 'Détails professionnels mis à jour avec succès.',
                'data' => $detail
            ], 200);
        } else {
            $profilePicturePath = $request->file('profile_picture') ? $request->file('profile_picture')->store('profile_pictures', 'public') : null;
            $cvPath = $request->file('cv') ? $request->file('cv')->store('cvs', 'public') : null;

            $detail = new Detail();
            $detail->user_id = $userId;
            $detail->profile_picture = $profilePicturePath;
            $detail->cv = $cvPath;
            $detail->bio = $request->bio;
            $detail->professional_experiences = $request->professional_experiences;
            $detail->skills = $request->skills;
            $detail->education = $request->education;
            $detail->save();

            return response()->json([
                'message' => 'Détails enregistrés avec succès.',
                'data' => $detail
            ], 201);
        }
    }


    public function index()
    {
        $userId = auth('sanctum')->user()->id;
        $detail = DB::table('Details')->where('user_id', $userId)->first();

        if (!$detail) {
            // Return a default empty structure instead of 404
            return response()->json([
                'message' => 'success',
                'data' => [
                    'profile_picture' => null,
                    'cv' => null,
                    'bio' => 'Pas de biographie',
                    'professional_experiences' => [],
                    'skills' => [],
                    'education' => [],
                ]
            ]);
        }

        return response()->json([
            'message' => 'success',
            'data' => [
                'profile_picture' => $detail->profile_picture,
                'cv' => $detail->cv,
                'bio' => $detail->bio,
                'professional_experiences' => json_decode($detail->professional_experiences, true),
                'skills' => json_decode($detail->skills, true),
                'education' => json_decode($detail->education, true),
            ]
        ]);
    }



    }
