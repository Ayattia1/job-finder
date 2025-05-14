<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Detail extends Model
{
    use HasFactory;

    // Allow mass assignment
    protected $fillable = [
        'user_id',
        'profile_picture',
        'cv',
        'bio',
        'professional_experiences',
        'skills',
        'education',
    ];

    // Cast JSON columns to arrays automatically
    protected $casts = [
        'professional_experiences' => 'array',
        'skills' => 'array',
        'education' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
