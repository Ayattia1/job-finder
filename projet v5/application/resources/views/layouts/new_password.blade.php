<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Nouveau mot de passe</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
        body {
            background: #f4f6f8;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 40px 0;
            display: flex;
            justify-content: center;
        }

        .card {
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            padding: 30px;
            max-width: 500px;
            text-align: center;
        }

        h2 {
            color: #333333;
        }

        .password {
            font-size: 1.8rem;
            font-weight: bold;
            color: #dc3545;
            margin: 20px 0;
        }

        p {
            color: #555555;
        }

        .footer {
            margin-top: 30px;
            font-size: 0.85rem;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="card">
        <h2>Votre nouveau mot de passe</h2>
        <p>Utilisez le mot de passe suivant pour vous connecter :</p>
        <div class="password">{{ $newPassword }}</div>
        <p>Nous vous recommandons de le changer après la connexion.</p>
        <div class="footer">Si vous n'avez pas demandé de réinitialisation, veuillez ignorer cet e-mail.</div>
    </div>
</body>
</html>
