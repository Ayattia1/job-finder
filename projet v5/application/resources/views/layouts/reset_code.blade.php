<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Code de Réinitialisation</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
        body {
            background: #f7f9fc;
            font-family: Arial, sans-serif;
            padding: 40px 0;
            display: flex;
            justify-content: center;
        }

        .card {
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            padding: 30px;
            max-width: 500px;
            text-align: center;
        }

        h2 {
            color: #333;
        }

        .code {
            font-size: 2rem;
            font-weight: bold;
            margin: 20px 0;
            color: #007bff;
        }

        p {
            color: #555;
        }

        .footer {
            margin-top: 30px;
            font-size: 0.875rem;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="card">
        <h2>Réinitialisation de mot de passe</h2>
        <p>Voici votre code de réinitialisation :</p>
        <div class="code">{{ $code }}</div>

        <div class="footer">Si vous n'avez pas demandé cela, ignorez cet e-mail.</div>
    </div>
</body>
</html>
