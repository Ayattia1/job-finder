@extends('backend.layouts.master')

@section('title')
Candidats - Panneau d'Administration
@endsection

@section('styles')
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.18/css/dataTables.bootstrap4.min.css">
@endsection

@section('admin-content')

<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                    <li><span>Liste des Candidats</span></li>
                </ul>
            </div>
        </div>
        <div class="col-sm-6 clearfix">
            @include('backend.layouts.partials.logout')
        </div>
    </div>
</div>

<div class="main-content-inner">
    <div class="row">
        <div class="col-12 mt-5">
            <div class="card">
                <div class="card-body">
                    <h4 class="header-title float-left">Liste des Candidats</h4>
                    <div class="clearfix"></div>
                    <div class="data-tables">
                        @include('backend.layouts.partials.messages')

                        <table id="dataTable" class="text-left">
                            <thead class="bg-light text-capitalize">
                                <tr>
                                    <th>#</th>
                                    <th>Email Utilisateur</th>
                                    <th>Catégorie</th>
                                    <th>Titre d'emploi</th>
                                    <th>Salaire</th>
                                    <th>Type</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($candidats as $candidat)
                                    <tr>
                                        <td>{{ $loop->iteration }}</td>
                                        <td>
                                            @if ($candidat->user)
                                                <a href="{{ route('admin.profiles.show', $candidat->user->id) }}">
                                                    {{ $candidat->user->email }}
                                                </a>
                                            @else
                                                Non disponible
                                            @endif
                                        </td>
                                        <td>{{ $candidat->category->name ?? 'Non disponible' }}</td>
                                        <td>{{ $candidat->job_title }}</td>
                                        <td>{{ $candidat->salary }} DT</td>
                                        <td>{{ $candidat->type }}</td>
                                        <td>
                                            <a class="btn btn-info btn-sm" href="#">Voir</a>
                                            <a class="btn btn-warning btn-sm" href="{{ route('admin.candidats.edit', $candidat->id) }}">Modifier</a>
                                            @if (auth()->user()->can('candidat.delete'))
                                            <a class="btn btn-danger text-white" href="#" onclick="confirmDeleteCondidat({{ $candidat->id }})">
                                                Supprimer
                                            </a>
                                            @endif
                                            <form id="delete-candidat-{{ $candidat->id }}" action="{{ route('admin.candidats.destroy', $candidat->id) }}" method="POST" style="display: none;">
                                                @method('DELETE')
                                                @csrf
                                            </form>

                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>

                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection

@section('scripts')
<script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
<script src="https://cdn.datatables.net/1.10.18/js/dataTables.bootstrap4.min.js"></script>
<script>
    $(document).ready(function () {
        $('#dataTable').DataTable({
            responsive: true
        });
    });
</script>
@endsection
