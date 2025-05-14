@extends('backend.auth.auth_master')

@section('auth_title')
    Connexion | Panneau d'administration
@endsection

@section('auth-content')
     <!-- zone de connexion début -->
     <div class="login-area">
        <div class="container">
            <div class="login-box ptb--100">
                <form method="POST" action="{{ route('admin.login.submit') }}">
                    @csrf
                    <div class="login-form-head">
                        <h4>Se connecter</h4>
                        <p>Bonjour, connectez-vous et commencez à gérer votre panneau d'administration</p>
                    </div>
                    <div class="login-form-body">
                        @include('backend.layouts.partials.messages')
                        <div class="form-gp">
                            <label for="exampleInputEmail1">Adresse e-mail ou nom d'utilisateur</label>
                            <input type="text" id="exampleInputEmail1" name="email">
                            <i class="ti-email"></i>
                            <div class="text-danger"></div>
                            @error('email')
                                <span class="invalid-feedback" role="alert">
                                    <strong>{{ $message }}</strong>
                                </span>
                            @enderror
                        </div>
                        <div class="form-gp">
                            <label for="exampleInputPassword1">Mot de passe</label>
                            <input type="password" id="exampleInputPassword1" name="password">
                            <i class="ti-lock"></i>
                            <div class="text-danger"></div>
                            @error('password')
                                <span class="invalid-feedback" role="alert">
                                    <strong>{{ $message }}</strong>
                                </span>
                            @enderror
                        </div>
                        <div class="row mb-4 rmber-area">
                            <div class="col-6">
                                <div class="custom-control custom-checkbox mr-sm-2">
                                    <input type="checkbox" class="custom-control-input" id="customControlAutosizing" name="remember">
                                    <label class="custom-control-label" for="customControlAutosizing">Se souvenir de moi</label>
                                </div>
                            </div>
                            {{-- <div class="col-6 text-right">
                                <a href="#">Mot de passe oublié ?</a>
                            </div> --}}
                        </div>
                        <div class="submit-btn-area">
                            <button id="form_submit" type="submit">Se connecter <i class="ti-arrow-right"></i></button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <!-- zone de connexion fin -->
@endsection
