import 'package:flutter/material.dart';
import 'package:login_registar_app/Utils/colors.dart';
import 'package:login_registar_app/Screen/register.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_registar_app/Screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<SignIn>{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

Future<void> _login() async {
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    _showErrorDialog('Veuillez remplir tous les champs.');
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

  final url = Uri.parse(Config.loginUrl);

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': _emailController.text, 'password': _passwordController.text}),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      final String token = responseData['token'];
      final responseBody = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('first_name', responseBody['user']['first_name']);
      await prefs.setString('last_name', responseBody['user']['last_name']);
      await prefs.setString('user_email', responseBody['user']['email']);
      await prefs.setString('user_num', responseBody['user']['num']);
      await prefs.setString('user_city', responseBody['user']['city']);
      await prefs.setString('user_address', responseBody['user']['address']);
      await prefs.setString('user_joined', responseBody['user']['created_at']);
      await prefs.setString('auth_token', token);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showErrorDialog(responseData['message']);
    }
  } catch (e) {
    print('Error: $e');
    _showErrorDialog('Une erreur inattendue s\'est produite. Veuillez réessayer.');
  }
}



Future<void> _checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token != null) {
    if (!mounted) return; 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}


  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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
                "Bonjour à nouveau!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 37,
                  color: textColor1,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Content de vous revoir, vous nous avez manqué!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, color: textColor2, height: 1.2),
              ),
              SizedBox(height: size.height * 0.04),
              myTextField("Email", Colors.white,controller : _emailController),
              myTextField("Mot de passe", Colors.black26 , controller: _passwordController),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Mot de passe oublié ?       ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor2,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _login ,
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "Se connecter",
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
                          "  Ou continuer avec  ",
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        socialIcon("images/google.png"),
                        socialIcon("images/apple.png"),
                        socialIcon("images/facebook.png"),
                      ],
                    ),
                    SizedBox(height: size.height * 0.07),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Register()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Pas encore membre ? ",
                          style: TextStyle(
                            color: textColor2,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          children: const [
                            TextSpan(
                              text: "S'inscrire maintenant",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container socialIcon(String image) {
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

  Container myTextField(String hint, Color color ,{bool isPassword = false, TextEditingController? controller}) {
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
          ),
          suffixIcon: Icon(
            Icons.visibility_off_outlined,
            color: color,
          ),
        ),
      ),
    );
  }
}
