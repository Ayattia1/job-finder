<?php

declare(strict_types=1);

namespace App\Http\Controllers\Backend;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProfileRequest;
use App\Models\candidat;
use App\Models\Detail;
use App\Models\User;
use Illuminate\Contracts\Support\Renderable;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class SubscribersController extends Controller
{
    public function index(): Renderable
    {
        $this->checkAuthorization(auth()->user(), ['subscriber.view']);

        return view('backend.pages.users.index', [
            'users' => User::all(),
        ]);
    }

    public function edit(int $id): Renderable
    {
        $this->checkAuthorization(auth()->user(), ['subscriber.edit']);

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
        $this->checkAuthorization(auth()->user(), ['subscriber.edit']);

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
        $this->checkAuthorization(auth()->user(), ['subscriber.delete']);

        $user = User::findOrFail($id);
        $user->delete();
        session()->flash('success', "L'utilisateur a été supprimer");
        return back();
    }
public function show($id): Renderable
{
    $this->checkAuthorization(auth()->user(), ['subscriber.show']);

    $user = User::findOrFail($id);
    $detail = $user->detail;
    $candidats = Candidat::where('user_id', $user->id)->get();

    return view('backend.pages.users.detail', compact('user', 'detail', 'candidats'));

}


}
