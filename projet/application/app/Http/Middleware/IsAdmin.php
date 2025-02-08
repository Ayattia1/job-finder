<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class IsAdmin
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {

        if (!Auth::guard('admin')->check()){
            return redirect()->route('admin.login');
        }
        $st = Auth::guard('admin')->user()->status;
        if($st == false){
            return redirect()->route('admin.login')->withErrors(['email' => 'Your account is not active']);
        }
            return $next($request);
    }
}
