import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class UserProfileViewPage extends StatefulWidget {
  final int userId;
  final String userName;

  const UserProfileViewPage({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  _UserProfileViewPageState createState() => _UserProfileViewPageState();
}

class _UserProfileViewPageState extends State<UserProfileViewPage> {
  late Future<Map<String, dynamic>> _userDataFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/user/${widget.userId}/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });
      final data = jsonDecode(response.body)['data'];
      return {
        'first_name': data['first_name'] ?? 'Utilisateur',
        'last_name': data['last_name'] ?? '',
        'avatarUrl': data['profile_picture'] != null
            ? '${Config.baseStorageUrl}/${data['profile_picture']}'
            : 'https://randomuser.me/api/portraits/men/1.jpg',
        'bio': data['bio'] ?? 'Pas de biographie',
        'cv': data['cv'] ?? '',
        'professional_experiences': data['professional_experiences'] ?? [],
        'skills': data['skills'] ?? [],
        'education': data['education'] ?? [],
        'job_preferences': data['job_preferences'] ?? [],
      };
    } else {
      throw Exception('Erreur de chargement du profil');
    }
  }

  void _showCVOptions(String cvFileName) {
    final cvUrl = '${Config.baseStorageUrl}/$cvFileName';

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

  Widget _buildJobPreferenceCard(Map<String, dynamic> pref) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pref['category_name'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Catégorie: ${pref['category_name']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (pref['job_title'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('Poste: ${pref['job_title']}'),
              ),
            if (pref['type'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('Type: ${pref['type']}'),
              ),
            if (pref['salary'] != null)
              Text('Salaire: ${pref['salary']} DT'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil de ${widget.userName}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, dynamic>>(
              future: _userDataFuture,
              builder: (context, snapshot) {
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

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data!;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                          ),
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                userData['avatarUrl'],
                                width: 104,
                                height: 104,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                  return Icon(Icons.person, size: 60, color: Colors.grey);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        '${userData['first_name']} ${userData['last_name']}'.trim(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 30),

                      // Professional Details Card
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
                              Text('Biographie',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                              SizedBox(height: 10),
                              Text(
                                userData['bio'],
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.justify,
                              ),
                              SizedBox(height: 20),
                              Text('CV :',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                              Text('Compétences :',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              userData['skills'].isNotEmpty
                                  ? Wrap(
                                      spacing: 8,
                                      children: (userData['skills'] as List)
                                          .map<Widget>(
                                              (skill) => Chip(label: Text(skill)))
                                          .toList(),
                                    )
                                  : Text('Aucune compétence renseignée'),
                              SizedBox(height: 20),
                              Text('Éducation :',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              userData['education'].isNotEmpty
                                  ? Column(
                                      children: (userData['education'] as List)
                                          .map<Widget>((edu) => ListTile(
                                                leading: Icon(Icons.school),
                                                title: Text(edu['diplome'] ??
                                                    'Diplôme inconnu'),
                                                subtitle: Text(
                                                    '${edu['etablissement'] ?? 'Établissement inconnu'} - ${edu['years'] ?? 'Année inconnue'}'),
                                              ))
                                          .toList(),
                                    )
                                  : Text('Aucune formation renseignée'),
                              SizedBox(height: 20),
                              Text('Expériences professionnelles :',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              userData['professional_experiences'].isNotEmpty
                                  ? Column(
                                      children: (userData['professional_experiences']
                                              as List)
                                          .map<Widget>((exp) => ListTile(
                                                leading: Icon(Icons.work),
                                                title: Text(exp['position'] ??
                                                    'Poste inconnu'),
                                                subtitle: Text(
                                                  '${exp['entreprise'] ?? 'Entreprise inconnue'}\n'
                                                  'De: ${exp['date_p'] ?? 'Inconnue'} à ${exp['date_f'] ?? 'Inconnue'}',
                                                ),
                                              ))
                                          .toList(),
                                    )
                                  : Text(
                                      'Aucune expérience professionnelle renseignée'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Job Preferences Card
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.work_outline),
                                  SizedBox(width: 10),
                                  Text('Préférences d\'emploi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                              Divider(height: 30),
                              (userData['job_preferences'] ?? []).isNotEmpty
                                  ? Column(
                                      children: (userData['job_preferences'] as List)
                                          .map<Widget>((pref) => _buildJobPreferenceCard(pref))
                                          .toList(),
                                    )
                                  : Text('Aucune préférence renseignée'),
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
}

class PDFViewerPage extends StatelessWidget {
  final String cvUrl;
  const PDFViewerPage({Key? key, required this.cvUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CV')),
      body: SfPdfViewer.network(cvUrl),
    );
  }
}