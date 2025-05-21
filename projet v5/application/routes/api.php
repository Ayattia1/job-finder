<?php
use App\Http\Controllers\CandidatController;
use App\Http\Controllers\DetailController;
use App\Http\Controllers\EmployeurController;
use App\Http\Controllers\JobController;
use App\Http\Controllers\MessageController;
use App\Http\Controllers\RequestController;
use App\Http\Controllers\userController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\NotificationController;
/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

//Route::get('welcome',[welcomeController::class,'welcome']);
Route::post('register',[userController::class,'register']);
Route::post('login',[userController::class,'login']);
Route::get('index',[userController::class,'index'])->middleware('auth:sanctum');
Route::put('user', [UserController::class, 'update'])->middleware('auth:sanctum');
Route::post('details', [DetailController::class, 'store'])->middleware('auth:sanctum');
Route::get('details', [DetailController::class, 'index'])->middleware('auth:sanctum');
Route::post('upload-profile-image', [DetailController::class, 'uploadProfileImage'])->middleware('auth:sanctum');
Route::post('upload-cv', [DetailController::class, 'uploadCV'])->middleware('auth:sanctum');
Route::post('candidat', [CandidatController::class, 'store'])->middleware('auth:sanctum');
Route::get('candidat', [CandidatController::class, 'index'])->middleware('auth:sanctum');
Route::put('/candidat/{id}', [CandidatController::class, 'update'])->middleware('auth:sanctum');
Route::delete('/candidat/{id}', [CandidatController::class, 'destroy'])->middleware('auth:sanctum');
Route::get('/categories', [candidatController::class, 'category']);
Route::post('/employeurs', [EmployeurController::class, 'store'])->middleware('auth:sanctum');
Route::get('/employeurs', [EmployeurController::class, 'index'])->middleware('auth:sanctum');
Route::put('/employeurs/{id}', [EmployeurController::class, 'update'])->middleware('auth:sanctum');
Route::delete('/employeurs/{id}', [EmployeurController::class, 'destroy'])->middleware('auth:sanctum');
Route::post('/employeurs/{id}/close', [EmployeurController::class, 'close'])->middleware('auth:sanctum');
Route::post('/employeurs/{id}/reopen', [EmployeurController::class, 'reopen'])->middleware('auth:sanctum');
Route::get('/conversations', [MessageController::class, 'conversations'])->middleware('auth:sanctum');
Route::get('/notifications', [NotificationController::class, 'index'])->middleware('auth:sanctum');
Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead'])->middleware('auth:sanctum');
Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount'])->middleware('auth:sanctum');



Route::get('/offres', [JobController::class, 'index'])->middleware('auth:sanctum');
Route::get('/offres/for-you', [JobController::class, 'forYou'])->middleware('auth:sanctum');
Route::get('/requests', [RequestController::class, 'userRequests'])->middleware('auth:sanctum');
Route::post('/requests', [RequestController::class, 'store'])->middleware('auth:sanctum');
Route::get('/requests/check/{jobId}', [RequestController::class, 'checkIfApplied'])->middleware('auth:sanctum');
Route::delete('/requests/{jobId}', [RequestController::class, 'destroy'])->middleware('auth:sanctum');
Route::get('/messages', [MessageController::class, 'index'])->middleware('auth:sanctum');
Route::post('/messages', [MessageController::class, 'store'])->middleware('auth:sanctum');
Route::get('/employeur/{jobId}/requests', [RequestController::class, 'requestsForJob'])->middleware('auth:sanctum');
Route::post('/employeur/requests/{request}/respond', [RequestController::class, 'respondToRequest'])->middleware('auth:sanctum');

Route::get('/user/{id}/profile', [userController::class, 'getUserProfile'])->middleware('auth:sanctum');
Route::get('/offres/search', [JobController::class, 'search'])->middleware('auth:sanctum');
Route::post('logout',[userController::class,'logout'])->middleware('auth:sanctum');
Route::get('/verifyMail/{token}', [userController::class,'verify']);
Route::middleware('auth:sanctum')->get('/verify-token', function (Request $request) {
    return response()->json(['message' => 'Token is valid'], 200);
});
