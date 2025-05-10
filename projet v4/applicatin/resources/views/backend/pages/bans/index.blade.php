@extends('backend.layouts.master')

@section('title')
    {{ __('Bannissements - Panneau d\'Administration') }}
@endsection

@section('styles')
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.18/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.3/css/responsive.bootstrap.min.css">
@endsection

@section('admin-content')

<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">{{ __('Tableau de Bord') }}</a></li>
                    <li><span>{{ __('Liste des Bannissements') }}</span></li>
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
                    <h4 class="header-title">{{ __('Utilisateurs Bannis Actuellement') }}</h4>
                    <div class="data-tables">
                        @include('backend.layouts.partials.messages')
                        <table id="dataTable" class="text-left">
                            <thead class="bg-light text-capitalize">
                                <tr>
                                    <th>#</th>
                                    <th>Nom Utilisateur</th>
                                    <th>Admin</th>
                                    <th>Raison</th>
                                    <th>Fin</th>
                                    <th>Statut</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($bans as $ban)
                                <tr>
                                    <td>{{ $loop->iteration }}</td>
                                    <td>{{ $ban->user->first_name ?? '-' }}</td>
                                    <td>{{ $ban->admin->name ?? 'N/A' }}</td>
                                    <td>{{ $ban->reason }}</td>
                                    <td>{{ $ban->end_date }}</td>
                                    <td>
                                        @if($ban->is_active)
                                            <span class="badge badge-success">Actif</span>
                                        @else
                                            <span class="badge badge-secondary">Expiré</span>
                                        @endif
                                    </td>
                                    <td>
                                        @if (auth()->user()->can('ban.edit'))
                                        <a class="btn btn-sm btn-info" href="{{ route('admin.bans.edit', $ban->id) }}">Modifier</a>
                                        @endif
                                        @if (auth()->user()->can('ban.delete'))
                                        <a class="btn btn-danger text-white" href="#" onclick="confirmDeleteBan({{ $ban->id }})">
                                            Supprimer
                                        </a>
                                        @endif
                                        <form id="delete-ban-{{ $ban->id }}" method="POST" action="{{ route('admin.bans.destroy', $ban->id) }}" style="display: none;">
                                            @csrf
                                            @method('DELETE')
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
    <script src="https://cdn.datatables.net/responsive/2.2.3/js/dataTables.responsive.min.js"></script>

    <script>
        $('#dataTable').DataTable({ responsive: true });
    </script>
@endsection
