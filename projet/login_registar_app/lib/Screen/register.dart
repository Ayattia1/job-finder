import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For converting data to JSON
import 'package:login_registar_app/Utils/colors.dart';
import 'package:login_registar_app/Screen/sign_in.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

Future<void> _register() async {
  if (_firstController.text.isEmpty ||
      _lastController.text.isEmpty ||
      _phoneController.text.isEmpty ||
      _emailController.text.isEmpty ||
      _passwordController.text.isEmpty ||
      _addressController.text.isEmpty) {
    _showErrorDialog('Veuillez remplir tous les champs.');
    return;
  }

  if (!RegExp(r'^[0-9]{8,}$').hasMatch(_phoneController.text)) {
    _showErrorDialog("Le numéro de téléphone doit contenir au moins 8 chiffres.");
    return;
  }

  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
    _showErrorDialog("Adresse e-mail invalide.");
    return;
  }

  if (_passwordController.text.length < 8) {
    _showErrorDialog("Le mot de passe doit contenir au moins 8 caractères.");
    return;
  }

  final url = Uri.parse('http://192.168.1.26:8001/api/register');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'first_name': _firstController.text,
        'last_name': _lastController.text,
        'num': _phoneController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'address': _addressController.text,
      }),
    );
  final responseData = json.decode(response.body);

if (response.statusCode == 201) {
  _showErrorDialog(responseData['message']);
  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn()));
} else if (response.statusCode == 422) { 
  String errorMessage = "Validation failed.";

  if (responseData.containsKey('errors')) {
    errorMessage = responseData['errors'].entries
        .map((entry) => "${entry.key}: ${entry.value.join("\n")}")
        .join("\n");
  }

  _showErrorDialog(errorMessage);
} else if (response.statusCode == 409) { 
  _showErrorDialog(responseData['message']);
} else {
  _showErrorDialog(responseData['message'] ?? 'Registration failed.');
}

  } catch (e) {
    _showErrorDialog('Une erreur inattendue s\'est produite. Veuillez réessayer.');
  }
}


void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Message'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              backgroundColor2,
              backgroundColor2,
              backgroundColor4,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              SizedBox(height: size.height * 0.03),
              Text(
                "Créer un compte",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 37,
                  color: textColor1,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Bienvenue chez nous",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 27, color: textColor2, height: 1.2),
              ),
              SizedBox(height: size.height * 0.04),
              myTextField("Nom", Colors.black26, controller: _lastController),
              myTextField("Prénom", Colors.black26, controller: _firstController),
              myTextField("Téléphone", Colors.black26, controller: _phoneController),
              myTextField("Email", Colors.black26, controller: _emailController),
              myTextField("Mot de passe", Colors.black26, isPassword: true, controller: _passwordController),
              myTextField("Adresse", Colors.black26, controller: _addressController),
              SizedBox(height: size.height * 0.04),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _register, 
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "S'inscrire",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 2,
                          width: size.width * 0.2,
                          color: Colors.black12,
                        ),
                        Text(
                          "  ou continuez avec   ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor2,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          height: 2,
                          width: size.width * 0.2,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.06),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        socialIcon("images/google.png"),
                      ],
                    ),
                    SizedBox(height: size.height * 0.07),
                    Text.rich(
                      TextSpan(
                        text: "Vous n'êtes pas membre ? ",
                        style: TextStyle(
                          color: textColor2,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignIn()), 
                                );
                              },
                              child: Text(
                                "Se connecter",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container socialIcon(image) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Image.asset(
        image,
        height: 35,
      ),
    );
  }

  Container myTextField(String hint, Color color, {bool isPassword = false, TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 22,
            ),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.black45,
              fontSize: 19,
            )),
      ),
    );
  }
}
