<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function activeAdmin()
    {
        $admins = Admin::where('status', true)->get();
        return view('admin.active', compact('admins'));
    }
    public function inactiveAdmin()
    {
        $admins = Admin::where('status', false)->get();
        return view('admin.inactive', compact('admins'));
    }


    public function deactivateAdmin($id)
    {
        $admin = Admin::findOrFail($id);
        $currentAdmin = auth()->guard('admin')->user();


        if ($currentAdmin->rank === $admin->rank) {
            return redirect()->back()->withErrors(['error' => 'Vous ne pouvez pas désactiver un administrateur de même rang.']);
        }

        $admin->status = false;
        $admin->save();

        return redirect()->back()->with('success', 'Administrateur désactivé avec succès.');
    }


    public function activerAdmin($id)
    {
        $admin = Admin::findOrFail($id);
        $currentAdmin = auth()->guard('admin')->user();

        if ($currentAdmin->rank === $admin->rank) {
            return redirect()->back()->withErrors(['error' => 'Vous ne pouvez pas activer un administrateur de même rang.']);
        }
        $admin->status = true;
        $admin->save();

        return redirect()->back()->with('success', 'Administrateur activer avec succès.');
    }
    public function destroyAdmin($id)
    {
        $admin = Admin::findOrFail($id);
        $currentAdmin = auth()->guard('admin')->user();

        if ($currentAdmin->rank === $admin->rank) {
            return redirect()->back()->withErrors(['error' => 'Vous ne pouvez pas supprimer un administrateur de même rang.']);
        }

        $admin->delete();

        return redirect()->back()->with('success', 'Administrateur supprimé avec succès.');
    }

    public function editAdmin($id)
    {
        $admin = Admin::findOrFail($id);
        $currentAdmin = auth()->guard('admin')->user();

        if ($currentAdmin->rank === $admin->rank) {
            return redirect()->route('admin.active')->withErrors(['error' => 'Vous ne pouvez pas modifier un administrateur de même rang.']);
        }

        return view('admin.editAdmin', compact('admin'));
    }

    public function updateAdmin(Request $request, $id)
    {
        $admin = Admin::findOrFail($id);
        $currentAdmin = auth()->guard('admin')->user();


        if ($currentAdmin->rank === $admin->rank) {
            return redirect()->route('admin.active')->withErrors(['error' => 'Vous ne pouvez pas mettre à jour un administrateur de même rang.']);
        }

        $validated = $request->validate([
            'username' => 'required|string|max:200',
            'email' => 'required|email|unique:admins,email,' . $id,
            'rank' => 'required|integer'
        ]);

        $admin->update($validated);

        return redirect()->route('admin.active')->with('success', 'Administrateur mis à jour avec succès.');
    }
}
