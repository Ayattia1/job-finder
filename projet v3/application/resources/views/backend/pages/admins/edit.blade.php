@extends('backend.layouts.master')

@section('title')
Modification d'Administrateur - Panneau d'Administration
@endsection

@section('styles')
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-beta.1/dist/css/select2.min.css" rel="stylesheet" />

<style>
    .form-check-label {
        text-transform: capitalize;
    }
</style>
@endsection

@section('admin-content')

<!-- Début de la zone du titre de la page -->
<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <h4 class="page-title pull-left">Modification d'Administrateur</h4>
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                    <li><a href="{{ route('admin.admins.index') }}">Tous les Administrateurs</a></li>
                    <li><span>Modifier l'Administrateur - {{ $admin->name }}</span></li>
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
        <!-- Début de la table de données -->
        <div class="col-12 mt-5">
            <div class="card">
                <div class="card-body">
                    <h4 class="header-title">Modifier l'Administrateur - {{ $admin->name }}</h4>
                    @include('backend.layouts.partials.messages')

                    <form action="{{ route('admin.admins.update', $admin->id) }}" method="POST">
                        @method('PUT')
                        @csrf
                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="name">Nom de l'Administrateur</label>
                                <input type="text" class="form-control" id="name" name="name" placeholder="Entrez le nom" value="{{ $admin->name }}" required autofocus>
                            </div>
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="email">Email de l'Administrateur</label>
                                <input type="text" class="form-control" id="email" name="email" placeholder="Entrez l'email" value="{{ $admin->email }}" required>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="password">Mot de passe (Optionnel)</label>
                                <input type="password" class="form-control" id="password" name="password" placeholder="Entrez le mot de passe">
                            </div>
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="password_confirmation">Confirmer le mot de passe (Optionnel)</label>
                                <input type="password" class="form-control" id="password_confirmation" name="password_confirmation" placeholder="Entrez le mot de passe">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-6">
                                <label for="password">Attribuer des Rôles</label>
                                <select name="roles[]" id="roles" class="form-control select2" multiple required>
                                    @foreach ($roles as $role)
                                        <option value="{{ $role->name }}" {{ $admin->hasRole($role->name) ? 'selected' : '' }}>{{ $role->name }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="form-group col-md-6 col-sm-6">
                                <label for="username">Nom d'utilisateur</label>
                                <input type="text" class="form-control" id="username" name="username" placeholder="Entrez le nom d'utilisateur" required value="{{ $admin->username }}">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary mt-4 pr-4 pl-4">Enregistrer</button>
                        <a href="{{ route('admin.admins.index') }}" class="btn btn-secondary mt-4 pr-4 pl-4">Annuler</a>
                    </form>
                </div>
            </div>
        </div>
        <!-- Fin de la table de données -->

    </div>
</div>
@endsection

@section('scripts')
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-beta.1/dist/js/select2.min.js"></script>
<script>
    $(document).ready(function() {
        $('.select2').select2();
    })
</script>
@endsection
