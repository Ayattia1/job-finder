<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
class userController extends Controller
{
    public function register(Request $request) {
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

        return response()->json([
            'message' => 'User registered successfully.',
            'user' => $user
        ], 201);
    }

    public function login(Request $request){
        $request->validate([
            'email'=>'required|email|string',
            'password'=>'required|string'
        ]);
        $user = User::where('email', $request->email)->first();

        if(!$user || !Hash::check($request->password, $user->password))
        return response()->json([
            'message'=>'Invalid user'
        ],401

    );

    //$user = User::where('email',$request->email)->firstOrFail();
    $token=$user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'message'=>'Login Successful',
        'user'=>$user,
        'token'=>$token
        ], 201);
    }
    public function logout(Request $request){
        $request->user()->currentAccessToken()->delete();
        return response()->json([
            'message'=>'Logout Successful',
            ]);
    }
    public function index()
    {
        //
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
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
