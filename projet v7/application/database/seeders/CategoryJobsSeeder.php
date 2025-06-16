<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CategoryJobsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('category_jobs')->insert([
            ['name' => 'Technologie'],
            ['name' => 'Soins de santé'],
            ['name' => 'Finance'],
            ['name' => 'Éducation'],
            ['name' => 'Marketing et ventes'],
            ['name' => 'Ingénierie'],
            ['name' => 'Service client'],
            ['name' => 'Emplois indépendants et à distance'],
            ['name' => 'Métiers spécialisés et travail manuel'],
            ['name' => 'Emplois dans la construction et les travaux quotidiens'],
            ['name' => 'Services domestiques et personnels'],
            ['name' => 'Transport & Livraison'],
            ['name' => "Services d'accueil et de restauration"],
            ['name' => 'Agriculture et agriculture'],
        ]);
    }
}
