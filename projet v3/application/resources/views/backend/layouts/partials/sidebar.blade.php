<!-- Début du menu de la barre latérale -->
@php
    $usr = Auth::guard('admin')->user();
@endphp
<div class="sidebar-menu">
    <div class="sidebar-header">
        <div class="logo">
            <a href="{{ route('admin.dashboard') }}">
                <h2 class="text-white">Admin</h2>
            </a>
        </div>
    </div>
    <div class="main-menu">
        <div class="menu-inner">
            <nav>
                <ul class="metismenu" id="menu">

                    @if ($usr->can('dashboard.view'))
                    <li class="active">
                        <a href="javascript:void(0)" aria-expanded="true"><i class="ti-dashboard"></i><span>Tableau de Bord</span></a>
                        <ul class="collapse">
                            <li class="{{ Route::is('admin.dashboard') ? 'active' : '' }}"><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                        </ul>
                    </li>
                    @endif

                    @if ($usr->can('role.create') || $usr->can('role.view') ||  $usr->can('role.edit') ||  $usr->can('role.delete'))
                    <li>
                        <a href="javascript:void(0)" aria-expanded="true"><i class="fa fa-tasks"></i><span>
                            Rôles & Permissions
                        </span></a>
                        <ul class="collapse {{ Route::is('admin.roles.create') || Route::is('admin.roles.index') || Route::is('admin.roles.edit') || Route::is('admin.roles.show') ? 'in' : '' }}">
                            @if ($usr->can('role.view'))
                                <li class="{{ Route::is('admin.roles.index')  || Route::is('admin.roles.edit') ? 'active' : '' }}"><a href="{{ route('admin.roles.index') }}">Tous les Rôles</a></li>
                            @endif
                            @if ($usr->can('role.create'))
                                <li class="{{ Route::is('admin.roles.create')  ? 'active' : '' }}"><a href="{{ route('admin.roles.create') }}">Créer un Rôle</a></li>
                            @endif
                        </ul>
                    </li>
                    @endif


                    @if ($usr->can('admin.create') || $usr->can('admin.view') ||  $usr->can('admin.edit') ||  $usr->can('admin.delete'))
                    <li>
                        <a href="javascript:void(0)" aria-expanded="true"><i class="fa fa-user"></i><span>
                            Administrateurs
                        </span></a>
                        <ul class="collapse {{ Route::is('admin.admins.create') || Route::is('admin.admins.index') || Route::is('admin.admins.edit') || Route::is('admin.admins.show') ? 'in' : '' }}">

                            @if ($usr->can('admin.view'))
                                <li class="{{ Route::is('admin.admins.index')  || Route::is('admin.admins.edit') ? 'active' : '' }}"><a href="{{ route('admin.admins.index') }}">Tous les Admins</a></li>
                            @endif

                            @if ($usr->can('admin.create'))
                                <li class="{{ Route::is('admin.admins.create')  ? 'active' : '' }}"><a href="{{ route('admin.admins.create') }}">Créer un Admin</a></li>
                            @endif
                        </ul>
                    </li>
                    @endif

                    @if ( $usr->can('profile.view') ||  $usr->can('profile.edit') ||  $usr->can('profile.delete') || $usr->can('profile.ban'))
                    <li>
                        <a href="javascript:void(0)" aria-expanded="true"><i class="fa fa-user"></i><span>
                            Profils
                        </span></a>
                        <ul class="collapse {{ Route::is('admin.profiles.index') || Route::is('admin.profiles.edit')  || Route::is('admin.bans.index') || Route::is('admin.bans.edit') || Route::is('admin.profiles.show') ? 'in' : ''}}">

                            @if ($usr->can('profile.view'))
                                <li class="{{ Route::is('admin.profiles.index')  || Route::is('admin.profiles.edit') ? 'active' : '' }}"><a href="{{ route('admin.profiles.index') }}">Tous les Utilisateurs </a></li>
                            @endif
                            @if ($usr->can('ban.view'))
                                <li class="{{ Route::is('admin.bans.index') || Route::is('admin.bans.edit') ? 'active' : '' }}"><a href="{{ route('admin.bans.index') }}">utilisateurs bannis </a></li>
                            @endif
                        </ul>
                    </li>
                    @endif

                </ul>
            </nav>
        </div>
    </div>
</div>
<!-- Fin du menu de la barre latérale -->
