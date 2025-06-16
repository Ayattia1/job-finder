import 'package:flutter/material.dart';
import 'package:login_registar_app/Screen/spash_screen.dart';
import 'package:login_registar_app/Screen/sign_in.dart';
import 'package:login_registar_app/Screen/register.dart';
import 'package:login_registar_app/Screen/home.dart';
import 'package:login_registar_app/Screen/AddJobPage.dart';
import 'package:login_registar_app/Screen/message_page.dart';

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
        '/add-job': (context) => AddJobPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/message') {
          final args = settings.arguments as Map<String, dynamic>;
          final jobId = int.tryParse(args['jobId'].toString()) ?? 0;
          final employerId = int.tryParse(args['employerId'].toString()) ?? 0;
          final employerName = args['employerName']?.toString() ?? '';
          final jobTitle = args['jobTitle']?.toString() ?? '';

          return MaterialPageRoute(
            builder: (context) =>
                MessagePage(jobId: jobId, employerId: employerId , employerName: employerName,jobTitle: jobTitle),
          );
        }
        return null;
      },
    );
  }
}
