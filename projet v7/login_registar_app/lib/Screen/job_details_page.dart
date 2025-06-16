import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job_model.dart';
import 'dart:io';
import 'dart:convert';
import 'package:android_intent_plus/flag.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:http/http.dart' as http;
import 'package:login_registar_app/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobDetailsPage extends StatelessWidget {
  final Job job;

  const JobDetailsPage({super.key, required this.job});
  Future<void> _launchURL(BuildContext context, String url) async {
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

  Future<void> _launchEmail(BuildContext context, String email) async {
    final uri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'envoyer un e-mail.")),
      );
    }
  }

  Future<String?> _checkIfApplied() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/requests/check/${job.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['status'];
    } else {
      return null;
    }
  }
  Future<bool> _cancelApplicationRequest(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/requests/${job.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] ?? "Erreur lors de l'annulation.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur réseau. Veuillez réessayer."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }
  }
Future<void> _showApplyDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Postuler à cette offre',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Voulez-vous postuler à cette offre?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'ANNULER',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('auth_token');

                      try {
                        final response = await http.post(
                          Uri.parse('${Config.baseUrl}/requests'),
                          headers: {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode({
                            'job_id': job.id,
                            'employer_id': job.idEmployer,
                            'message': 'Candidature spontanée', // Default message
                          }),
                        );

                        final responseData = jsonDecode(response.body);
                        Navigator.pop(dialogContext); // Close dialog

                        if (response.statusCode == 201) {
                          final successMessage = responseData['message'] ??
                              'Votre demande a été envoyée avec succès. Nous vous contacterons sous peu.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(successMessage),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          final errorMessage = responseData['message'] ??
                              'Une erreur s\'est produite lors de l\'envoi de votre demande. Veuillez réessayer.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Une erreur réseau est survenue. Veuillez vérifier votre connexion.",
                            ),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'ENVOYER',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job.jobTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Détails de l\'offre'),
            _buildInfoCard([
              _buildRow(Icons.work, "Poste", job.jobTitle),
              _buildRow(Icons.category, "Catégorie", job.categoryName ?? 'N/A'),
              _buildRow(
                Icons.location_on,
                "Lieu",
                "${job.jobLocation}${job.jobLocationType != null ? ' (${job.jobLocationType!})' : ''}",
              ),
              _buildRow(Icons.money, "Salaire", "${job.salary} DT"),
              _buildRow(Icons.schedule, "Type", job.jobType),
              if (job.contactEmail != null)
                _buildRowWithEmail(
                    context, Icons.email, "Contact", job.contactEmail!)
              else
                _buildRow(Icons.email, "Contact", 'Non spécifié'),
              _buildRow(Icons.calendar_today, "Date limite",
                  job.applicationDeadline ?? 'Non spécifiée'),
              if (job.firstNameEmployer != null || job.lastNameEmployer != null)
                _buildRow(
                    Icons.person,
                    "Publié par",
                    "${job.firstNameEmployer ?? ''} ${job.lastNameEmployer ?? ''}"
                        .trim()),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Description'),
            _buildDescriptionCard(job.description ?? 'Aucune description'),
            const SizedBox(height: 20),
            if (job.employerType == 'entreprise') ...[
              _buildSectionTitle('Informations sur l\'entreprise'),
              _buildInfoCard([
                _buildRow(
                    Icons.business, "Nom", job.companyName ?? 'Non spécifié'),
                _buildRow(Icons.info_outline, "Description",
                    job.companyDescription ?? 'Non spécifiée'),
                if (job.companyWebsite != null)
                  _buildRowWithLink(
                      context, Icons.link, "Site Web", job.companyWebsite!),
              ]),
            ],
            const SizedBox(height: 30),
            FutureBuilder<String?>(
              future: _checkIfApplied(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data == 'applied') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/message',
                                  arguments: {
                                    'jobId': job.id,
                                    'employerId': job.idEmployer,
                                    'employerName':"${job.firstNameEmployer ?? ''} ${job.lastNameEmployer ?? ''}".trim(),
                                    'jobTitle':job.jobTitle,
                                  },
                                );
                              },
                              icon:
                                  const Icon(Icons.message_outlined, size: 20),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  'Contacter le recruteur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor: Colors.blue.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                bool confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirmer l'annulation"),
                                    content: const Text(
                                        "Êtes-vous sûr de vouloir retirer votre candidature ?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("Non"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text("Oui"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  final success =
                                      await _cancelApplicationRequest(context);
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Votre candidature a été annulée."),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.close, size: 20),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  'Retirer ma candidature',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                side: BorderSide(color: Colors.grey[400]!),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showApplyDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                    ),
                    child: const Text(
                      'POSTULER À CETTE OFFRE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(top: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(description, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithLink(
      BuildContext context, IconData icon, String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _launchURL(context, url),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16),
                  children: [
                    TextSpan(
                        text: "$label: ",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    TextSpan(
                        text: url,
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithEmail(
      BuildContext context, IconData icon, String label, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _launchEmail(context, email),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16),
                  children: [
                    TextSpan(
                        text: "$label: ",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    TextSpan(
                        text: email,
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
