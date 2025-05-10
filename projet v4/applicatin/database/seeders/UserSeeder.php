<?php

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $user = User::where('email', 'manirujjamanakash@gmail.com')->first();
        if (is_null($user)) {
            $user = new User();
            $user->first_name = "test1";
            $user->last_name = "test1";
            $user->num = "12345678";
            $user->email = "test@gmail.com";
            $user->city = "sousse";
            $user->address = "msaken sousse";
            $user->password = Hash::make('12345678');
            $user->save();
        }
    }
}
