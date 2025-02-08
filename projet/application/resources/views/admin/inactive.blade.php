@extends('layouts.headerbar')
@section('content')
    @include('layouts.sidebar')


    <div class="wrapper">
        @if (session('success'))
            <script>
                Swal.fire({
                    icon: 'success',
                    title: 'Succès',
                    text: "{{ session('success') }}",
                    timer: 3000,
                    showConfirmButton: false
                });
            </script>
        @endif
        <div class="content-wrapper">
            <!-- Content Header (Page header) -->
            <section class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2">
                        <div class="col-sm-6">
                            <h1>Projects</h1>
                        </div>
                        <div class="col-sm-6">
                            <ol class="breadcrumb float-sm-right">
                                <li class="breadcrumb-item"><a href="#">Home</a></li>
                                <li class="breadcrumb-item active">Projects</li>
                            </ol>
                        </div>
                    </div>
                </div><!-- /.container-fluid -->
            </section>

            <!-- Main content -->
            <section class="content">

                <!-- Default box -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">administrateur inactif</h3>
                        @if ($errors->any())
                            <div class="alert alert-danger">
                                <ul>
                                    @foreach ($errors->all() as $error)
                                        <li>{{ $error }}</li>
                                    @endforeach
                                </ul>
                            </div>
                        @endif
                        <div class="card-tools">
                            <button type="button" class="btn btn-tool" data-card-widget="collapse" title="Collapse">
                                <i class="fas fa-minus"></i>
                            </button>
                            <button type="button" class="btn btn-tool" data-card-widget="remove" title="Remove">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-striped projects">
                            <thead>
                                <tr>
                                    <th style="width: 1%">
                                        #
                                    </th>
                                    <th style="width: 20%">
                                        Nom d'utilisateur
                                    </th>
                                    <th style="width: 30%">
                                        Email
                                    </th>
                                    <th style="width: 8%" class="text-center">
                                        Rang
                                    </th>
                                    <th>

                                    </th>

                                    <th style="width: 20%">

                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($admins as $admin)
                                    <tr>
                                        <td>
                                            {{ $admin->id }}
                                        </td>
                                        <td>
                                            <a>
                                                {{ $admin->username }}
                                            </a>
                                            <br />
                                            <small>
                                                {{ $admin->created_at }}
                                            </small>
                                        </td>
                                        <td>
                                            {{ $admin->email }}
                                        </td>
                                        <td class="project-state">
                                            @if ($admin->rank == 1)
                                                <span class="badge badge-success">Directrice</span>
                                            @elseif ($admin->rank == 2)
                                                <span class="badge badge-success">Administrateur</span>
                                            @elseif ($admin->rank == 3)
                                                <span class="badge badge-success">Modérateur</span>
                                            @endif


                                        </td>
                                        <td class="project_progress">

                                        </td>

                                        <td class="project_progress gap-2 d-flex">
                                            <form id="activer-form-{{ $admin->id }}"
                                                action="{{ route('admin.activer', $admin->id) }}" method="POST"
                                                style="display: inline;">
                                                @csrf
                                                <button type="button" class="btn btn-warning btn-sm"
                                                    onclick="confirmActiver({{ $admin->id }})">
                                                    <i class="fas fa-unlock"></i> Activer
                                                </button>
                                            </form>
                                            <a href="{{ route('admin.edit', $admin->id) }}" class="btn btn-info btn-sm p-1">
                                                <i class="fas fa-pencil-alt"></i> Modifier
                                            </a>
                                            <form id="delete-form-{{ $admin->id }}"
                                                action="{{ route('admin.delete', $admin->id) }}" method="POST"
                                                style="display: inline;">
                                                @csrf
                                                @method('DELETE')
                                                <button type="button" class="btn btn-danger btn-sm p-1"
                                                    onclick="confirmDelete({{ $admin->id }})">
                                                    <i class="fas fa-trash"></i> Supprimer
                                                </button>
                                            </form>
                                        </td>

                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    <!-- /.card-body -->
                </div>
                <!-- /.card -->

            </section>
            <!-- /.content -->
        </div>



    </div>

    @include('layouts.footer')
@endsection
