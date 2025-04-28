@extends('backend.layouts.master')

@section('title')
Modifier Utilisateur - Panneau d'Administration
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

<!-- Zone du titre de la page -->
<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <h4 class="page-title pull-left">Modifier Utilisateur</h4>
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                    <li><a href="{{ route('admin.profiles.index') }}">Tous les Utilisateurs</a></li>
                    <li><span>Modifier l'utilisateur - {{ $user->first_name }}</span></li>
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
        <!-- Début du formulaire -->
        <div class="col-12 mt-5">
            <div class="card">
                <div class="card-body">
                    <h4 class="header-title">Modifier l'Utilisateur - {{ $user->first_name }}</h4>
                    @include('backend.layouts.partials.messages')

                    <form action="{{ route('admin.profiles.update', $user->id) }}" method="POST">
                        @method('PUT')
                        @csrf
                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="last_name">Nom</label>
                                <input type="text" class="form-control" id="last_name" name="last_name" placeholder="Entrez votre nom" value="{{ $user->last_name }}">
                            </div>
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="first_name">Prénom</label>
                                <input type="text" class="form-control" id="first_name" name="first_name" placeholder="Entrez votre prénom" value="{{ $user->first_name }}">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="email">Email</label>
                                <input type="email" class="form-control" id="email" name="email" placeholder="Entrez votre email" value="{{ $user->email }}">
                            </div>
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="address">Adresse</label>
                                <input type="text" class="form-control" id="address" name="address" placeholder="Entrez votre adresse" value="{{ $user->address }}">
                            </div>
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="num">Téléphone</label>
                                <input type="text" class="form-control" id="num" name="num" placeholder="Entrez votre numéro de téléphone" value="{{ $user->num }}">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="cities">Votre Ville</label>
                                <select name="city" id="cities" class="form-control select2">
                                    @foreach ($cities as $city)
                                        <option value="{{ $city }}" {{ $user->city == $city ? 'selected' : '' }}>
                                            {{ $city }}
                                        </option>
                                    @endforeach
                                </select>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary mt-4 pr-4 pl-4">Enregistrer l'Utilisateur</button>
                    </form>
                </div>
            </div>
        </div>
        <!-- Fin du formulaire -->

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
