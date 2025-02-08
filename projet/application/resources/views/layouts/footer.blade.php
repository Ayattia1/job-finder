<footer class="py-4 bg-light mt-auto">
    <div class="container-fluid px-4">
        <div class="d-flex align-items-center justify-content-between small">
            <div class="text-muted">Copyright &copy; Your Website 2023</div>
            <div>
                <a href="#">Privacy Policy</a>
                &middot;
                <a href="#">Terms &amp; Conditions</a>
            </div>
        </div>
    </div>
</footer>
</div>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.2.3/js/bootstrap.bundle.min.js"
    integrity="sha512-i9cEfJwUwViEPFKdC1enz4ZRGBj8YQo6QByFTF92YXHi7waCqyexvRD75S5NVTsSiTv7rKWqG9Y5eFxmRsOn0A=="
    crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="{{ asset('js/script.js') }}"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.8.0/Chart.min.js" crossorigin="anonymous"></script>
<script src="{{ asset('assets/demo/chart-area-demo.js') }}"></script>
<script src="{{ asset('assets/demo/chart-bar-demo.js') }}"></script>
<script src="https://cdn.jsdelivr.net/npm/simple-datatables@7.1.2/dist/umd/simple-datatables.min.js"
    crossorigin="anonymous"></script>
<script src="{{ asset('js/datatables-simple-demo.js') }}"></script>

<script src="{{ asset('plugins/jquery/jquery.min.js') }}"></script>
<!-- Bootstrap 4 -->
<script src="{{ asset('plugins/bootstrap/js/bootstrap.bundle.min.js') }}"></script>
<!-- AdminLTE App -->
<script src="{{ asset('dist/js/adminlte.min.js') }}"></script>
<!-- AdminLTE for demo purposes -->


<script>
    function confirmDeactivation(adminId) {
        Swal.fire({
            title: 'Êtes-vous sûr(e) ?',
            text: "Cette action désactivera cet administrateur.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#e6a100',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Oui, désactiver !',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById(`deactivate-form-${adminId}`).submit();
            }
        });
    }
    function confirmActiver(adminId) {
        Swal.fire({
            title: 'Êtes-vous sûr(e) ?',
            text: "Cette action Activera cet administrateur.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#e6a100',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Oui, activer !',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById(`activer-form-${adminId}`).submit();
            }
        });
    }
    function confirmDelete(adminId) {
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
                // Submit the delete form
                document.getElementById(`delete-form-${adminId}`).submit();
            }
        });
    }
</script>

</body>
</html>
