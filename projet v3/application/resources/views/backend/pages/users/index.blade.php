@extends('backend.layouts.master')

@section('title')
Utilisateurs - Panneau d'Administration
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
                    <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                    <li><span>Tous les Utilisateurs</span></li>
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
                    <h4 class="header-title float-left">Liste des Utilisateurs</h4>
                    <div class="clearfix"></div>
                    <div class="data-tables">
                        @include('backend.layouts.partials.messages')
                        @include('backend.modals.ban-user')
                        <table id="dataTable" class="text-left">
                            <thead class="bg-light text-capitalize">
                                <tr>
                                    <th width="1%">N°</th>
                                    <th width="7%">Nom</th>
                                    <th width="7%">Prénom</th>
                                    <th width="15%">Email</th>
                                    <th width="10%">Numéro</th>
                                    <th width="10%">Ville</th>
                                    <th width="20%">Adresse</th>
                                    <th width="15%">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                               @foreach ($users as $user)
                               <tr>
                                    <td>{{ $loop->index+1 }}</td>
                                    <td>{{ $user->last_name }}</td>
                                    <td>{{ $user->first_name }}</td>
                                    @if($user->email_verified_at!=null)
                                        <td>{{ $user->email }} <span class="badge badge-success">Vérifier</span></td>
                                    @else
                                        <td>{{ $user->email }} <span class="badge badge-secondary">Non vérifier</span></td>
                                    @endif
                                    <td>{{ $user->num }}</td>
                                    <td>{{ $user->city }}</td>
                                    <td>{{ $user->address }}</td>
                                    <td>
                                        @if (auth()->user()->can('profile.edit'))
                                            <a class="btn btn-success text-white" href="{{ route('admin.profiles.edit', $user->id) }}">Modifier</a>
                                        @endif
                                        @if (auth()->user()->can('ban.create'))
                                        <a href="javascript:void(0);" class="btn btn-warning text-white" onclick="openBanModal({{ $user->id }}, '{{ $user->first_name }}')">Interdit</a>
                                        @endif
                                        @if (auth()->user()->can('profile.delete'))
                                        <a class="btn btn-danger text-white" href="#" onclick="confirmDeleteUser({{ $user->id }})">
                                            Supprimer
                                        </a>
                                        @endif
                                        <form id="delete-form-{{ $user->id }}" action="{{ route('admin.profiles.destroy', $user->id) }}" method="POST" style="display: none;">
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
     <!-- Inclure SweetAlert2 -->


     <script>
         /*================================
        Activation de DataTable
        ==================================*/
        if ($('#dataTable').length) {
            $('#dataTable').DataTable({
                responsive: true
            });
        }
        function openBanModal(userId, firstName) {
        document.getElementById('ban-user-id').value = userId;
        document.getElementById('ban-user-name').textContent = firstName;
        $('#banUserModal').modal('show');
    }
     </script>
@endsection
