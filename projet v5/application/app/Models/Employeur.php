<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Employeur extends Model
{
    use HasFactory;

    protected $fillable = [
        'employer_type',
        'user_id',
        'company_name',
        'company_description',
        'company_website',
        'category_job_id',
        'job_title',
        'job_description',
        'job_location_type',
        'job_location',
        'salary',
        'job_type',
        'application_deadline',
        'contact_email',
        'status',
        'note',
    ];

    public function category()
    {
        return $this->belongsTo(CategoryJob::class, 'category_job_id');
    }
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
