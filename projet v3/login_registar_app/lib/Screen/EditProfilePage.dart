import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Declare _selectedCity and list of cities
  String? _selectedCity;
  final List<String> _cities = [
    'Ariana',
    'Beja',
    'Ben Arous',
    'Bizerte',
    'Gabès',
    'Gafsa',
    'Jendouba',
    'Kairouan',
    'Kasserine',
    'Kebili',
    'Kef',
    'Mahdia',
    'Manouba',
    'Médenine',
    'Monastir',
    'Nabeul',
    'Sfax',
    'Sidi Bouzid',
    'Siliana',
    'Sousse',
    'Tataouine',
    'Tozeur',
    'Tunis',
    'Zaghouan'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data and set the city
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _firstNameController.text = prefs.getString('first_name') ?? '';
    _lastNameController.text = prefs.getString('last_name') ?? '';
    _emailController.text = prefs.getString('user_email') ?? '';
    _phoneController.text = prefs.getString('user_num') ?? '';
    _addressController.text = prefs.getString('user_address') ?? '';
    _selectedCity = prefs.getString('user_city');
    setState(() {});
  }

  // Function to save updated data
  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token'); 

      // Prepare the data to send
      final data = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'num': _phoneController.text,
        'address': _addressController.text,
        'city': _selectedCity ?? '',
      };

      // Send PUT request to Laravel API
      final response = await http.put(
        Uri.parse('http://192.168.185.79:8001/api/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the bearer token for auth
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        await prefs.setString('first_name', _firstNameController.text);
        await prefs.setString('last_name', _lastNameController.text);
        await prefs.setString('user_email', _emailController.text);
        await prefs.setString('user_num', _phoneController.text);
        await prefs.setString('user_address', _addressController.text);
        await prefs.setString('user_city', _selectedCity ?? '');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );

        // ✅ Go back and trigger refresh on ProfilePage
        Navigator.pop(context, true);
      } else {
        // Handle errors
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorData['message'] ?? 'Error updating profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modifier le profil")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Prénom", _firstNameController),
              _buildTextField("Nom", _lastNameController),
              _buildTextField("Email", _emailController),
              _buildTextField("Téléphone", _phoneController),
              _buildTextField("Adresse", _addressController),

              // City Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCity,
                        items: _cities.map((city) {
                          return DropdownMenuItem(
                              value: city, child: Text(city));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                        },
                        hint: Text(
                          "Sélectionnez votre ville",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                        isExpanded: true,
                        icon:
                            Icon(Icons.arrow_drop_down, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserData,
                child: Text("Enregistrer"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create form fields
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Veuillez entrer $label' : null,
      ),
    );
  }
}
