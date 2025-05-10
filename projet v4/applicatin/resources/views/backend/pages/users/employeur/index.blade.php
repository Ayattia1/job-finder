@extends('backend.layouts.master')

@section('title')
    Employeurs - Panneau d'Administration
@endsection

@section('styles')
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.18/css/dataTables.bootstrap4.min.css">
@endsection

@section('admin-content')
    <div class="page-title-area">
        <div class="row align-items-center">
            <div class="col-sm-6">
                <div class="breadcrumbs-area clearfix">
                    <ul class="breadcrumbs pull-left">
                        <li><a href="{{ route('admin.dashboard') }}">Tableau de Bord</a></li>
                        <li><span>Liste des Employeurs</span></li>
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
                        <h4 class="header-title float-left">Liste des Employeurs</h4>

                        <!-- Filter Form -->
                        <form method="GET" action="{{ route('admin.employeurs.index') }}"
                            class="form-inline float-right mb-3">
                            <label for="status" class="mr-2">Filtrer par statut:</label>
                            <select name="status" id="status" class="form-control mr-2" onchange="this.form.submit()">
                                <option value="accepted" {{ request('status') == 'accepted' ? 'selected' : '' }}>Accepté
                                </option>
                                <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>En attente
                                </option>
                                <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>Rejeté
                                </option>
                            </select>
                        </form>

                        <div class="clearfix mb-3"></div>
                        @include('backend.layouts.partials.messages')


                        <div class="table-responsive">
                            <table id="dataTable" class="table table-striped table-bordered text-left">
                                <thead class="bg-light text-capitalize">
                                    <tr>
                                        <th>#</th>
                                        <th>Email</th>
                                        <th>Type</th>
                                        <th>Catégorie</th>
                                        <th>Titre</th>
                                        <th>Type de poste</th>
                                        <th>Localisation</th>
                                        <th>Salaire</th>
                                        <th>Description</th>
                                        <th>Email de contact</th>
                                        <th>Deadline</th>
                                        <th>créé à</th>
                                        <th>Note</th>
                                        <th>Entreprise</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach ($employeurs as $employeur)
                                        <tr>
                                            <td>{{ $loop->iteration }}</td>
                                            <td>
                                                @if ($employeur->user)
                                                    <a href="{{ route('admin.profiles.show', $employeur->user->id) }}">
                                                        {{ $employeur->user->email }}
                                                    </a>
                                                @else
                                                    Non disponible
                                                @endif
                                            </td>
                                            <td>{{ ucfirst($employeur->employer_type) }}</td>
                                            <td>{{ $employeur->category->name ?? 'Non disponible' }}</td>
                                            <td>{{ $employeur->job_title }}</td>
                                            <td>{{ $employeur->job_type }}</td>
                                            <td>{{ $employeur->job_location_type }} - {{ $employeur->job_location }}</td>
                                            <td>{{ $employeur->salary ?? 'N/A' }} DT</td>
                                            <td>
                                                <button type="button" class="btn btn-info btn-sm" data-toggle="modal"
                                                    data-target="#descModal{{ $employeur->id }}">
                                                    Détail
                                                </button>

                                                <!-- Job Description Modal -->
                                                <div class="modal fade" id="descModal{{ $employeur->id }}" tabindex="-1"
                                                    role="dialog" aria-labelledby="descModalLabel{{ $employeur->id }}"
                                                    aria-hidden="true">
                                                    <div class="modal-dialog modal-dialog-centered" role="document">
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <h5 class="modal-title"
                                                                    id="descModalLabel{{ $employeur->id }}">Description du
                                                                    Poste</h5>
                                                                <button type="button" class="close" data-dismiss="modal"
                                                                    aria-label="Fermer">
                                                                    <span aria-hidden="true">&times;</span>
                                                                </button>
                                                            </div>
                                                            <div class="modal-body">
                                                                {{ $employeur->job_description ?? 'Non disponible' }}
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-secondary"
                                                                    data-dismiss="modal">Fermer</button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>{{ $employeur->contact_email }}</td>
                                            <td>{{ $employeur->application_deadline }}</td>
                                            <td>{{ $employeur->created_at }}</td>
                                            <td>{{ $employeur->note ?? '-' }}</td>
                                            <td>
                                                @if ($employeur->employer_type == 'entreprise')
                                                    <button type="button" class="btn btn-primary btn-sm"
                                                        data-toggle="modal"
                                                        data-target="#entrepriseModal{{ $employeur->id }}">
                                                        Détail
                                                    </button>

                                                    <!-- Modal -->
                                                    <div class="modal fade" id="entrepriseModal{{ $employeur->id }}"
                                                        tabindex="-1" role="dialog"
                                                        aria-labelledby="entrepriseModalLabel{{ $employeur->id }}"
                                                        aria-hidden="true">
                                                        <div class="modal-dialog modal-dialog-centered" role="document">
                                                            <div class="modal-content">
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title"
                                                                        id="entrepriseModalLabel{{ $employeur->id }}">
                                                                        Informations sur l'entreprise</h5>
                                                                    <button type="button" class="close"
                                                                        data-dismiss="modal" aria-label="Fermer">
                                                                        <span aria-hidden="true">&times;</span>
                                                                    </button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <p><strong>Nom:</strong> {{ $employeur->company_name }}
                                                                    </p>
                                                                    <p><strong>Description:</strong>
                                                                        {{ $employeur->company_description }}</p>
                                                                    <p><strong>Site Web:</strong>
                                                                        <a href="{{ $employeur->company_website }}"
                                                                            target="_blank">{{ $employeur->company_website }}</a>
                                                                    </p>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="button" class="btn btn-secondary"
                                                                        data-dismiss="modal">Fermer</button>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                @else
                                                    -
                                                @endif
                                            </td>
                                            <td>
                                                @if ($employeur->status === 'pending')
                                                    <button class="btn btn-success btn-sm mb-1" data-toggle="modal"
                                                        data-target="#acceptModal{{ $employeur->id }}">Accepter</button>
                                                    <button class="btn btn-danger btn-sm mb-1" data-toggle="modal"
                                                        data-target="#rejectModal{{ $employeur->id }}">Refuser</button>

                                                    <!-- Accept Modal -->
                                                    <div class="modal fade" id="acceptModal{{ $employeur->id }}"
                                                        tabindex="-1" role="dialog"
                                                        aria-labelledby="acceptModalLabel{{ $employeur->id }}"
                                                        aria-hidden="true">
                                                        <div class="modal-dialog modal-dialog-centered" role="document">
                                                            <form method="POST"
                                                                action="{{ route('admin.employeurs.updateStatus', $employeur->id) }}">
                                                                @csrf
                                                                <input type="hidden" name="status" value="accepted">
                                                                <div class="modal-content">
                                                                    <div class="modal-header">
                                                                        <h5 class="modal-title"
                                                                            id="acceptModalLabel{{ $employeur->id }}">
                                                                            Accepter l'Employeur</h5>
                                                                        <button type="button" class="close"
                                                                            data-dismiss="modal" aria-label="Fermer">
                                                                            <span aria-hidden="true">&times;</span>
                                                                        </button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <label>Note (optionnel):</label>
                                                                        <textarea name="note" class="form-control" rows="3"></textarea>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="submit"
                                                                            class="btn btn-success">Confirmer</button>
                                                                        <button type="button" class="btn btn-secondary"
                                                                            data-dismiss="modal">Annuler</button>
                                                                    </div>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>

                                                    <!-- Reject Modal -->
                                                    <div class="modal fade" id="rejectModal{{ $employeur->id }}"
                                                        tabindex="-1" role="dialog"
                                                        aria-labelledby="rejectModalLabel{{ $employeur->id }}"
                                                        aria-hidden="true">
                                                        <div class="modal-dialog modal-dialog-centered" role="document">
                                                            <form method="POST"
                                                                action="{{ route('admin.employeurs.updateStatus', $employeur->id) }}">
                                                                @csrf
                                                                <input type="hidden" name="status" value="rejected">
                                                                <div class="modal-content">
                                                                    <div class="modal-header">
                                                                        <h5 class="modal-title"
                                                                            id="rejectModalLabel{{ $employeur->id }}">
                                                                            Rejeter l'Employeur</h5>
                                                                        <button type="button" class="close"
                                                                            data-dismiss="modal" aria-label="Fermer">
                                                                            <span aria-hidden="true">&times;</span>
                                                                        </button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <label>Note (optionnel):</label>
                                                                        <textarea name="note" class="form-control" rows="3"></textarea>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="submit"
                                                                            class="btn btn-danger">Confirmer</button>
                                                                        <button type="button" class="btn btn-secondary"
                                                                            data-dismiss="modal">Annuler</button>
                                                                    </div>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                @elseif($employeur->status === 'rejected')
                                                @if (auth()->user()->can('employeur.delete'))
                                                <a class="btn btn-danger text-white" href="#" onclick="confirmDeleteEmployeur({{ $employeur->id }})">
                                                    Supprimer
                                                </a>
                                                @endif
                                                <form id="delete-employeur-{{ $employeur->id }}" action="{{ route('admin.employeurs.destroy', $employeur->id) }}" method="POST" style="display: none;">
                                                    @method('DELETE')
                                                    @csrf
                                                </form>
                                                @else
                                                    <a class="btn btn-info btn-sm mb-1" href="#">Voir</a>
                                                    <a class="btn btn-warning btn-sm mb-1"
                                                        href="{{ route('admin.employeurs.edit', $employeur->id) }}">Modifier</a>
                                                    <button class="btn btn-danger btn-sm mb-1" data-toggle="modal"
                                                        data-target="#forceRejectModal{{ $employeur->id }}">Refuser</button>

                                                    <!-- Force Reject Modal -->
                                                    <div class="modal fade" id="forceRejectModal{{ $employeur->id }}"
                                                        tabindex="-1" role="dialog"
                                                        aria-labelledby="forceRejectModalLabel{{ $employeur->id }}"
                                                        aria-hidden="true">
                                                        <div class="modal-dialog modal-dialog-centered" role="document">
                                                            <form method="POST"
                                                                action="{{ route('admin.employeurs.updateStatus', $employeur->id) }}">
                                                                @csrf
                                                                <input type="hidden" name="status" value="rejected">
                                                                <div class="modal-content">
                                                                    <div class="modal-header">
                                                                        <h5 class="modal-title"
                                                                            id="forceRejectModalLabel{{ $employeur->id }}">
                                                                            Rejeter l'Employeur Accepté</h5>
                                                                        <button type="button" class="close"
                                                                            data-dismiss="modal" aria-label="Fermer">
                                                                            <span aria-hidden="true">&times;</span>
                                                                        </button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <label>Note (optionnel):</label>
                                                                        <textarea name="note" class="form-control" rows="3"></textarea>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="submit"
                                                                            class="btn btn-danger">Confirmer le
                                                                            refus</button>
                                                                        <button type="button" class="btn btn-secondary"
                                                                            data-dismiss="modal">Annuler</button>
                                                                    </div>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                @endif
                                            </td>


                                        </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div> <!-- table-responsive -->
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('scripts')
    <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
    <script src="https://cdn.datatables.net/1.10.18/js/dataTables.bootstrap4.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#dataTable').DataTable({
                responsive: true,
                scrollX: true,
                autoWidth: false
            });
        });
    </script>
@endsection
