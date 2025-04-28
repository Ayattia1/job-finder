import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; 
import 'EditProfilePage.dart';
import 'EditProfessionalDetailsPage.dart';

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

  void _showCVOptions(String cvFileName) {
    final cvUrl = 'http://192.168.185.79:8001/storage/$cvFileName';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('CV Options'),
        content: Text('Que voulez-vous faire ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerPage(cvUrl: cvUrl),
                ),
              );
            },
            child: Text('Voir dans l\'app'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(cvUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                throw 'Impossible d\'ouvrir le CV';
              }
            },
            child: Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/details'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      return {
        'first_name': prefs.getString('first_name') ?? 'Utilisateur',
        'last_name': prefs.getString('last_name') ?? '',
        'email': prefs.getString('user_email') ?? 'email@example.com',
        'phone': prefs.getString('user_num') ?? 'N/A',
        'Adresse': prefs.getString('user_address') ?? 'N/A',
        'avatarUrl': data['profile_picture'] != null
            ? 'http://192.168.185.79:8001/storage/${data['profile_picture']}'
            : 'https://randomuser.me/api/portraits/men/1.jpg',
        'joined': prefs.getString('user_joined') ?? 'Date inconnue',
        'bio': data['bio'] ?? 'Pas de biographie',
        'cv': data['cv'] ?? '',
        'professional_experiences': data['professional_experiences'] ?? [],
        'skills': data['skills'] ?? [],
        'education': data['education'] ?? [],
      };
    } else {
      throw Exception('Erreur de chargement du profil');
    }
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
                  SizedBox(height: 16),
                  Text('Erreur : ${snapshot.error}'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _userDataFuture = _fetchUserData();
                      });
                    },
                    child: Text('Réessayer'),
                  ),
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
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 30),

                // Personal Info Card
                _buildInfoCard(
                  icon: Icons.person,
                  title: 'Informations personnelles',
                  items: {
                    'Téléphone': userData['phone'],
                    'Adresse': userData['Adresse'],
                    'Inscrit depuis': userData['joined'],
                  },
                  action: TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          _userDataFuture = _fetchUserData();
                        });
                      }
                    },
                    icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                    label: Text('Modifier informations personnelles', style: TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                ),

                SizedBox(height: 20),

                // Détails professionnels (ONE box)
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 10),
                            Text('Détails professionnels',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        Divider(height: 30),

                        // Biographie
                        Text('Biographie',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                        SizedBox(height: 10),
                        Text(
                          userData['bio'],
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 20),

                        // CV
                        Text('CV :', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        userData['cv'] != ''
                            ? TextButton(
                                onPressed: () {
                                  _showCVOptions(userData['cv']);
                                },
                                child: Text('Voir CV'),
                              )
                            : Text('Pas de CV disponible'),

                        SizedBox(height: 20),

                        // Compétences
                        Text('Compétences :', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        userData['skills'].isNotEmpty
                            ? Wrap(
                                spacing: 8,
                                children: (userData['skills'] as List)
                                    .map<Widget>((skill) => Chip(label: Text(skill)))
                                    .toList(),
                              )
                            : Text('Aucune compétence renseignée'),

                        SizedBox(height: 20),

                        // Éducation
                        Text('Éducation :', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        userData['education'].isNotEmpty
                            ? Column(
                                children: (userData['education'] as List)
                                    .map<Widget>((edu) => ListTile(
                                          leading: Icon(Icons.school),
                                          title: Text(edu['diplome'] ?? 'Diplôme inconnu'),
                                          subtitle: Text(
                                              '${edu['etablissement'] ?? 'Établissement inconnu'} - ${edu['years'] ?? 'Année inconnue'}'),
                                        ))
                                    .toList(),
                              )
                            : Text('Aucune formation renseignée'),

                        SizedBox(height: 20),

                        // Expériences professionnelles
                        Text('Expériences professionnelles :',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        userData['professional_experiences'].isNotEmpty
                            ? Column(
                                children: (userData['professional_experiences'] as List)
                                    .map<Widget>((exp) => ListTile(
                                          leading: Icon(Icons.work),
                                          title: Text(exp['position'] ?? 'Poste inconnu'),
                                          subtitle: Text(
                                            '${exp['entreprise'] ?? 'Entreprise inconnue'}\n'
                                            'De: ${exp['date_p'] ?? 'Inconnue'} à ${exp['date_f'] ?? 'Inconnue'}',
                                          ),
                                        ))
                                    .toList(),
                              )
                            : Text('Aucune expérience professionnelle renseignée'),

                        SizedBox(height: 10),

                        // 🛠 Edit Button under expériences
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfessionalDetailsPage(),
                                ),
                              );
                              if (result == true) {
                                setState(() {
                                  _userDataFuture = _fetchUserData();
                                });
                              }
                            },
                            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                            label: Text(
                              'Modifier détails professionnels',
                              style: TextStyle(color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                Icon(icon),
                SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(height: 30),
            ...items.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text('${entry.key} :', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[600])),
                      SizedBox(width: 10),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                )),
            if (action != null) ...[
              SizedBox(height: 10),
              Center(child: action),
            ],
          ],
        ),
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String cvUrl;
  const PDFViewerPage({Key? key, required this.cvUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mon CV')),
      body: SfPdfViewer.network(cvUrl),
    );
  }
}
