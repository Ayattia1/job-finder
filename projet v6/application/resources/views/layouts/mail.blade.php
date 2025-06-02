<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Vérification de l'adresse e-mail</title>
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
        .btn {
            display: inline-block;
            margin-top: 20px;
            padding: 12px 20px;
            background-color: #28a745;
            color: #fff;
            text-decoration: none;
            border-radius: 8px;
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
            <p>Merci de vous être inscrit !</p>
            <p>Pour finaliser la création de votre compte, veuillez vérifier votre adresse e-mail en cliquant sur le bouton ci-dessous :</p>
            <center><a href="{{ $link }}" class="btn">Vérifier mon e-mail</a></center>
        </div>
        <div class="footer">
            <p>Si vous n’avez pas demandé cette vérification, veuillez ignorer cet e-mail.</p>
        </div>
    </div>

</body>
</html>
