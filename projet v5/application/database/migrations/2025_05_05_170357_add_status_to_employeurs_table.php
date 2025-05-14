<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('employeurs', function (Blueprint $table) {
            $table->enum('status', ['pending', 'accepted', 'rejected'])->default('pending')->after('contact_email');
        });
    }

    public function down(): void
    {
        Schema::table('employeurs', function (Blueprint $table) {
            $table->dropColumn('status');
        });
    }
};
