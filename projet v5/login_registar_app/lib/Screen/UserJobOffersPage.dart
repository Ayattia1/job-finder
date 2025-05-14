import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/constants.dart';
import 'package:login_registar_app/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:android_intent_plus/android_intent.dart';

class UserJobOffersPage extends StatefulWidget {
  const UserJobOffersPage({super.key});

  @override
  State<UserJobOffersPage> createState() => _UserJobOffersPageState();
}

class _UserJobOffersPageState extends State<UserJobOffersPage> {
  List<Map<String, dynamic>> _userJobs = [];
  bool _isLoading = true;
  bool _hasError = false;

  Future<void> _fetchUserJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return;

    final url = Uri.parse('${Config.baseUrl}/employeurs');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final jobsData = data['data'] as List;

        setState(() {
          _userJobs = List<Map<String, dynamic>>.from(jobsData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteJobOffer(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("No auth token found.");
      return;
    }

    final url = Uri.parse('${Config.baseUrl}/employeurs/$jobId');
    print("Attempting to delete job offer with ID: $jobId");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          _userJobs.removeWhere((job) => job['id'].toString() == jobId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Offre d'emploi supprimée avec succès.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Erreur lors de la suppression de l'offre.")),
        );
      }
    } catch (e) {
      print("Error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réseau.")),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content:
              const Text("Êtes-vous sûr de vouloir supprimer cette offre ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    String fixedUrl = url.trim();
    if (!fixedUrl.startsWith('http://') && !fixedUrl.startsWith('https://')) {
      fixedUrl = 'https://$fixedUrl';
    }

    final uri = Uri.tryParse(fixedUrl);

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("URL invalide.")),
      );
      return;
    }

    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data: uri.toString(),
        package: 'com.android.chrome',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      try {
        await intent.launch();
      } catch (_) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossible d'ouvrir le site web.")),
          );
        }
      }
    } else {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir le site web.")),
        );
      }
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Rejetée';
      default:
        return 'En attente';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusNote(String? status, String? note) {
    if (status == 'rejected' || status == 'accepted') {
      return note ?? 'Aucune note disponible';
    } else if (status == 'pending') {
      return 'Votre demande est en cours d\'étude';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _fetchUserJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos Offres d\'Emploi'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(
                  child: Text("Erreur lors du chargement des offres."))
              : _userJobs.isEmpty
                  ? const Center(child: Text("Aucune offre trouvée."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _userJobs.length,
                      itemBuilder: (context, index) {
                        final job = _userJobs[index];
                        final status = job['status'];
                        final note = job['note'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 20),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        job['job_title'] ?? 'Titre manquant',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(Icons.category, 'Catégorie',
                                    job['category_name']),
                                _buildInfoRow(
                                    Icons.work, 'Type', job['job_type']),
                                _buildInfoRow(Icons.place, 'Lieu',
                                    '${job['job_location'] ?? '-'} (${job['job_location_type'] ?? '-'})'),
                                _buildInfoRow(Icons.monetization_on, 'Salaire',
                                    '${job['salary'] ?? 'Non spécifié'} DT'),
                                _buildInfoRow(Icons.calendar_today,
                                    'Date limite', job['application_deadline']),
                                _buildInfoRow(Icons.info_outline, 'Statut',
                                    _getStatusLabel(status),
                                    iconColor: _getStatusColor(status),
                                    textColor: _getStatusColor(status)),
                                _buildInfoRow(Icons.note_add, 'Note',
                                    _getStatusNote(status, note)),
                                if (job['employer_type'] == 'entreprise') ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const Text(
                                    'Entreprise',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  if ((job['company_name'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Text('Nom : ${job['company_name']}'),
                                  if ((job['company_description'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Text(
                                        'Description : ${job['company_description']}'),
                                  if ((job['company_website'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    GestureDetector(
                                      onTap: () =>
                                          _launchURL(job['company_website']),
                                      child: Text(
                                        'Site web : ${job['company_website']}',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // TODO: Implement edit action
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        minimumSize: const Size(0, 36),
                                      ),
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white, size: 16),
                                      label: const Text(
                                        'Modifier',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        bool? confirmDelete =
                                            await _showDeleteConfirmationDialog();

                                        if (confirmDelete == true) {
                                          _deleteJobOffer(job['id'].toString());
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        minimumSize: const Size(0, 36),
                                      ),
                                      icon: const Icon(Icons.delete,
                                          color: Colors.white, size: 16),
                                      label: const Text(
                                        'Supprimer',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value,
      {Color? iconColor, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label : ${value ?? 'Non spécifié'}',
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
