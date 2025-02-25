import 'package:flutter/material.dart';
import 'package:login_registar_app/Screen/spash_screen.dart';
import 'package:login_registar_app/Screen/sign_in.dart';
import 'package:login_registar_app/Screen/register.dart';
import 'package:login_registar_app/Screen/home.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', 
      routes: {
        '/splash': (context) => const MySplashScreen(),
        '/register': (context) => const Register(),
        '/login': (context) => const SignIn(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
