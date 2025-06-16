@extends('backend.layouts.master')

@section('title')
    Gestion des Catégories - Panneau d'Administration
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
                        <li><span>Catégories</span></li>
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
            <div class="col-12 mt-5">
                <div class="card">
                    <div class="card-body">
                        <h4 class="header-title float-left">Gestion des Catégories</h4>
                        <a href="{{ route('admin.categories.create') }}" class="btn btn-success float-right mb-3">
                            <i class="fas fa-plus"></i> Ajouter une Catégorie
                        </a>

                        <div class="clearfix"></div>
                        @include('backend.layouts.partials.messages')

                        <div class="data-tables">
                            <table id="dataTable" class="text-left table table-bordered">
                                <thead class="bg-light text-capitalize">
                                    <tr>
                                        <th width="5%">ID</th>
                                        <th width="25%">Nom</th>
                                        <th width="20%">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($categories as $category)
                                        <tr>
                                            <td>{{ $category->id }}</td>
                                            <td>{{ $category->name }}</td>
                                            <td>
                                                <a href="{{ route('admin.categories.edit', $category->id) }}" class="btn btn-primary btn-sm">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                                <form action="{{ route('admin.categories.destroy', $category->id) }}" method="POST" style="display: inline-block;">
                                                    @csrf
                                                    @method('DELETE')
                                                    <button type="submit" class="btn btn-danger btn-sm">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
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
    <!-- Début des scripts pour DataTables -->
    <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
    <script src="https://cdn.datatables.net/1.10.18/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.18/js/dataTables.bootstrap4.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.2.3/js/dataTables.responsive.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.2.3/js/responsive.bootstrap.min.js"></script>

    <script>
        $(document).ready(function () {
            $('#dataTable').DataTable({
                responsive: true
            });
        });
    </script>
@endsection
