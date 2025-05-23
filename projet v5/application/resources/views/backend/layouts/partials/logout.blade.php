<div class="user-profile pull-right">
    <h4 class="user-name dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
        {{ Auth::guard('admin')->user()->name }}
        <i class="fa fa-angle-down"></i>
    </h4>
    <div class="dropdown-menu">
        <!-- Link to Profile Page -->
        <a class="dropdown-item" href="{{ route('admin.profile') }}">Mon Profil</a>

        <!-- Logout -->
        <a class="dropdown-item" href="{{ route('admin.logout.submit') }}"
           onclick="event.preventDefault();
           document.getElementById('admin-logout-form').submit();">
            Se Déconnecter
        </a>
    </div>

    <form id="admin-logout-form" action="{{ route('admin.logout.submit') }}" method="POST" style="display: none;">
        @csrf
    </form>
</div>
