<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('employeurs', function (Blueprint $table) {
            $table->id();
            $table->enum('employer_type', ['entreprise', 'recruteur']);
            $table->unsignedBigInteger('user_id');
            $table->string('company_name')->nullable();
            $table->text('company_description')->nullable();
            $table->string('company_website')->nullable();

            $table->unsignedBigInteger('category_job_id')->nullable();
            $table->string('job_title');
            $table->text('job_description');
            $table->enum('job_location_type', ['sur site', 'téletravail', 'hybride']);
            $table->string('job_location');
            $table->decimal('salary', 10, 2)->nullable();
            $table->enum('job_type', ['Temps plein', 'Temps partiel', 'Contrat', 'Travail journalier']);
            $table->date('application_deadline');
            $table->string('contact_email');

            $table->timestamps();
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('category_job_id')->references('id')->on('category_jobs')->onDelete('set null');
        });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('employeurs');
    }
};
