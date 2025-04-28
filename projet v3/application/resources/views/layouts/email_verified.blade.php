<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Email Vérifié</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap 5 CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background: #f7f9fc;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }

        .card {
            border: none;
            border-radius: 1rem;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .card-body {
            text-align: center;
        }

        .checkmark {
            font-size: 4rem;
            color: #28a745;
        }
    </style>
</head>
<body>

    <div class="card p-4" style="width: 100%; max-width: 450px;">
        <div class="card-body">
            <div class="checkmark">✔️</div>
            <h3 class="mt-3">{{ $message }}</h3>
            <p class="text-muted">Votre adresse e-mail a été vérifiée avec succès.</p>
        </div>
    </div>

</body>
</html>
