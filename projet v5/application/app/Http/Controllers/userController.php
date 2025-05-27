<?php

namespace App\Http\Controllers;

use App\Mail\VerificationEmail;
use App\Models\Ban;
use App\Models\Detail;
use App\Models\User;
use App\Notifications\EmailVerificationNotification;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Password;
use App\Mail\ResetPasswordCode;
use App\Mail\NewPasswordMail;
class userController extends Controller
{
    protected $model;
    function __construct()
    {
        $this->model = new User;
    }
    function generateToken($email)
    {
        $token = substr(md5(rand(0, 9) . $email . time()), 0, 32);
        $user = $this->model->whereEmail($email)->first();
        $user->remember_token = $token;
        $user->save();
        return $user;
    }
    function sendEmail($user)
    {
        Mail::to($user->email)->send(new VerificationEmail($user));
    }
    public function register(Request $request)
    {
        if (User::where('email', $request->email)->exists()) {
            return response()->json([
                'message' => "L'utilisateur existe déjà avec cet email.",
            ], 409);
        }
        $request->validate([
            'last_name' => 'required|string',
            'first_name' => 'required|string',
            'num' => 'required|integer',
            'email' => 'required|email|unique:users,email|string',
            'password' => 'required|string|min:8',
            'address' => 'required|string',
            'city' => 'required|string'
        ]);


        // Create new user
        $user = User::create([
            'last_name' => $request->last_name,
            'first_name' => $request->first_name,
            'num' => $request->num,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'address' => $request->address,
            'city' => $request->city,
        ]);

        //event(new Registered($user));
        //$user->notify(new EmailVerificationNotification());
        $token = $this->generateToken($request->email);
        $this->sendEmail($token);
        return response()->json([
            'message' => '
            ',
            'user' => $user
        ], 201);
    }
    public function verify($token)
    {
        $user = User::where('remember_token', $token)->first();
        if (!$user) {
            return response()->json([
                'message' => 'Token non valide.',
            ], 401);
        }
        $user->remember_token = null;
        $user->email_verified_at = now();
        $user->save();
        return view('layouts.email_verified', [
            'message' => 'Compte déjà vérifié.'
        ]);
    }
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email|string',
            'password' => 'required|string'
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Identifiants invalides.'
            ], 401);
        }

        if (!$user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Veuillez vérifier votre adresse e-mail avant de vous connecter.'
            ], 403);
        }


        $ban = Ban::where('user_id', $user->id)
            ->where('is_active', true)
            ->first();
        if ($ban) {
            return response()->json([
                'message' => 'Votre compte est temporairement suspendu. Veuillez réessayer après le ' . $ban->end_date . '.'
            ], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Connexion réussie',
            'user' => $user,
            'token' => $token
        ], 201);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json([
            'message' => 'Logout Successful',
        ]);
    }
    public function index()
    {

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
     * Update the specified resource in storage.
     */
public function update(Request $request)
{
    $user = auth('sanctum')->user();

    if (!$user) {
        return response()->json([
            'message' => 'Utilisateur non authentifié.',
        ], 401);
    }

    // Validate the request
    $validatedData = $request->validate([
        'first_name' => 'required|string|max:255',
        'last_name' => 'required|string|max:255',
        'num' => 'required|numeric',
        'email' => 'required|email|unique:users,email,' . $user->id,
        'address' => 'required|string|max:255',
        'city' => 'required|string|max:255',
        'current_password' => 'required|string',
        'password' => 'nullable|string|min:8|confirmed',
    ]);

    // Check current password
    if (!\Hash::check($request->current_password, $user->password)) {
        return response()->json([
            'message' => 'Mot de passe actuel incorrect.',
        ], 403);
    }

    // Update user details
    $user->first_name = $validatedData['first_name'];
    $user->last_name = $validatedData['last_name'];
    $user->num = $validatedData['num'];
    $user->email = $validatedData['email'];
    $user->address = $validatedData['address'];
    $user->city = $validatedData['city'];

    // Update password if new one is provided
    if (!empty($request->password)) {
        $user->password = bcrypt($request->password);
    }

    $user->save();

    return response()->json([
        'message' => 'Profil mis à jour avec succès.',
        'user' => $user
    ], 200);
}


/**
 * Get user profile data for employer view
 */
/**
 * Get user profile data for employer view
 */
public function getUserProfile($userId)
{
    // Get the authenticated employer
    $employer = auth('sanctum')->user();

    if (!$employer) {
        return response()->json([
            'message' => 'Non autorisé.'
        ], 401);
    }

    // Find the user with their details and job preferences
    $user = User::with(['detail', 'candidats' => function($query) {
        $query->with('category');
    }])->find($userId);

    if (!$user) {
        return response()->json([
            'message' => 'Utilisateur non trouvé.'
        ], 404);
    }

    // Get the user's details or create empty defaults
    $details = $user->detail ?? new Detail();

    // Format job preferences with category information
    $jobPreferences = $user->candidats->map(function($pref) {
        return [
            'category_name' => $pref->category->name ?? 'Non spécifié',
            'job_title' => $pref->job_title,
            'salary' => $pref->salary,
            'type' => $pref->type,
            // Include any other fields you need
        ];
    });

    // Return only professional information
    return response()->json([
        'data' => [
            'first_name' => $user->first_name,
            'last_name' => $user->last_name,
            'profile_picture' => $details->profile_picture,
            'bio' => $details->bio,
            'cv' => $details->cv,
            'professional_experiences' => $details->professional_experiences ?? [],
            'skills' => $details->skills ?? [],
            'education' => $details->education ?? [],
            'job_preferences' => $jobPreferences,
        ]
    ], 200);
}

public function requestPasswordReset(Request $request)
{
    $request->validate(['email' => 'required|email']);

    $user = User::where('email', $request->email)->first();
    if (!$user) {
        return response()->json(['message' => 'Si cet e-mail est enregistré, des instructions ont été envoyées.'], 200);
    }

    $code = rand(100000, 999999);
    DB::table('password_resets')->updateOrInsert(
        ['email' => $user->email],
        ['token' => $code, 'created_at' => now()]
    );

    Mail::to($user->email)->send(new ResetPasswordCode($code));

    return response()->json(['message' => 'Code envoyé si l\'e-mail est enregistré.'], 200);
}

public function verifyResetCode(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'code' => 'required'
    ]);

    $record = DB::table('password_resets')
        ->where('email', $request->email)
        ->where('token', $request->code)
        ->first();

    if (!$record || Carbon::parse($record->created_at)->addMinutes(10)->isPast()) {
        return response()->json(['message' => 'Code invalide ou expiré.'], 400);
    }

    return response()->json(['message' => 'Code vérifié.'], 200);
}

public function resetPassword(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'code' => 'required'
    ]);

    $record = DB::table('password_resets')
        ->where('email', $request->email)
        ->where('token', $request->code)
        ->first();

    if (!$record || Carbon::parse($record->created_at)->addMinutes(10)->isPast()) {
        return response()->json(['message' => 'Code invalide ou expiré.'], 400);
    }

    $user = User::where('email', $request->email)->first();
    if (!$user) {
        return response()->json(['message' => 'Utilisateur non trouvé.'], 404);
    }

    $newPassword = Str::random(10);
    $user->password = Hash::make($newPassword);
    $user->save();

    DB::table('password_resets')->where('email', $request->email)->delete();

    Mail::to($user->email)->send(new NewPasswordMail($newPassword));

    return response()->json(['message' => 'Nouveau mot de passe envoyé.'], 200);
}

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
