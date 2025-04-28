<?php

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Backend\AdminsController;
use App\Http\Controllers\Backend\Auth\ForgotPasswordController;
use App\Http\Controllers\Backend\Auth\LoginController;
use App\Http\Controllers\Backend\BanController;
use App\Http\Controllers\Backend\DashboardController;
use App\Http\Controllers\Backend\ProfilesController;
use App\Http\Controllers\Backend\RolesController;
use App\Http\Controllers\testMail;
use Symfony\Component\HttpKernel\Profiler\Profile;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Route::get('/', function () {
//     return view('welcome');
// });

Auth::routes();

Route::get('/', 'HomeController@redirectAdmin')->name('index');
Route::get('/home', 'HomeController@index')->name('home');
/**
 * Admin routes
 */
Route::group(['prefix' => 'admin', 'as' => 'admin.'], function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    Route::resource('roles', RolesController::class);
    Route::resource('admins', AdminsController::class);
    Route::resource('profiles', ProfilesController::class);
    Route::post('/bans', [BanController::class, 'store'])->name('ban.store');
    Route::get('/bans', [BanController::class, 'index'])->name('bans.index');
    Route::get('/bans/{ban}/edit', [BanController::class, 'edit'])->name('bans.edit');
    Route::put('/bans/{ban}', [BanController::class, 'update'])->name('bans.update');
    Route::delete('/bans/{ban}', [BanController::class, 'destroy'])->name('bans.destroy');
    Route::get('profile', [AdminsController::class, 'profile'])->name('profile');
    Route::get('profile/edit', [AdminsController::class, 'editProfile'])->name('profile.edit');
    Route::put('profile/update', [AdminsController::class, 'updateProfile'])->name('profile.update');




    // Login Routes.
    Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
    Route::post('/login/submit', [LoginController::class, 'login'])->name('login.submit');

    // Logout Routes.
    Route::post('/logout/submit', [LoginController::class, 'logout'])->name('logout.submit');

    // Forget Password Routes.
    Route::get('/password/reset', [ForgotPasswordController::class, 'showLinkRequestForm'])->name('password.request');
    Route::post('/password/reset/submit', [ForgotPasswordController::class, 'reset'])->name('password.update');
})->middleware('auth:admin');
