<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Request extends Model
{
    protected $fillable = ['user_id', 'job_id', 'status', 'employer_id'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }


    public function job()
    {
        return $this->belongsTo(Employeur::class, 'job_id')->with('user', 'category');
    }
   /* public function conversation()
    {
        return $this->hasOne(Conversation::class, 'user_id', 'user_id')
            ->where('employer_id', $this->employer_id);
    }*/
public function conversationBase()
{
    return $this->hasOne(Conversation::class, 'user_id', 'user_id');
}

}
