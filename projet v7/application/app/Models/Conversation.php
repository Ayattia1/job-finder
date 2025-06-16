<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Message;
class Conversation extends Model
{
    protected $fillable = ['user_id', 'employer_id'];

    public function messages()
    {
        return $this->hasMany(Message::class);
    }
    public function latestMessage()
{
    return $this->hasOne(Message::class)->latestOfMany();
}
public function user() {
    return $this->belongsTo(User::class, 'user_id');
}

public function employer() {
    return $this->belongsTo(User::class, 'employer_id');
}

}
