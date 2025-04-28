
<!-- footer area start-->
<footer>
    <div class="footer-area">
        <p>© Copyright 2018. All right reserved. Template by <a href="https://colorlib.com/wp/">Colorlib</a>.</p>
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
    </script>
</footer>
<!-- footer area end-->
