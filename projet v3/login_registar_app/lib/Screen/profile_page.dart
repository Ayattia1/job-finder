import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';
import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  // Récupération des données de l'utilisateur depuis les préférences
  Future<Map<String, dynamic>> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'first_name': prefs.getString('first_name') ?? 'Utilisateur',
      'last_name': prefs.getString('last_name') ?? '',
      'email': prefs.getString('user_email') ?? 'email@example.com',
      'phone': prefs.getString('user_num') ?? 'N/A',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'joined': prefs.getString('user_joined') ?? 'Date inconnue',
      'bio':
          'Développeur mobile expérimenté spécialisé en Flutter et Dart. Passionné par la création d\'applications belles et performantes.',
      'Adresse': prefs.getString('user_address') ?? 'Localisation inconnue',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 60),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                        'Erreur lors du chargement du profil : ${snapshot.error}'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _userDataFuture = _fetchUserData();
                    }),
                    child: Text('Réessayer'),
                  )
                ],
              ),
            );
          }

          final userData = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(userData['avatarUrl']),
                ),
                SizedBox(height: 20),
                Text(
                  '${userData['first_name']} ${userData['last_name']}'.trim(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 10),
                Text(
                  userData['email'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                SizedBox(height: 30),
                _buildInfoCard(
                  icon: Icons.person,
                  title: 'Informations personnelle',
                  items: {
                    'Téléphone': userData['phone'],
                    'Adresse': userData['Adresse'],
                  },
                  action: TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfilePage()),
                      );
                      if (result == true) {
                        setState(() {
                          _userDataFuture = _fetchUserData();
                        });
                      }
                    },
                    icon:
                        Icon(Icons.edit, color: Theme.of(context).primaryColor),
                    label: Text(
                      "Modifier l'information personnelle",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.info_outline,
                  title: 'À propos',
                  items: {
                    'Inscrit depuis': userData['joined'],
                  },
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biographie',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        userData['bio'],
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Map<String, String> items,
    Widget? action,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(height: 30),
            ...items.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${entry.key} :',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                )),
            if (action != null) ...[
              SizedBox(height: 10),
              Center(child: action),
            ]
          ],
        ),
      ),
    );
  }
}
