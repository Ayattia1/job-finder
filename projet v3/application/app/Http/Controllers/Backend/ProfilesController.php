<?php

declare(strict_types=1);

namespace App\Http\Controllers\Backend;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProfileRequest;
use App\Models\User;
use Illuminate\Contracts\Support\Renderable;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class ProfilesController extends Controller
{
    public function index(): Renderable
    {
        $this->checkAuthorization(auth()->user(), ['profile.view']);

        return view('backend.pages.users.index', [
            'users' => User::all(),
        ]);
    }

    public function edit(int $id): Renderable
    {
        $this->checkAuthorization(auth()->user(), ['profile.edit']);

        $user = User::findOrFail($id);
        $cities = [
            'Ariana', 'Beja', 'Ben Arous', 'Bizerte', 'Gabès',
            'Gafsa', 'Jendouba', 'Kairouan', 'Kasserine', 'Kebili',
            'Kef', 'Mahdia', 'Manouba', 'Médenine', 'Monastir',
            'Nabeul', 'Sfax', 'Sidi Bouzid', 'Siliana', 'Sousse',
            'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan'
        ];
        return view('backend.pages.users.edit', compact('user', 'cities'));
    }

    public function update(ProfileRequest $request, int $id): RedirectResponse
    {
        $this->checkAuthorization(auth()->user(), ['profile.edit']);

        $user = User::findOrFail($id);
        
        $user->last_name = $request->last_name;
        $user->first_name = $request->first_name;
        $user->email = $request->email;
        $user->num = $request->num;
        $user->city = $request->city;
        $user->address = $request->address;
        $user->save();

        /*$user->roles()->detach();
        if ($request->roles) {
            $user->assignRole($request->roles);
        }
*/
        session()->flash('success', "L'utilisateur a été mis à jour.");
        return back();
    }

    public function destroy(int $id): RedirectResponse
    {
        $this->checkAuthorization(auth()->user(), ['profile.delete']);

        $user = User::findOrFail($id);
        $user->delete();
        session()->flash('success', "L'utilisateur a été supprimer");
        return back();
    }
    public function show($id): Renderable
    {
        // Récupérer l'utilisateur par son ID
        $this->checkAuthorization(auth()->user(), ['profile.show']);

        $user = User::findOrFail($id);

        return view('backend.profiles.show', compact('user'));
    }
}
