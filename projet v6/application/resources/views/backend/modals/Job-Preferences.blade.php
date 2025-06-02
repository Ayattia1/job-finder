@foreach ($candidats as $index => $candidat)
<div class="modal fade" id="jobPreferencesModal{{ $index }}" tabindex="-1" role="dialog" aria-labelledby="jobPreferencesModalLabel{{ $index }}" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="jobPreferencesModalLabel{{ $index }}">Détails des Préférences d'emploi</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Fermer">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <ul class="list-group">
            <li class="list-group-item"><strong>Titre:</strong> {{ $candidat->job_title ?? 'Non spécifié' }}</li>
            <li class="list-group-item"><strong>Salaire souhaité:</strong> {{ $candidat->salary ? $candidat->salary . ' DT' : 'Non spécifié' }}</li>
            <li class="list-group-item"><strong>Type de travail:</strong> {{ $candidat->type ?? 'Non spécifié' }}</li>
            <li class="list-group-item"><strong>Catégorie:</strong> {{ $candidat->category->name ?? 'Non spécifié' }}</li>
        </ul>
      </div>
    </div>
  </div>
</div>
@endforeach
