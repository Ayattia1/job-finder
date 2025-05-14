<?php

namespace App\Http\Controllers;

use App\Mail\VerificationEmail;
use App\Models\Ban;
use App\Models\User;
use App\Notifications\EmailVerificationNotification;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

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
        // Get the currently authenticated user
        $user = auth('sanctum')->user();

        if (!$user) {
            return response()->json([
                'message' => 'Utilisateur non authentifié.',
            ], 401);
        }

        // Validate the request
        $request->validate([
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'num' => 'required|numeric',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'address' => 'required|string|max:255',
            'city' => 'required|string|max:255',
        ]);

        // Update user attributes
        $user->update([
            'first_name' => $request->first_name,
            'last_name' => $request->last_name,
            'num' => $request->num,
            'email' => $request->email,
            'address' => $request->address,
            'city' => $request->city,
        ]);

        return response()->json([
            'message' => 'Informations utilisateur mises à jour avec succès.',
            'user' => $user
        ], 200);
    }




    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
