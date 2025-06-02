<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Support\Facades\Auth;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return string|null
     */
    protected function redirectTo($request)
    {
        // If the request expects JSON (API calls), return nothing — causes 401
        if ($request->expectsJson()) {
            return null;
        }

        // Otherwise, redirect to the appropriate login route
        if ($request->is('admin/*')) {
            return route('admin.login');
        }

        return route('admin.login');
    }

}
