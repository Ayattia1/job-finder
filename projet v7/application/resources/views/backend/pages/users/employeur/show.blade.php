@extends('backend.layouts.master')

@section('title')
    Détail Offre - Panneau d'Administration
@endsection

@section('admin-content')
    <div class="page-title-area">
        <div class="row align-items-center">
            <div class="col-sm-6">
                <div class="breadcrumbs-area clearfix">
                    <ul class="breadcrumbs pull-left">
                        <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                        <li><a href="{{ route('admin.employeurs.index') }}">Offres</a></li>
                        <li><span>Détail Offre</span></li>
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
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="title mb-0">Détail de l'offre</h4>
                        <div class="btn-group" role="group" aria-label="Actions">

                            @if ($employeur->status === 'pending')
                                <button class="btn btn-success btn-sm" data-toggle="modal"
                                    data-target="#acceptModal{{ $employeur->id }}" title="Accepter l'offre">
                                    <i class="fas fa-check-circle"></i> Accepter
                                </button>

                                <button class="btn btn-danger btn-sm" data-toggle="modal"
                                    data-target="#rejectModal{{ $employeur->id }}" title="Rejeter l'offre">

                                    <i class="fas fa-times-circle"></i> Refuser
                                </button>
                            @elseif($employeur->status === 'rejected')
                                @can('employeur.delete')
                                    <button class="btn btn-success btn-sm" data-toggle="modal"
                                        data-target="#acceptModal{{ $employeur->id }}" title="Accepter l'offre">
                                        <i class="fas fa-check-circle"></i> Accepter
                                    </button>
                                @endcan
                            @else
                                <button class="btn btn-danger btn-sm" data-toggle="modal"
                                    data-target="#rejectModal{{ $employeur->id }}" title="Rejeter l'offre">

                                    <i class="fas fa-times-circle"></i> Refuser
                                </button>
                            @endif

                            <button class="btn btn-outline-secondary btn-sm" onclick="confirmDeleteEmployeur({{ $employeur->id }})"
                                data-toggle="tooltip" data-placement="top" title="Supprimer l'offre rejetée">
                                <i class="fas fa-trash-alt"></i> Supprimer
                            </button>
                            <form id="delete-employeur-{{ $employeur->id }}"
                                action="{{ route('admin.employeurs.destroy', $employeur->id) }}" method="POST"
                                style="display: none;">
                                @method('DELETE')
                                @csrf
                            </form>

                        </div>
                    </div>


                    <div class="card-body">
                        <table class="table table-bordered">
                            <tbody>
                                <tr>
                                    <th>ID</th>
                                    <td>{{ $employeur->id }}</td>
                                </tr>
                                <tr>
                                    <th>Type d'employeur</th>
                                    <td>{{ $employeur->employer_type }}</td>
                                </tr>
                                <tr>
                                    <th>Email Utilisateur</th>
                                    <td>
                                        @if ($employeur->user)
                                            <a
                                                href="{{ route('admin.subscribers.show', $employeur->user->id) }}">{{ $employeur->user->email }}</a>
                                        @else
                                            Non disponible
                                        @endif
                                    </td>
                                </tr>
                                <tr>
                                    <th>Catégorie</th>
                                    <td>{{ $employeur->category->name ?? 'Non disponible' }}</td>
                                </tr>
                                <tr>
                                    <th>Titre</th>
                                    <td>{{ $employeur->job_title }}</td>
                                </tr>
                                <tr>
                                    <th>Type d'emploi</th>
                                    <td>{{ $employeur->job_type }}</td>
                                </tr>
                                <tr>
                                    <th>Mode de travail</th>
                                    <td>{{ $employeur->job_location_type }}</td>
                                </tr>
                                <tr>
                                    <th>Lieu</th>
                                    <td>{{ $employeur->job_location }}</td>
                                </tr>
                                <tr>
                                    <th>Salaire</th>
                                    <td>{{ $employeur->salary }} DT</td>
                                </tr>
                                <tr>
                                    <th>Date limite</th>
                                    <td>{{ $employeur->application_deadline }}</td>
                                </tr>
                                <tr>
                                    <th>Description de l'emploi</th>
                                    <td>{{ $employeur->job_description }}</td>
                                </tr>
                                <tr>
                                    <th>Email de contact</th>
                                    <td>{{ $employeur->contact_email }}</td>
                                </tr>
                                <tr>
                                    <th>Statut</th>
                                    <td>{{ ucfirst($employeur->status) }}</td>
                                </tr>
                                @if (in_array($employeur->status, ['accepted', 'rejected']) && $employeur->note)
                                    <tr>
                                        <th>Note</th>
                                        <td>{{ $employeur->note }}</td>
                                    </tr>
                                @endif

                                <tr>
                                    <th>Date de publication</th>
                                    <td>{{ $employeur->created_at->format('d/m/Y') }}</td>
                                </tr>

                                @if ($employeur->employer_type === 'entreprise')
                                    <tr>
                                        <th>Nom de l'entreprise</th>
                                        <td>{{ $employeur->company_name }}</td>
                                    </tr>
                                    <tr>
                                        <th>Description de l'entreprise</th>
                                        <td>{{ $employeur->company_description }}</td>
                                    </tr>
                                    <tr>
                                        <th>Site web de l'entreprise</th>
                                        <td>
                                            <a href="{{ $employeur->company_website }}" target="_blank">
                                                {{ $employeur->company_website }}
                                            </a>
                                        </td>
                                    </tr>
                                @endif
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- Accept Modal --}}
    <div class="modal fade" id="acceptModal{{ $employeur->id }}" tabindex="-1" role="dialog"
        aria-labelledby="acceptModalLabel{{ $employeur->id }}" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <form method="POST" action="{{ route('admin.employeurs.updateStatus', $employeur->id) }}">
                @csrf
                <input type="hidden" name="status" value="accepted">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="acceptModalLabel{{ $employeur->id }}">Accepter l'Employeur</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Fermer"><span
                                aria-hidden="true">&times;</span></button>
                    </div>
                    <div class="modal-body">
                        <label>Note (optionnel):</label>
                        <textarea name="note" class="form-control" rows="3"></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-success">Confirmer</button>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Annuler</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    {{-- Reject Modal --}}
    <div class="modal fade" id="rejectModal{{ $employeur->id }}" tabindex="-1" role="dialog"
        aria-labelledby="rejectModalLabel{{ $employeur->id }}" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <form method="POST" action="{{ route('admin.employeurs.updateStatus', $employeur->id) }}">
                @csrf
                <input type="hidden" name="status" value="rejected">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="rejectModalLabel{{ $employeur->id }}">Rejeter l'Employeur</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Fermer"><span
                                aria-hidden="true">&times;</span></button>
                    </div>
                    <div class="modal-body">
                        <label>Note (obligatoire):</label>
                        <textarea name="note" class="form-control" rows="3"></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-danger">Confirmer</button>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Annuler</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    {{-- Force Reject Modal --}}
    <div class="modal fade" id="forceRejectModal{{ $employeur->id }}" tabindex="-1" role="dialog"
        aria-labelledby="forceRejectModalLabel{{ $employeur->id }}" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <form method="POST" action="{{ route('admin.employeurs.updateStatus', $employeur->id) }}">
                @csrf
                <input type="hidden" name="status" value="rejected">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="forceRejectModalLabel{{ $employeur->id }}">Rejeter l'Employeur
                            Accepté</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Fermer"><span
                                aria-hidden="true">&times;</span></button>
                    </div>
                    <div class="modal-body">
                        <label>Note (optionnel):</label>
                        <textarea name="note" class="form-control" rows="3"></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-danger">Confirmer le refus</button>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Annuler</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        $(function() {
            $('[data-toggle="tooltip"]').tooltip();
        });
    </script>
@endpush
