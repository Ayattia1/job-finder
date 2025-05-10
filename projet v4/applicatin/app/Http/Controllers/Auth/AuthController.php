<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Ichtrojan\Otp\Otp;
class AuthController extends Controller
{
    public function verifyEmail(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'otp' => 'required'
    ]);

    $otp = (new Otp)->validate($request->email, $request->otp);

    if (!$otp->status) {
        return response()->json(['message' => 'Invalid or expired code'], 422);
    }

    $user = User::where('email', $request->email)->first();
    $user->markEmailAsVerified();

    return response()->json(['message' => 'Email verified successfully']);
}
}
