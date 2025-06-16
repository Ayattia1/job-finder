<?php

namespace App\Http\Controllers;

use App\Models\candidat;
use Illuminate\Http\Request;
use App\Models\CategoryJob;

class CandidatController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'categoryJob' => 'required',
            'job_title' => 'required|string',
            'salary' => 'required',
            'type' => 'required|string'
        ]);
        $userId = auth('sanctum')->user()->id;
        $candidas = new candidat();
        $candidas->user_id = $userId;
        $candidas->category_id = $request->categoryJob;
        $candidas->job_title = $request->job_title;
        $candidas->salary = $request->salary;
        $candidas->type = $request->type;
        $candidas->save();
        return response()->json([
            'message' => 'Vos informations enregistrés avec succès.',
            'data' => $candidas
        ], 201);
    }
    public function index()
    {
        $userId = auth('sanctum')->user()->id;
        $preferences = candidat::with('category')->where('user_id', $userId)->get();

        if ($preferences->isEmpty()) {
            return response()->json([
                'message' => 'Aucune préférence trouvée.',
                'data' => []
            ], 200);
        }

        return response()->json([
            'message' => 'Préférences récupérées avec succès.',
            'data' => $preferences->map(function ($preference) {
                return [
                    'id' => $preference->id,
                    'job_title' => $preference->job_title,
                    'type' => $preference->type,
                    'salary' => $preference->salary,
                    'category_name' => $preference->category->name ?? 'Inconnu'
                ];
            })
        ]);
    }
    public function destroy($id)
    {
        $userId = auth('sanctum')->user()->id;
        $candidas = candidat::where('user_id', $userId)->find($id);

        if (!$candidas) {
            return response()->json([
                'message' => 'Préférence introuvable.',
            ], 404);
        }

        $candidas->delete();

        return response()->json([
            'message' => 'Préférence supprimée avec succès.',
        ]);
    }
    public function update(Request $request, $id)
    {
        $request->validate([
            'categoryJob' => 'required',
            'job_title' => 'required|string',
            'salary' => 'required',
            'type' => 'required|string'
        ]);

        $userId = auth('sanctum')->user()->id;
        $candidas = candidat::where('user_id', $userId)->find($id);

        if (!$candidas) {
            return response()->json([
                'message' => 'Préférence introuvable.',
            ], 404);
        }

        $candidas->category_id = $request->categoryJob;
        $candidas->job_title = $request->job_title;
        $candidas->salary = $request->salary;
        $candidas->type = $request->type;
        $candidas->save();

        return response()->json([
            'message' => 'Préférence mise à jour avec succès.',
            'data' => $candidas
        ]);
    }

    public function category()
    {
        $categories = CategoryJob::select('id', 'name')->get();

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }
}
