<?php

namespace App\Http\Controllers\Backend;

use App\Http\Controllers\Controller;
use App\Models\categoryJob;
use App\Models\Employeur;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;

class EmployeursController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $this->checkAuthorization(auth()->user(), ['employeur.view']);

        $status = $request->get('status', 'pending');
        $employeurs = Employeur::with('user', 'category')
            ->where('status', $status)
            ->get();

        return view('backend.pages.users.employeur.index', compact('employeurs', 'status'));
    }

    public function updateStatus(Request $request, $id)
    {
        $this->checkAuthorization(auth()->user(), ['employeur.status']);

        $employeur = Employeur::findOrFail($id);
        $oldStatus = $employeur->status;

        $employeur->status = $request->input('status');
        $employeur->note = $request->input('note');
        $employeur->save();

        if ($employeur->user_id) {
            $body = 'Le statut de votre offre "' . $employeur->job_title . '" a été mis à jour à "' . $employeur->status . '".';

            if ($employeur->status === 'rejected' && $employeur->note) {
                $body .= ' Raison: ' . $employeur->note;
            }

            \App\Models\Notification::create([
                'user_id' => $employeur->user_id,
                'title' => 'Mise à jour de votre offre',
                'body'  => $body,
                'type'  => 'job_offre',
                'data'  => json_encode([
                    'job_id' => $employeur->id,
                    'new_status' => $employeur->status,
                ]),
            ]);
        }


        if ($oldStatus !== 'accepted' && $employeur->status === 'accepted') {
            if ($employeur->category_job_id) {
                $matchingCandidates = \App\Models\candidat::where('category_id', $employeur->category_job_id)->get();

                foreach ($matchingCandidates as $candidate) {
                    // Avoid notifying the same user if they're also a candidate
                    if ($candidate->user_id && $candidate->user_id !== $employeur->user_id) {
                        \App\Models\Notification::create([
                            'user_id' => $candidate->user_id,
                            'title' => 'Nouvelle offre d\'emploi disponible',
                            'body' => 'Une nouvelle offre "' . $employeur->job_title . '" correspondant à votre catégorie est maintenant disponible.',
                            'type' => 'new_job',
                            'data' => json_encode([
                                'job_id' => $employeur->id,
                                'category_id' => $employeur->category_job_id,
                            ]),
                        ]);
                    }
                }
            }
        }

        return redirect()->route('admin.employeurs.index')->with('success', 'Statut mis à jour avec succès.');
    }





    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $employeur = Employeur::with('user', 'category')->findOrFail($id);
        return view('backend.pages.users.employeur.show', compact('employeur'));
    }



    /**
     * Show the form for editing the specified resource.
     */
    public function edit($id)
    {
        $this->checkAuthorization(auth()->user(), ['employeur.edit']);

        $employeur = Employeur::with('user', 'category')->findOrFail($id);
        $categories = $categories = categoryJob::all();

        return view('backend.pages.users.employeur.edit', compact('employeur', 'categories'));
    }


    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $this->checkAuthorization(auth()->user(), ['employeur.edit']);

        $employeur = Employeur::findOrFail($id);

        $request->validate([
            'job_title' => 'required|string|max:255',
            'job_type' => 'required|string|max:255',
            'job_location_type' => 'required|string',
            'job_location' => 'nullable|string|max:255',
            'salary' => 'nullable|numeric',
            'job_description' => 'nullable|string',
            'application_deadline' => 'nullable|date',
            'company_name' => 'nullable|string|max:255',
            'company_description' => 'nullable|string',
            'company_website' => 'nullable|url',
        ]);

        $employeur->update($request->all());

        return redirect()->route('admin.employeurs.index')->with('success', 'Informations mises à jour avec succès.');
    }


    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $this->checkAuthorization(auth()->user(), ['employeur.delete']);

        $candidat = Employeur::findOrFail($id);
        $candidat->delete();

        return redirect()->route('admin.employeurs.index')->with('success', 'employeur supprimé avec succès.');
    }
}
