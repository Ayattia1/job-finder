<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class categoryJob extends Model
{
    protected $fillable = ['name'];
    public function candidats()
{
    return $this->hasMany(Candidat::class, 'category_id');
}
public function employeurs()
{
    return $this->hasMany(Employeur::class, 'category_job_id');
}
}
