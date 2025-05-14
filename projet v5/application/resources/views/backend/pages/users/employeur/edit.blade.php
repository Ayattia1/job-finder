@extends('backend.layouts.master')

@section('title')
    Modifier l'Employeur
@endsection

@push('styles')
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
@endpush

@section('admin-content')
    <div class="page-title-area">
        <div class="row align-items-center">
            <div class="col-sm-6">
                <div class="breadcrumbs-area clearfix">
                    <ul class="breadcrumbs pull-left">
                        <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                        <li><a href="{{ route('admin.employeurs.index') }}">Employeurs</a></li>
                        <li><span>Modifier</span></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <div class="main-content-inner">
        <div class="row">
            <div class="col-lg-10 offset-lg-1">
                <div class="card mt-5">
                    <div class="card-body">
                        <h4 class="header-title">Modifier l'Employeur</h4>

                        <form action="{{ route('admin.employeurs.update', $employeur->id) }}" method="POST">
                            @csrf
                            @method('PUT')

                            <div class="form-group">
                                <label>Titre du Poste</label>
                                <input type="text" name="job_title" class="form-control"
                                       value="{{ old('job_title', $employeur->job_title) }}">
                            </div>

                            <div class="form-group">
                                <label>Type de Poste</label>
                                <select name="job_type" class="form-control">
                                    <option value="Temps plein" {{ $employeur->job_type == 'Temps plein' ? 'selected' : '' }}>Temps plein</option>
                                    <option value="Temps partiel" {{ $employeur->job_type == 'Temps partiel' ? 'selected' : '' }}>Temps partiel</option>
                                    <option value="Contrat" {{ $employeur->job_type == 'Contrat' ? 'selected' : '' }}>Contrat</option>
                                    <option value="Travail journalier" {{ $employeur->job_type == 'Travail journalier' ? 'selected' : '' }}>Travail journalier</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Catégorie</label>
                                <select name="category_job_id" class="form-control select2">
                                    <option value="">-- Sélectionner --</option>
                                    @foreach ($categories as $category)
                                        <option value="{{ $category->id }}"
                                            {{ $employeur->category_job_id == $category->id ? 'selected' : '' }}>
                                            {{ $category->name }}
                                        </option>
                                    @endforeach
                                </select>
                            </div>


                            <div class="form-group">
                                <label>Type de Localisation</label>
                                <select name="job_location_type" class="form-control">
                                    <option value="distant" {{ $employeur->job_location_type == 'distant' ? 'selected' : '' }}>Distant</option>
                                    <option value="sur site" {{ $employeur->job_location_type == 'dur site' ? 'selected' : '' }}>Sur site</option>
                                    <option value="hybride" {{ $employeur->job_location_type == 'hybride' ? 'selected' : '' }}>Hybride</option>
                                </select>

                            </div>

                            <div class="form-group">
                                <label>Localisation</label>
                                <input type="text" name="job_location" class="form-control"
                                       value="{{ old('job_location', $employeur->job_location) }}">
                            </div>

                            <div class="form-group">
                                <label>Salaire (DT)</label>
                                <input type="number" name="salary" class="form-control"
                                       value="{{ old('salary', $employeur->salary) }}">
                            </div>

                            <div class="form-group">
                                <label>Description du Poste</label>
                                <textarea name="job_description" class="form-control" rows="4">{{ old('job_description', $employeur->job_description) }}</textarea>
                            </div>

                            <div class="form-group">
                                <label>Date Limite</label>
                                <input type="date" name="application_deadline" class="form-control"
                                       value="{{ old('application_deadline', $employeur->application_deadline) }}">
                            </div>

                            @if ($employeur->employer_type == 'entreprise')
                                <hr>
                                <h5>Informations sur l'entreprise</h5>

                                <div class="form-group">
                                    <label>Nom</label>
                                    <input type="text" name="company_name" class="form-control"
                                           value="{{ old('company_name', $employeur->company_name) }}">
                                </div>

                                <div class="form-group">
                                    <label>Description</label>
                                    <textarea name="company_description" class="form-control" rows="3">{{ old('company_description', $employeur->company_description) }}</textarea>
                                </div>

                                <div class="form-group">
                                    <label>Site Web</label>
                                    <input type="url" name="company_website" class="form-control"
                                           value="{{ old('company_website', $employeur->company_website) }}">
                                </div>
                            @endif

                            <button type="submit" class="btn btn-primary mt-3">Enregistrer</button>
                            <a href="{{ route('admin.employeurs.index') }}" class="btn btn-secondary mt-3">Annuler</a>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script>
        $(document).ready(function() {
            $('.select2').select2({
                width: '100%'
            });
        });
    </script>
@endpush
