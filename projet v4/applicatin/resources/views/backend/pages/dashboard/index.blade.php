@extends('backend.layouts.master')

@section('title')
Page Tableau de Bord - Panneau d'Administration
@endsection


@section('admin-content')

<!-- Début de la zone du titre de la page -->
<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <ul class="breadcrumbs pull-left">
                    <li><a href="index.html">Accueil</a></li>
                    <li><span>Tableau de Bord</span></li>
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
    <div class="col-lg-8">
        <div class="row">
            <div class="col-md-6 mt-5 mb-3">
                <div class="card">
                    <div class="seo-fact sbg1">
                        <a href="{{ route('admin.roles.index') }}">
                            <div class="p-4 d-flex justify-content-between align-items-center">
                                <div class="seofct-icon"><i class="fa fa-user"></i> Rôles</div>
                                <h2>{{ $total_roles }}</h2>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
            <div class="col-md-6 mt-md-5 mb-3">
                <div class="card">
                    <div class="seo-fact sbg2">
                        <a href="{{ route('admin.admins.index') }}">
                            <div class="p-4 d-flex justify-content-between align-items-center">
                                <div class="seofct-icon"><i class="fa fa-user"></i> Administrateurs</div>
                                <h2>{{ $total_admins }}</h2>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
            <div class="col-md-6 mt-5 mb-3 ">
                <div class="card">
                    <div class="seo-fact sbg3">
                        <a href="{{ route('admin.roles.index') }}">
                            <div class="p-4 d-flex justify-content-between align-items-center">
                                <div class="seofct-icon"><i class="fa fa-lock"></i>Permissions</div>
                                <h2>{{ $total_permissions }}</h2>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
            <div class="col-md-6 mt-5 mb-3">
                <div class="card">
                    <div class="seo-fact sbg4">
                        <a href="{{ route('admin.profiles.index') }}">
                            <div class="p-4 d-flex justify-content-between align-items-center">
                                <div class="seofct-icon"><i class="fa fa-users"></i> Utilisateur</div>
                                <h2>{{ $total_users }}</h2>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
  </div>
</div>
@endsection
