<?php

namespace App\Notifications;

use Ichtrojan\Otp\Models\Otp as ModelsOtp;
use Ichtrojan\Otp\Otp as OtpOtp;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Ichtrojan\Otp\Otp;
class EmailVerificationNotification extends Notification
{
    use Queueable;
    public $message;
    public $subject;
    public $fromEmail;
    public $mailer;
    private $otp;
    /**
     * Create a new notification instance.
     */
    public function __construct()
    {
        $this->message = 'use the blow code for verification process';
        $this->subject = 'Email Verification';
        $this->fromEmail = 'aymencodingattia@gmail.com';
        $this->mailer = 'mailgun';
        $this->otp = new OtpOtp;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail($notifiable)
    {
        $otp = (new Otp)->generate($notifiable->email, 'numeric', 6, 10); // 6-digit code valid for 10 minutes

        return (new MailMessage)
            ->subject('Verify Your Email')
            ->line('Use this code to verify your email:')
            ->line($otp->token);
    }



    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            //
        ];
    }
}
