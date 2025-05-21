@extends('backend.layouts.master')

@section('title')
Modifier Catégorie - Panneau d'Administration
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
                <h4 class="page-title pull-left">Modifier Catégorie</h4>
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                    <li><a href="{{ route('admin.categories.index') }}">Toutes les Catégories</a></li>
                    <li><span>Modifier la catégorie - {{ $categorie->name }}</span></li>
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
                    <h4 class="header-title">Modifier la Catégorie - {{ $categorie->name }}</h4>
                    @include('backend.layouts.partials.messages')

                    <form action="{{ route('admin.categories.update', $categorie->id) }}" method="POST">
                        @method('PUT')
                        @csrf
                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="name">Nom de la Catégorie</label>
                                <input type="text" class="form-control" id="name" name="name"
                                    placeholder="Entrez le nom de la catégorie" value="{{ $categorie->name }}">
                            </div>
                        </div>



                        <button type="submit" class="btn btn-primary mt-4 pr-4 pl-4">Mettre à Jour</button>
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
        // Initialize Select2 if needed
        $('.select2').select2();

        // Optional: Add any category-specific scripts here
    });
</script>
@endsection
