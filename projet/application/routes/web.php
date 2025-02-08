<?php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|

*/
Route::get('/', function () {
    return view('welcome');
});
Route::prefix('admin')->name('admin.')->group(function(){

    Route::middleware('isAdmin')->group(function(){
        Route::view('dashboard','admin.dashboard')->name('dashboard');
        Route::middleware('checkSuperAdmin')->group(function(){
            Route::get('active', [AdminController::class, 'activeAdmin'])->name('active');
            Route::get('inactive', [AdminController::class, 'inactiveAdmin'])->name('inactive');
            Route::post('/{id}/deactivate', [AdminController::class, 'deactivateAdmin'])->name('deactivate');
            Route::post('/{id}/activer', [AdminController::class, 'activerAdmin'])->name('activer');
            Route::delete('admin/delete/{id}', [AdminController::class, 'destroyAdmin'])->name('delete');
            Route::get('edit/{id}', [AdminController::class, 'editAdmin'])->name('edit');
            Route::put('update/{id}', [AdminController::class, 'updateAdmin'])->name('update');
        });
        Route::middleware('checkManager')->group(function(){
        });
    });
    require __DIR__.'/admin_auth.php';

});






/*
Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';
*/
