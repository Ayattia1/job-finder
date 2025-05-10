@extends('backend.layouts.master')

@section('title')
Modifier Candidat - Panneau d'Administration
@endsection

@section('styles')
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-beta.1/dist/css/select2.min.css" rel="stylesheet" />
@endsection

@section('admin-content')
<style>
    /* Apply the unified form-control styling */
    .form-control {
        height: calc(2.25rem + 2px); /* Matches the default input height */
        padding: 0.375rem 0.75rem;
        border-radius: 0.375rem;
        border: 1px solid #ced4da;
    }

    /* Styling for Select2 to match form-control */
    .select2-container .select2-selection--single {
        height: calc(2.25rem + 2px); /* Matches form-control height */
        padding: 0.375rem 0.75rem;
        border-radius: 0.375rem;
        border: 1px solid #ced4da;
    }

    .select2-container .select2-selection__rendered {
        line-height: calc(2.25rem + 2px); /* Ensure the text aligns properly */
    }

    .select2-container--default .select2-selection--single .select2-selection__arrow {
        height: calc(2.25rem + 2px); /* Align the arrow with input height */
    }
</style>

<!-- Zone du titre de la page -->
<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <h4 class="page-title pull-left">Modifier Candidat</h4>
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                    <li><a href="{{ route('admin.candidats.index') }}">Tous les Candidats</a></li>
                    <li><span>Modifier Candidat - {{ $candidat->user->email }}</span></li>
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
                    <h4 class="header-title">Modifier Candidat - {{ $candidat->user->email }}</h4>
                    @include('backend.layouts.partials.messages')

                    <form action="{{ route('admin.candidats.update', $candidat->id) }}" method="POST">
                        @method('PUT')
                        @csrf
                        <!-- Hidden user_id field -->
                        <input type="hidden" name="user_id" value="{{ $candidat->user->id }}">

                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="user_id">Utilisateur</label>
                                <input type="text" class="form-control" id="user_id" value="{{ $candidat->user->email }}" readonly>
                            </div>

                            <div class="form-group col-md-6 col-sm-12">
                                <label for="category_id">Catégorie</label>
                                <select name="category_id" id="category_id" class="form-control select2">
                                    @foreach ($categories as $category)
                                        <option value="{{ $category->id }}" {{ $candidat->category_id == $category->id ? 'selected' : '' }}>
                                            {{ $category->name }}
                                        </option>
                                    @endforeach
                                </select>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="job_title">Titre d'emploi</label>
                                <input type="text" class="form-control" id="job_title" name="job_title" placeholder="Entrez le titre de l'emploi" value="{{ $candidat->job_title }}">
                            </div>
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="salary">Salaire</label>
                                <input type="text" class="form-control" id="salary" name="salary" placeholder="Entrez le salaire" value="{{ $candidat->salary }}">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label for="type">Type de Travail</label>
                                <select name="type" id="type" class="form-control">
                                    <option value="Temps plein" {{ $candidat->type == 'Temps plein' ? 'selected' : '' }}>Temps plein</option>
                                    <option value="Temps partiel" {{ $candidat->type == 'Temps partiel' ? 'selected' : '' }}>Temps partiel</option>
                                    <option value="Contrat" {{ $candidat->type == 'Contrat' ? 'selected' : '' }}>Contrat</option>
                                    <option value="Travail journalier" {{ $candidat->type == 'Travail journalier' ? 'selected' : '' }}>Travail journalier</option>
                                </select>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary mt-4 pr-4 pl-4">Enregistrer Candidat</button>
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
    });
</script>
@endsection
