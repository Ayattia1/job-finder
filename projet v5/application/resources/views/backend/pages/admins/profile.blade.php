@extends('backend.layouts.master')

@section('title')
    {{ __('Mon Profil - Panneau d\'Administration') }}
@endsection

@section('admin-content')

<!-- Début de la zone du titre de la page -->
<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <h4 class="page-title pull-left">{{ __('Mon Profil') }}</h4>
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">{{ __('Tableau de Bord') }}</a></li>
                    <li><span>{{ __('Profil') }}</span></li>
                </ul>
            </div>
        </div>
        <div class="col-sm-6 clearfix">
            @include('backend.layouts.partials.logout')
        </div>
    </div>
</div>
<!-- Fin de la zone du titre de la page -->

<div class="main-content-inner">
    <div class="row">
        <!-- Début de la section du profil -->
        <div class="col-lg-6 offset-lg-3 mt-5">
            <div class="card">
                <div class="card-body">
                    <h4 class="header-title">{{ __('Détails du Profil') }}</h4>
                    <div class="profile-details mt-4">
                        <p><strong>{{ __('Nom:') }}</strong> {{ $admin->name }}</p>
                        <p><strong>{{ __('Email:') }}</strong> {{ $admin->email }}</p>
                        <p><strong>{{ __('Rôles:') }}</strong>
                            @foreach ($admin->roles as $role)
                                <span class="badge badge-info mr-1">{{ $role->name }}</span>
                            @endforeach
                        </p>

                        <a href="{{ route('admin.profile.edit', $admin->id) }}" class="btn btn-primary mt-3">
                            {{ __('Modifier le Profil') }}
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <!-- Fin de la section du profil -->
    </div>
</div>
@endsection
