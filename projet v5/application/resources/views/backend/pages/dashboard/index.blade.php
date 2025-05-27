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
                            <div class="seo-fact sbg4">
                                <a href="{{ route('admin.subscribers.index') }}">
                                    <div class="p-4 d-flex justify-content-between align-items-center">
                                        <div class="seofct-icon"><i class="fa fa-users"></i> Abonnés</div>
                                        <h2>{{ $total_users }}</h2>
                                    </div>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Chart Section -->
        <div class="row">
            <div class="col-12 mt-4">
                <div class="card">
                    <div class="card-body">
                        <h5>Statistiques des inscriptions des utilisateurs (30 derniers jours)</h5>
                        <canvas id="userChart" height="100"></canvas>
                    </div>
                </div>
            </div>

        </div>
        <div class="row">
            <div class="col-md-6 mt-md-5 mb-3">
                <div class="card">
                    <div class="seo-fact sbg2">
                        <a href="{{ route('admin.candidats.index') }}">
                            <div class="p-4 d-flex justify-content-between align-items-center">
                                <div class="seofct-icon"><i class="fa fa-user"></i> Candidats</div>
                                <h2>{{ $total_candidats }}</h2>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
            <div class="row mt-4">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-body">
                            <h5>Statistiques des candidats ajoutés (30 derniers jours)</h5>
                            <canvas id="candidatChart" height="280"></canvas>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="card">
                        <div class="card-body">
                            <h5>Répartition des candidats par catégorie</h5>
                            <canvas id="categoryPieChart" height="250"></canvas>
                        </div>
                    </div>
                </div>
            </div>

        </div>
        <div class="row">
            <div class="col-md-6 mt-md-5 mb-3">
                <div class="card">
                    <div class="seo-fact sbg3">
                        <a href="{{ route('admin.employeurs.index') }}">
                            <div class="p-4 d-flex justify-content-between align-items-center">
                                <div class="seofct-icon text-white">
                                    <i class="fa fa-briefcase"></i> Offres d'emploi
                                </div>
                                <h2>{{ $total_employeurs }}</h2>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
            <div class="row mt-4">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-body">
                            <h5>Statistiques des offres d'emploi ajoutées (30 derniers jours)</h5>
                            <canvas id="jobOfferChart" height="280"></canvas>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="card">
                        <div class="card-body">
                            <h5>Répartition des offres par catégorie</h5>
                            <canvas id="offerCategoryPieChart" height="250"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="container-fluid mt-4">
                <div class="card">
                    <div class="card-body">
                        <h5>Statut des offres acceptées</h5>
                        <canvas id="offerRequestStatusChart" height="150"></canvas>
                    </div>
                </div>
            </div>

        </div>
    </div>

    @include('backend.layouts.partials.charts')
@endsection
