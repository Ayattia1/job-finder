@extends('backend.layouts.master')

@section('title')
Modification de Rôle - Panneau d'Administration
@endsection

@section('styles')
<style>
    .form-check-label {
        text-transform: capitalize;
    }
</style>
@endsection


@section('admin-content')

<!-- Début de la zone du titre de la page -->
<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <h4 class="page-title pull-left">Modification de Rôle - {{ $role->name }}</h4>
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                    <li><a href="{{ route('admin.roles.index') }}">Tous les Rôles</a></li>
                    <li><span>Modifier le Rôle</span></li>
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
                    <form action="{{ route('admin.roles.update', $role->id) }}" method="POST">
                        @method('PUT')
                        @csrf
                        <div class="row mb-2">
                            <div class="col-md-6">
                                <h4 class="header-title">Modification de Rôle - {{ $role->name }}</h4>
                            </div>
                            <div class="col-md-6 text-right">
                                <button type="submit" class="btn btn-primary pr-4 pl-4">Enregistrer</button>
                            </div>
                        </div>

                        @include('backend.layouts.partials.messages')
                        <div class="form-group">
                            <label for="name">Nom du Rôle</label>
                            <input type="text" class="form-control" id="name" value="{{ $role->name }}" name="name" placeholder="Entrez un nom de rôle" required autofocus>
                        </div>

                        <div class="form-group">
                            <label for="name">Permissions</label>

                            <div class="form-check">
                                <input type="checkbox" class="form-check-input" id="checkPermissionAll" value="1" {{ App\User::roleHasPermissions($role, $all_permissions) ? 'checked' : '' }}>
                                <label class="form-check-label" for="checkPermissionAll">Tout sélectionner</label>
                            </div>
                            <hr>
                            @php $i = 1; @endphp
                            @foreach ($permission_groups as $group)
                                <div class="row">
                                    @php
                                        $permissions = App\User::getpermissionsByGroupName($group->name);
                                        $j = 1;
                                    @endphp

                                    <div class="col-3">
                                        <div class="form-check">
                                            <input type="checkbox" class="form-check-input" id="{{ $i }}Management" value="{{ $group->name }}" onclick="checkPermissionByGroup('role-{{ $i }}-management-checkbox', this)" {{ App\User::roleHasPermissions($role, $permissions) ? 'checked' : '' }}>
                                            <label class="form-check-label" for="checkPermission">{{ $group->name }}</label>
                                        </div>
                                    </div>

                                    <div class="col-9 role-{{ $i }}-management-checkbox">
                                        @foreach ($permissions as $permission)
                                            <div class="form-check">
                                                <input type="checkbox" class="form-check-input" onclick="checkSinglePermission('role-{{ $i }}-management-checkbox', '{{ $i }}Management', {{ count($permissions) }})" name="permissions[]" {{ $role->hasPermissionTo($permission->name) ? 'checked' : '' }} id="checkPermission{{ $permission->id }}" value="{{ $permission->name }}">
                                                <label class="form-check-label" for="checkPermission{{ $permission->id }}">{{ $permission->name }}</label>
                                            </div>
                                            @php $j++; @endphp
                                        @endforeach
                                        <br>
                                    </div>
                                </div>
                                @php  $i++; @endphp
                            @endforeach
                        </div>

                        <button type="submit" class="btn btn-primary mt-4 pr-4 pl-4">Enregistrer</button>
                        <a href="{{ route('admin.admins.index') }}" class="btn btn-secondary mt-4 pr-4 pl-4">Annuler</a>
                    </form>
                </div>
            </div>
        </div>
        <!-- Fin de la table de données -->
    </div>
</div>
@endsection


@section('scripts')
     @include('backend.pages.roles.partials.scripts')
@endsection
