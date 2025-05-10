@extends('backend.layouts.master')

@section('title')
    Détail Utilisateur - Panneau d'Administration
@endsection

@section('admin-content')

<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-6">
            <div class="breadcrumbs-area clearfix">
                <ul class="breadcrumbs pull-left">
                    <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                    <li><a href="{{ route('admin.profiles.index') }}">Utilisateurs</a></li>
                    <li><span>Détail Utilisateur</span></li>
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
                    <h4 class="header-title">Détail de l'utilisateur</h4>

                    @if ($detail || $user)
                        <div class="table-responsive mt-4">
                            <table class="table table-bordered">
                                <tbody>
                                    <tr>
                                        <th>Nom</th>
                                        <td>{{ $user->last_name }}</td>
                                    </tr>
                                    <tr>
                                        <th>Prénom</th>
                                        <td>{{ $user->first_name }}</td>
                                    </tr>
                                    <tr>
                                        <th>Email</th>
                                        <td>{{ $user->email }}</td>
                                    </tr>
                                    <tr>
                                        <th>Ville</th>
                                        <td>{{ $user->city }}</td>
                                    </tr>
                                    <tr>
                                        <th>Adresse</th>
                                        <td>{{ is_string($user->address) ? $user->address : json_encode($user->address) }}</td>
                                    </tr>
                                    <tr>
                                        <th>Numéro</th>
                                        <td>{{ $user->num }}</td>
                                    </tr>
                                    <tr>
                                        <th>Photo de Profil</th>
                                        <td>
                                            @if (!empty($detail->profile_picture))
                                                <img src="{{ asset('storage/' . $detail->profile_picture) }}" alt="Photo de Profil" class="img-thumbnail" style="max-width: 200px;">
                                            @else
                                                Non disponible
                                            @endif
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>CV</th>
                                        <td>
                                            @if (!empty($detail->cv))
                                                <a href="{{ asset('storage/' . $detail->cv) }}" target="_blank" class="btn btn-outline-primary btn-sm">Télécharger CV</a>
                                            @else
                                                Non disponible
                                            @endif
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Biographie</th>
                                        <td>{{ isset($detail) && is_string($detail->bio) ? $detail->bio : 'Non disponible' }}</td>
                                    </tr>
                                    <tr>
                                        <th>Compétences</th>
                                        <td>
                                            @if (!empty($detail->skills) && is_array($detail->skills))
                                                <ul>
                                                    @foreach ($detail->skills as $skill)
                                                        <li>{{ $skill }}</li>
                                                    @endforeach
                                                </ul>
                                            @else
                                                Non disponible
                                            @endif
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Expériences Professionnelles</th>
                                        <td>
                                            @if (!empty($detail->professional_experiences) && is_array($detail->professional_experiences))
                                                <ul>
                                                    @foreach ($detail->professional_experiences as $exp)
                                                        <li>{{ is_array($exp) ? implode(' - ', $exp) : $exp }}</li>
                                                    @endforeach
                                                </ul>
                                            @else
                                                Non disponible
                                            @endif
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Éducation</th>
                                        <td>
                                            @if (!empty($detail->education) && is_array($detail->education))
                                                <ul>
                                                    @foreach ($detail->education as $edu)
                                                        <li>{{ is_array($edu) ? implode(' - ', $edu) : $edu }}</li>
                                                    @endforeach
                                                </ul>
                                            @else
                                                Non disponible
                                            @endif
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    @else
                        <div class="alert alert-warning mt-3">
                            Aucune information complémentaire disponible pour cet utilisateur.
                        </div>
                    @endif

                </div>
            </div>
        </div>
    </div>
</div>

@endsection
