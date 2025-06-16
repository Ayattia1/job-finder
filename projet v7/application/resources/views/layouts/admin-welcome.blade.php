<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Informations du compte administrateur</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f9;
            margin: 0;
            padding: 0;
        }
        .email-container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
        }
        .header {
            text-align: center;
            color: #333;
        }
        .content {
            margin-top: 20px;
            color: #555;
            font-size: 16px;
            line-height: 1.6;
        }
        .footer {
            margin-top: 40px;
            text-align: center;
            font-size: 12px;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="email-container">
        <div class="header">
            <h2>Bonjour, {{ $name }}</h2>
        </div>
        <div class="content">
            <p>Votre compte administrateur a été créé avec succès.</p>
            <p><strong>Nom d'utilisateur:</strong> {{ $username }}</p>
            <p><strong>Email:</strong> {{ $email }}</p>
            <p><strong>Mot de passe:</strong> {{ $password }}</p>
            <p>Nous vous recommandons de changer votre mot de passe après votre première connexion.</p>
        </div>
        <div class="footer">
            <p>Si vous n’avez pas demandé cette création de compte, veuillez nous contacter immédiatement.</p>
        </div>
    </div>
</body>
</html>
