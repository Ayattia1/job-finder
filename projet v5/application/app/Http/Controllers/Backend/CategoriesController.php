<?php
namespace App\Http\Controllers\Backend;
use App\Http\Controllers\Controller;
use App\Models\categoryjob; // Changed casing to PascalCase
use Illuminate\Http\Request;

class CategoriesController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $this->checkAuthorization(auth()->user(), ['categorie.view']); // Fixed permission key
        $categories = categoryjob::all(); // Corrected model casing
        return view('backend.pages.categories.index', compact('categories'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $this->checkAuthorization(auth()->user(), ['categorie.create']); // Fixed permission key
        return view('backend.pages.categories.create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $this->checkAuthorization(auth()->user(), ['categorie.create']); // Fixed permission key

        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:category_jobs', // Corrected table name
            'description' => 'nullable|string',
        ]);

        categoryjob::create($validated); // Corrected model casing

        return redirect()->route('admin.categories.index')
            ->with('success', 'categorie created successfully.');
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit($id)
    {
        $this->checkAuthorization(auth()->user(), ['categorie.edit']); // Fixed permission key
        $categorie = categoryjob::findOrFail($id); // Corrected model casing and variable name
        return view('backend.pages.categories.edit', compact('categorie')); // Fixed variable name
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $this->checkAuthorization(auth()->user(), ['categorie.edit']); // Fixed permission key

        $categorie = categoryjob::findOrFail($id); // Corrected model casing and variable name

        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:category_jobs,name,'.$id, // Corrected table name
            'description' => 'nullable|string',
        ]);

        $categorie->update($validated);

        return redirect()->route('admin.categories.index')
            ->with('success', 'categorie updated successfully.'); // Capitalized success message
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $this->checkAuthorization(auth()->user(), ['categorie.delete']); // Fixed permission key
        $categorie = categoryjob::findOrFail($id); // Corrected model casing and variable name
        $categorie->delete();

        return redirect()->route('admin.categories.index')
            ->with('success', 'categorie deleted successfully.'); // Capitalized success message
    }
}
