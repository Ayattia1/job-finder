<?php

declare(strict_types=1);

namespace App\Http\Controllers\Backend;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\candidat;
use App\Models\categoryJob;
use App\Models\Employeur;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class DashboardController extends Controller
{

    public function index()
    {
        $this->checkAuthorization(auth()->user(), ['dashboard.view']);

        $startDate = now()->subDays(29)->startOfDay();
        $endDate = now()->endOfDay();

        $dates = [];
        $verifiedCounts = [];
        $unverifiedCounts = [];
        $candidatCounts = [];
        $offerPendingCounts = [];
        $offerAcceptedCounts = [];
        $offerRejectedCounts = [];
        for ($date = $startDate->copy(); $date <= $endDate; $date->addDay()) {
            $dateString = $date->format('Y-m-d');
            $count = Employeur::whereDate('created_at', $dateString)->count();
            $offerPendingCounts[] = Employeur::whereDate('created_at', $dateString)->where('status', 'pending')->count();
            $offerAcceptedCounts[] = Employeur::whereDate('created_at', $dateString)->where('status', 'accepted')->count();
            $offerRejectedCounts[] = Employeur::whereDate('created_at', $dateString)->where('status', 'rejected')->count();
        }
        for ($date = $startDate->copy(); $date <= $endDate; $date->addDay()) {
            $dateString = $date->format('Y-m-d');
            $dates[] = $dateString;

            $verified = User::whereDate('created_at', $dateString)
                ->whereNotNull('email_verified_at')
                ->count();

            $unverified = User::whereDate('created_at', $dateString)
                ->whereNull('email_verified_at')
                ->count();

            $candidats = Candidat::whereDate('created_at', $dateString)->count();

            $verifiedCounts[] = $verified;
            $unverifiedCounts[] = $unverified;
            $candidatCounts[] = $candidats;
        }

        // Get counts of candidats per category
        $categories = categoryJob::withCount('candidats')->get();
        $categoryLabels = $categories->pluck('name');
        $categoryCounts = $categories->pluck('candidats_count');

        $jobCategories = CategoryJob::withCount('employeurs')->get();
        $offerCategoryLabels = $jobCategories->pluck('name');
        $offerCategoryCounts = $jobCategories->pluck('employeurs_count');

        $acceptedOffers = Employeur::where('status', 'accepted')->get();

        $acceptedOffersWithNoRequests = $acceptedOffers->filter(function ($offer) {
            return $offer->requests()->count() === 0;
        });

        $acceptedOffersWithOnlyPendingOrRejected = $acceptedOffers->filter(function ($offer) {
            $requests = $offer->requests;
            return $requests->count() > 0 && $requests->every(function ($req) {
                return in_array($req->status, ['pending', 'rejected']);
            });
        });

        $acceptedOffersWithAcceptedRequest = $acceptedOffers->filter(function ($offer) {
    return $offer->requests()->where('status', 'accepted')->exists();
});
        $offersNoRequestsCount = $acceptedOffersWithNoRequests->count();
        $offersPendingRejectedCount = $acceptedOffersWithOnlyPendingOrRejected->count();
        $offersAcceptedRequestCount = $acceptedOffersWithAcceptedRequest->count();
        return view('backend.pages.dashboard.index', [
            'total_admins' => Admin::count(),
            'total_roles' => Role::count(),
            'total_candidats' => Candidat::count(),
            'total_permissions' => Permission::count(),
            'total_employeurs' => Employeur::count(),
            'total_users' => User::count(),
            'dates' => $dates,
            'verifiedCounts' => $verifiedCounts,
            'unverifiedCounts' => $unverifiedCounts,
            'candidatCounts' => $candidatCounts,
            'categoryLabels' => $categoryLabels,
            'categoryCounts' => $categoryCounts,
            'offerPendingCounts' => $offerPendingCounts,
            'offerAcceptedCounts' => $offerAcceptedCounts,
            'offerRejectedCounts' => $offerRejectedCounts,
            'offerCategoryLabels' => $offerCategoryLabels,
            'offerCategoryCounts' => $offerCategoryCounts,
            'offersNoRequestsCount' => $offersNoRequestsCount,
            'offersPendingRejectedCount' => $offersPendingRejectedCount,
            'offersAcceptedRequestCount' => $offersAcceptedRequestCount,
        ]);
    }
}
