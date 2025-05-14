<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Ban;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class UnbanExpiredUsers extends Command
{
    protected $signature = 'users:unban-expired';
    protected $description = 'Unban users whose ban period has expired';

    public function handle()
    {
        $now = \Carbon\Carbon::now();
        DB::table('bans')
            ->where('end_date', '<=', $now)
            ->where('is_active', true)
            ->update(['is_active' => false]);
    }
}
