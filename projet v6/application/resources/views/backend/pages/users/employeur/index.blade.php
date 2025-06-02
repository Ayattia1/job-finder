@extends('backend.layouts.master')

@section('title')
    Employeurs - Panneau d'Administration
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
                    <li><span>Liste des Offres</span></li>
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
                    <h4 class="header-title float-left">Les offres</h4>

                    <!-- Filtrer par statut -->
                    <form method="GET" action="{{ route('admin.employeurs.index') }}" class="form-inline float-right mb-3">
                        <label for="status" class="mr-2">Filtrer par statut:</label>
                        <select name="status" id="status" class="form-control mr-2" onchange="this.form.submit()">
                            <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>En attente</option>
                            <option value="accepted" {{ request('status') == 'accepted' ? 'selected' : '' }}>Accepté</option>
                            <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>Rejeté</option>
                        </select>
                    </form>

                    <div class="clearfix mb-3"></div>

                    @include('backend.layouts.partials.messages')

                    <div class="data-tables">
                        <table id="dataTable" class="text-left">
                            <thead class="bg-light text-capitalize">
                                <tr>
                                    <th>#</th>
                                    <th>Réf</th>
                                    <th>Email Utilisateur</th>
                                    <th>Catégorie</th>
                                    <th>Titre d'emploi</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($employeurs as $employeur)
                                    <tr>
                                        <td>{{ $loop->iteration }}</td>
                                        <td>{{$employeur->id}}</td>
                                        <td>
                                            @if ($employeur->user)
                                                <a href="{{ route('admin.subscribers.show', $employeur->user->id) }}">
                                                    {{ $employeur->user->email }}
                                                </a>
                                            @else
                                                Non disponible
                                            @endif
                                        </td>
                                        <td>{{ $employeur->category->name ?? 'Non disponible' }}</td>
                                        <td>{{ $employeur->job_title }}</td>
                                        <td>
                                            <a href="{{ route('admin.employeurs.show', $employeur->id) }}" class="btn btn-info btn-sm">
                                                <i class="fa fa-eye"></i> Détail
                                            </a>

                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div> <!-- /.data-tables -->
                </div> <!-- /.card-body -->
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

    function confirmDeleteEmployeur(id) {
        if (confirm('Êtes-vous sûr de vouloir supprimer cette offre ?')) {
            document.getElementById('delete-employeur-' + id).submit();
        }
    }
</script>
@endsection
