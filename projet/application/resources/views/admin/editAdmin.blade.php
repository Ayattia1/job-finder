@extends('layouts.headerbar')
@section('content')
    @include('layouts.sidebar')

    <div class="wrapper">
        <div class="content-wrapper">
            <section class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2">
                        <div class="col-sm-6">
                            <h1>Modifier l'administrateur</h1>
                        </div>
                        <div class="col-sm-6">
                            <ol class="breadcrumb float-sm-right">
                                <li class="breadcrumb-item"><a href="#">Home</a></li>
                                <li class="breadcrumb-item active">Modifier l'administrateur</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </section>

            <section class="content">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Modifier les informations de l'administrateur</h3>
                    </div>
                    <div class="card-body">
                        <form action="{{ route('admin.update', $admin->id) }}" method="POST">
                            @csrf
                            @method('PUT')
                            <div class="form-group">
                                <label for="username">Nom d'utilisateur</label>
                                <input type="text" class="form-control" id="username" name="username" value="{{ $admin->username }}" required>
                            </div>

                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" class="form-control" id="email" name="email" value="{{ $admin->email }}" required>
                            </div>

                            <div class="form-group">
                                <label for="rank">Rang</label>
                                <select name="rank" id="rank" class="form-control" required>
                                    <option value="1" {{ $admin->rank == 1 ? 'selected' : '' }}>Directrice</option>
                                    <option value="2" {{ $admin->rank == 2 ? 'selected' : '' }}>Administrateur</option>
                                    <option value="3" {{ $admin->rank == 3 ? 'selected' : '' }}>Modérateur</option>
                                </select>
                            </div>

                            <button type="submit" class="btn btn-primary">Mettre à jour</button>
                            <a href="{{ route('admin.active') }}" class="btn btn-secondary">Retour</a>
                        </form>
                    </div>
                </div>
            </section>
        </div>
    </div>

    @include('layouts.footer')
@endsection
