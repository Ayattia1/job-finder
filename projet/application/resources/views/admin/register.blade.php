@extends('layouts.loginheader')
@section('content')
        <form action="{{route('admin.register')}}" method="POST">
            @csrf
            <h1 class="h3 mb-3 fw-normal">Admin Sign Up</h1>
            <div class="form-floating">
                <input type="text" name="username" :value="old('username')" required class="form-control" id="floatingInput" placeholder="Enter Your UserName" >
                <label for="floatingInput">username</label>
                <x-input-error :messages="$errors->get('username')" class="mt-2 text_start text-danger small" style="list-style:none" />
            </div>

            <div class="form-floating">
                <input type="email" name="email" :value="old('email')" required class="form-control" id="floatingInput" placeholder="name@example.com" >
                <label for="floatingInput">Email address</label>
                <x-input-error :messages="$errors->get('email')" class="mt-2 text_start text-danger small" style="list-style:none" />
            </div>
            <div class="form-floating">
                <input type="password" name="password" :value="old('password')" required class="form-control" id="floatingPassword" placeholder="Password" >
                <label for="floatingPassword">Password</label>
                <x-input-error :messages="$errors->get('password')" class="mt-2 text_start text-danger small" style="list-style:none" />
            </div>
            <div class="form-floating">
                <input type="password" name="password_confirmation" required class="form-control" id="floatingPassword" placeholder="Password" >
                <label for="floatingPassword">Password</label>
                <x-input-error :messages="$errors->get('password_confirmation')" class="mt-2 text_start text-danger small" style="list-style:none" />
            </div>

            <div class="checkbox mb-3">
                <label>
                    <input type="checkbox" value="remember-me"> Remember me
                </label>
            </div>
            <button class="w-100 btn btn-md btn-primary" type="submit">Sign in</button>
            <p class="mt-5 mb-3 text-muted">&copy; 2017–2022</p>
        </form>
   @endsection
