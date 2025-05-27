import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_registar_app/config.dart';
import '../sign_in.dart';

class CodeVerificationPage extends StatefulWidget {
  final String email;

  const CodeVerificationPage({super.key, required this.email});

  @override
  State<CodeVerificationPage> createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showDialog("Veuillez entrer le code.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/password/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'code': code}),
      );

      final json = jsonDecode(response.body);

if (response.statusCode == 200) {
  await _resetPassword(); // Call Laravel reset logic

  _showDialog(
    "Code vérifié avec succès. Un nouveau mot de passe a été envoyé à votre e-mail.",
    onOk: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignIn()),
        (route) => false,
      );
    },
  );
}
 else {
        _showDialog(json['message'] ?? 'Code invalide ou expiré.');
      }
    } catch (_) {
      _showDialog("Erreur de connexion. Veuillez réessayer.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    await http.post(
      Uri.parse('${Config.baseUrl}/password/reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email, 'code': _codeController.text.trim()}),
    );
  }

void _showDialog(String message, {VoidCallback? onOk}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Vérification"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
            if (onOk != null) onOk(); // Execute callback if provided
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vérification du code")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Code envoyé à : ${widget.email}"),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Code de vérification",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Vérifier"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
