<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class AdminWelcomeMail extends Mailable
{
    use Queueable, SerializesModels;

    public string $name;
    public string $username;
    public string $email;
    public string $password;

    public function __construct(string $name, string $username, string $email, string $password)
    {
        $this->name = $name;
        $this->username = $username;
        $this->email = $email;
        $this->password = $password;
    }

    public function build()
    {
        return $this->subject('Création de votre compte administrateur')
                    ->view('layouts.admin-welcome')
                    ->with([
                        'name' => $this->name,
                        'username' => $this->username,
                        'email' => $this->email,
                        'password' => $this->password,
                    ]);
    }
}
