import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  // Function to verify the token
  Future<void> _verifyToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      // No token, redirect to login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Send the token to the backend for verification
    final url = Uri.parse('http://192.168.1.26:8001/api/verify-token'); // Modify with your verification route
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _isAuthenticated = true;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
        });
        // Token is invalid, redirect to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
      });
      // Handle error (e.g., show a dialog)
      _showErrorDialog('Une erreur s\'est produite.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _verifyToken(); // Verify the token when the page loads
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: _isAuthenticated
          ? const Center(
              child: Text(
                "Welcome to Home Page!",
                style: TextStyle(fontSize: 20),
              ),
            )
          : const Center(
              child: Text(
                "Invalid Token. Please log in again.",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
    );
  }
}
