<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('requests', function (Blueprint $table) {
            $table->foreignId('employer_id')->constrained('users')->after('job_id')->onDelete('cascade');
        });
    }

    public function down(): void {
        Schema::table('requests', function (Blueprint $table) {
            $table->dropForeign(['employer_id']);
            $table->dropColumn('employer_id');
        });
    }
};

