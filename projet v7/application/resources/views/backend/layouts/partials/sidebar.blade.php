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
                    <li class="{{ Route::is('admin.dashboard') ? 'active' : '' }}">
                       <li class="{{ Route::is('admin.dashboard') ? 'active' : '' }}"> <a href="{{ route('admin.dashboard') }}" aria-expanded="true"><i class="ti-dashboard"></i><span>Tableau de Bord</span></a></li>
                        <ul class="collapse">
                            
                        </ul>
                    </li>
                    @endif

                    @if ( $usr->can('employeur.view') ||  $usr->can('employeur.edit') ||  $usr->can('employeur.delete')  || $usr->can('employeur.status'))
                    <li>
                        <a href="javascript:void(0)" aria-expanded="true"><i class="fa fa-users"></i><span>
                            Offres d'emploi
                        </span></a>
                        <ul class="collapse {{ Route::is('admin.employeurs.index') || Route::is('admin.employeurs.edit')  || Route::is('admin.employeurs.status') || Route::is('admin.employeurs.show') ? 'in' : ''}}">

                            @if ($usr->can('employeur.view'))
                                <li class="{{ Route::is('admin.employeurs.index')  || Route::is('admin.employeurs.edit') ? 'active' : '' }}"><a href="{{ route('admin.employeurs.index') }}">tous les offres </a></li>
                            @endif
                            @if ($usr->can('categorie.view'))
                                <li class="{{ Route::is('admin.categories.index')  || Route::is('admin.categories.edit') ? 'active' : '' }}"><a href="{{ route('admin.categories.index') }}">tous les categories </a></li>
                            @endif
                        </ul>
                    </li>
                    @endif

                    @if ( $usr->can('subscriber.view') ||  $usr->can('subscriber.edit') ||  $usr->can('subscriber.delete')  || $usr->can('candidat.view'))
                    <li>
                        <a href="javascript:void(0)" aria-expanded="true"><i class="fa fa-user"></i><span>
                            Abonnés
                        </span></a>
                        <ul class="collapse {{ Route::is('admin.subscribers.index') || Route::is('admin.subscribers.edit')  || Route::is('admin.bans.index') || Route::is('admin.bans.edit') || Route::is('admin.candidats.index') || Route::is('admin.subscribers.show') ? 'in' : ''}}">

                            @if ($usr->can('subscriber.view'))
                                <li class="{{ Route::is('admin.subscribers.index')  || Route::is('admin.bans.index') || Route::is('admin.bans.edit') || Route::is('admin.subscribers.edit') ? 'active' : '' }}"><a href="{{ route('admin.subscribers.index') }}">Tous Les Abonnés </a></li>
                            @endif
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
                </ul>
            </nav>
        </div>
    </div>
</div>
<!-- Fin du menu de la barre latérale -->
