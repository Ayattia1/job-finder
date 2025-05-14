<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class candidat extends Model
{
    protected $fillable = ['category_id', 'job_title', 'salary', 'type'];
    public function category()
    {
        return $this->belongsTo(categoryJob::class, 'category_id');
    }
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
