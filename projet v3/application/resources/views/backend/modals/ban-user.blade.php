
<div class="modal fade" id="banUserModal" tabindex="-1" role="dialog" aria-labelledby="banUserModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <form id="banUserForm" method="POST" action="{{ route('admin.ban.store') }}">
            @csrf
            <input type="hidden" name="user_id" id="ban-user-id">

            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="banUserModalLabel">Bannir un utilisateur - <span id="ban-user-name"></span></h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>

                <div class="modal-body">
                    <div class="form-group">
                        <label for="ban-reason">Raison du bannissement</label>
                        <textarea name="reason" class="form-control" id="ban-reason" rows="3" required></textarea>
                    </div>
                    <div class="form-group">
                        <label for="end-date">Date de fin</label>
                        <input type="datetime-local" name="end_date" class="form-control" id="end-date" required>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit" class="btn btn-danger">Confirmer le bannissement</button>
                </div>
            </div>
        </form>
    </div>
</div>
