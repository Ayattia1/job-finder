
<!-- footer area start-->
<footer>
    <div class="footer-area">
        
    </div>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function confirmDeleteAdmin(Id) {
        Swal.fire({
            title: 'Êtes-vous sûr(e) ?',
            text: "Cette action supprimera définitivement cet administrateur.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Oui, supprimer !',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById(`delete-admin-${Id}`).submit();
            }
        });
    }
    function confirmDeleteBan(Id) {
        Swal.fire({
            title: 'Êtes-vous sûr(e) ?',
            text: "Cette action supprimera définitivement cet Utilisateur Bannis.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Oui, supprimer !',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById(`delete-ban-${Id}`).submit();
            }
        });
    }
    function confirmDeleteUser(Id) {
        Swal.fire({
            title: 'Êtes-vous sûr(e) ?',
            text: "Cette action supprimera définitivement cet utilisateur.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Oui, supprimer !',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById(`delete-form-${Id}`).submit();
            }
        });
    }
    function confirmDeleteRole(Id) {
        Swal.fire({
            title: 'Êtes-vous sûr(e) ?',
            text: "Cette action supprimera définitivement cet role.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Oui, supprimer !',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById(`delete-role-${Id}`).submit();
            }
        });
    }
    function confirmDeleteCondidat(Id) {
        Swal.fire({
            title: 'Êtes-vous sûr(e) ?',
            text: "Cette action supprimera définitivement cet candidat.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Oui, supprimer !',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById(`delete-candidat-${Id}`).submit();
            }
        });
    }
    function confirmDeleteEmployeur(Id) {
        Swal.fire({
            title: 'Êtes-vous sûr(e) ?',
            text: "Cette action supprimera définitivement cet employeur.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Oui, supprimer !',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById(`delete-employeur-${Id}`).submit();
            }
        });
    }
    function handleFilterChange(value) {
        if (value === 'Abonnés') {
            window.location.href = "{{ route('admin.subscribers.index') }}";
        } else if (value === 'Interdit') {
            window.location.href = "{{ route('admin.bans.index') }}";
        }
    }

    </script>
</footer>
<!-- footer area end-->
