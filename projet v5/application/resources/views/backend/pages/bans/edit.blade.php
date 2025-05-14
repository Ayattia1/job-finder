@extends('backend.layouts.master')

@section('title')
    {{ __('Modifier le Bannissement') }}
@endsection

@section('admin-content')
<div class="main-content-inner">
    <div class="row justify-content-center">
        <div class="col-md-8 mt-5">
            <div class="card">
                <div class="card-header bg-warning text-white">
                    <h4 class="modal-title mb-0">
                        Modifier l'interdit - {{ $ban->user->first_name }}
                    </h4>
                </div>
                <div class="card-body">
                    <form method="POST" action="{{ route('admin.bans.update', $ban->id) }}">
                        @csrf
                        @method('PUT')

                        <input type="hidden" name="user_id" value="{{ $ban->user->id }}">

                        <div class="form-group">
                            <label for="ban-reason">Raison du l'interdit</label>
                            <textarea name="reason" class="form-control" id="ban-reason" rows="3" required>{{ old('reason', $ban->reason) }}</textarea>
                        </div>

                        <div class="form-group">
                            <label for="end-date">Date de fin</label>
                            <input type="datetime-local" name="end_date" class="form-control" id="end-date"
                                value="{{ old('end_date', \Carbon\Carbon::parse($ban->end_date)->format('Y-m-d\TH:i')) }}" required>
                        </div>

                        <div class="form-group mt-4 text-right">
                            <button type="submit" class="btn btn-primary">Mettre à jour</button>
                            <a href="{{ route('admin.bans.index') }}" class="btn btn-secondary">Annuler</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
