<?php

namespace App\Http\Controllers\Backend;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\Ban;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class BanController extends Controller
{
    public function index()
    {
        $this->checkAuthorization(auth()->user(), ['ban.view']);
        $bans = Ban::with(['user', 'admin'])
            ->orderByDesc('is_active')
            ->orderByDesc('created_at')
            ->get();

        return view('backend.pages.bans.index', compact('bans'));
    }


    public function store(Request $request)
    {
        $this->checkAuthorization(auth()->user(), ['ban.create']);
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'reason' => 'required|string',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);
        $admin = Auth::guard('admin')->user();
        $user = User::find($request->user_id);
        $user->tokens()->delete();
        Ban::create([
            'user_id' => $request->user_id,
            'admin_id' => $admin->id,
            'reason' => $request->reason,
            'end_date' => $request->end_date,
        ]);

        return redirect()->route('admin.bans.index')->with('success', 'Utilisateur banni avec succès.');
    }

    public function edit(Ban $ban)
    {
        $this->checkAuthorization(auth()->user(), ['ban.edit']);
        return view('backend.pages.bans.edit', compact('ban'));
    }

    public function update(Request $request, Ban $ban)
    {
        $this->checkAuthorization(auth()->user(), ['ban.update']);
        $request->validate([
            'reason' => 'required|string',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        $ban->update([
            'reason' => $request->reason,
            'end_date' => $request->end_date,
        ]);

        return redirect()->route('admin.bans.index')->with('success', 'Bannissement mis à jour.');
    }

    public function destroy(Ban $ban)
    {
        $this->checkAuthorization(auth()->user(), ['ban.delete']);
        $ban->delete();

        return redirect()->route('admin.bans.index')->with('success', 'Bannissement supprimé.');
    }
}
