@extends('backend.layouts.master')

@section('title')
{{ __('Rôles - Panneau d\'Administration') }}
@endsection

@section('styles')
    <!-- Début des styles pour DataTables -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.18/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.3/css/responsive.bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.3/css/responsive.jqueryui.min.css">
@endsection

@section('admin-content')

<!-- Début de la zone du titre de la page -->
<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">{{ __('Tableau de Bord') }}</a></li>
                    <li><span>{{ __('Tous les Rôles') }}</span></li>
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
                    <h4 class="header-title float-left">{{ __('Rôles') }}</h4>
                    <p class="float-right mb-2">
                        @if (Auth::user()->can('role.create'))
                            <a class="btn btn-primary text-white" href="{{ route('admin.roles.create') }}">Créer un Nouveau Rôle</a>
                        @endif
                    </p>
                    <div class="clearfix"></div>
                    <div class="data-tables">
                        @include('backend.layouts.partials.messages')
                        <table id="dataTable" class="text-center">
                            <thead class="bg-light text-capitalize">
                                <tr>
                                    <th width="1%">{{ __('N°') }}</th>
                                    <th width="5%">{{ __('Nom') }}</th>
                                    <th width="60%">{{ __('Permissions') }}</th>
                                    <th width="20%">{{ __('Action') }}</th>
                                </tr>
                            </thead>
                            <tbody>
                               @foreach ($roles as $role)
                               <tr>
                                    <td>{{ $loop->index + 1 }}</td>
                                    <td>{{ $role->name }}</td>
                                    <td>
                                        @foreach ($role->permissions as $permission)
                                            <span class="badge badge-info mr-1">
                                                {{ $permission->name }}
                                            </span>
                                        @endforeach
                                    </td>
                                    <td>
                                        @if (auth::user()->can('role.edit'))
                                            <a class="btn btn-success text-white" href="{{ route('admin.roles.edit', $role->id) }}">Modifier</a>
                                        @endif

                                        @if (auth::user()->can('role.delete'))
                                        <a class="btn btn-danger text-white" href="#" onclick="confirmDeleteRole({{ $role->id }})">
                                            Supprimer
                                        </a>

                                            <form id="delete-role-{{ $role->id }}" action="{{ route('admin.roles.destroy', $role->id) }}" method="POST" style="display: none;">
                                                @method('DELETE')
                                                @csrf
                                            </form>
                                        @endif
                                    </td>
                                </tr>
                               @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <!-- Fin de la table de données -->
    </div>
</div>
@endsection

@section('scripts')
     <!-- Début des scripts pour DataTables -->
     <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
     <script src="https://cdn.datatables.net/1.10.18/js/jquery.dataTables.min.js"></script>
     <script src="https://cdn.datatables.net/1.10.18/js/dataTables.bootstrap4.min.js"></script>
     <script src="https://cdn.datatables.net/responsive/2.2.3/js/dataTables.responsive.min.js"></script>
     <script src="https://cdn.datatables.net/responsive/2.2.3/js/responsive.bootstrap.min.js"></script>

     <script>
        if ($('#dataTable').length) {
            $('#dataTable').DataTable({
                responsive: true
            });
        }
     </script>
@endsection
