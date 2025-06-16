@extends('backend.layouts.master')

@section('title')
    {{ __('Modifier Mon Profil') }}
@endsection

@section('admin-content')
    <div class="page-title-area">
        <div class="row align-items-center">
            <div class="col-sm-6">
                <div class="breadcrumbs-area clearfix">
                    <h4 class="page-title pull-left">{{ __('Modifier Mon Profil') }}</h4>
                    <ul class="breadcrumbs pull-left">
                        <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                        <li><span>Profil</span></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <div class="main-content-inner">
        <div class="row">
            <div class="col-lg-8 offset-lg-2 mt-5">
                <div class="card">
                    <div class="card-body">
                        <form action="{{ route('admin.profile.update') }}" method="POST">
                            @csrf
                            @method('PUT')
                            @if (session('success'))
                                <div class="alert alert-success">
                                    {{ session('success') }}
                                </div>
                            @endif
                            @if ($errors->any())
                                <div class="alert alert-danger">
                                    <ul>
                                        @foreach ($errors->all() as $error)
                                            <li>{{ $error }}</li>
                                        @endforeach
                                    </ul>
                                </div>
                            @endif
                            <div class="form-group">
                                <label>Nom</label>
                                <input type="text" name="name" value="{{ $admin->name }}" class="form-control">
                            </div>

                            <div class="form-group">
                                <label>Nom d'utilisateur</label>
                                <input type="text" name="username" value="{{ $admin->username }}" class="form-control">
                            </div>

                            <div class="form-group">
                                <label>Email</label>
                                <input type="email" name="email" value="{{ $admin->email }}" class="form-control">
                            </div>

                            <div class="form-group">
                                <label>Mot de passe (laisser vide si inchangé)</label>
                                <input type="password" name="password" class="form-control">
                            </div>
                            <div class="form-group">
                                <label>Confirmer le mot de passe</label>
                                <input type="password" name="password_confirmation" class="form-control">
                            </div>
                            <button type="submit" class="btn btn-primary">Mettre à jour</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
