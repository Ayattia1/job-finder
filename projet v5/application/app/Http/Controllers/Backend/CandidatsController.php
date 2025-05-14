<?php

namespace App\Http\Controllers\Backend;

use App\Http\Controllers\Controller;
use App\Models\candidat;
use App\Models\categoryJob;
use App\Models\User;
use Illuminate\Http\Request;

class CandidatsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $this->checkAuthorization(auth()->user(), ['candidat.view']);
        $candidats = Candidat::with('user', 'category')->get();
        return view('backend.pages.users.candidat.index', compact('candidats'));
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
    public function show(string $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        $this->checkAuthorization(auth()->user(), ['candidat.edit']);

        $candidat = Candidat::findOrFail($id);
        $users = User::all();
        $categories = categoryJob::all();

        return view('backend.pages.users.candidat.edit', compact('candidat', 'users', 'categories'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $this->checkAuthorization(auth()->user(), ['candidat.edit']);

        $request->validate([
            'user_id' => 'required|exists:users,id',
            'category_id' => 'nullable|exists:category_jobs,id',
            'job_title' => 'required|string|max:255',
            'salary' => 'nullable|string|max:255',
            'type' => 'nullable|string|max:255',
        ]);
        $candidat = Candidat::findOrFail($id);

        $updated = $candidat->update([
            'user_id' => $request->user_id,
            'category_id' => $request->category_id,
            'job_title' => $request->job_title,
            'salary' => $request->salary,
            'type' => $request->type,
        ]);
        return redirect()->route('admin.candidats.index')->with('success', 'Candidat mis à jour avec succès.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $this->checkAuthorization(auth()->user(), ['candidat.delete']);

        $candidat = Candidat::findOrFail($id);
        $candidat->delete();

        return redirect()->route('admin.candidats.index')->with('success', 'Candidat supprimé avec succès.');
    }


}
