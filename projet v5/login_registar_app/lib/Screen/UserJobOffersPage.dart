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
import 'addJobPage.dart';
import 'JobRequestsPage.dart';

class UserJobOffersPage extends StatefulWidget {
  const UserJobOffersPage({super.key});

  @override
  State<UserJobOffersPage> createState() => _UserJobOffersPageState();
}

class _UserJobOffersPageState extends State<UserJobOffersPage> {
  List<Map<String, dynamic>> _userJobs = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isRefreshing = false;
  int? _expandedJobIndex;

String _currentFilter = 'all'; 

void _applyFilter(String filter) {
  setState(() {
    _currentFilter = filter;
  });
}

List<Map<String, dynamic>> get _filteredJobs {
  if (_currentFilter == 'all') {
    return _userJobs;
  } else {
    return _userJobs.where((job) => job['status'] == _currentFilter).toList();
  }
}
  Future<void> _fetchUserJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse('${Config.baseUrl}/employeurs');

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
          _isRefreshing = false;
          _expandedJobIndex = null;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _deleteJobOffer(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      _showErrorSnackbar("Session expirée. Veuillez vous reconnecter.");
      return;
    }

    final url = Uri.parse('${Config.baseUrl}/employeurs/$jobId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userJobs.removeWhere((job) => job['id'].toString() == jobId);
          _expandedJobIndex = null;
        });
        _showSuccessSnackbar("Offre d'emploi supprimée avec succès.");
      } else {
        _showErrorSnackbar("Erreur lors de la suppression de l'offre.");
      }
    } catch (e) {
      _showErrorSnackbar("Erreur réseau. Veuillez réessayer.");
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(String jobTitle) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(
                    text: "Êtes-vous sûr de vouloir supprimer l'offre "),
                TextSpan(
                  text: "'$jobTitle'",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: " ? Cette action est irréversible."),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text("ANNULER"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("SUPPRIMER"),
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
      _showErrorSnackbar("URL invalide.");
      return;
    }

    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'action_view',
          data: uri.toString(),
          package: 'com.android.chrome',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } else if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar("Impossible d'ouvrir le site web.");
      }
    } catch (e) {
      _showErrorSnackbar("Impossible d'ouvrir le lien.");
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

String _getStatusLabel(String? status) {
  switch (status) {
    case 'accepted':
      return 'Acceptée';
    case 'rejected':
      return 'Rejetée';
    case 'closed':
      return 'Fermée';
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
    case 'closed':
      return Colors.grey;
    default:
      return Colors.orange;
  }
}

  String _getStatusNote(String? status, String? note) {
    if (status == 'rejected' || status == 'accepted') {
      return note ?? 'Aucune note fournie';
    } else if (status == 'pending') {
      return 'En cours d\'examen par le recruteur';
    }
    return '';
  }
Future<void> _closeJobOffer(String jobId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null) {
    _showErrorSnackbar("Session expirée. Veuillez vous reconnecter.");
    return;
  }

  final url = Uri.parse('${Config.baseUrl}/employeurs/$jobId/close');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await _fetchUserJobs(); 
      _showSuccessSnackbar("Offre d'emploi fermée avec succès.");
    } else {
      _showErrorSnackbar("Erreur lors de la fermeture de l'offre.");
    }
  } catch (e) {
    _showErrorSnackbar("Erreur réseau. Veuillez réessayer.");
  }
}

Future<void> _reopenJobOffer(String jobId, String currentDeadline) async {
  final newDeadline = await _showReopenDialog(currentDeadline);
  if (newDeadline == null) return;

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null) {
    _showErrorSnackbar("Session expirée. Veuillez vous reconnecter.");
    return;
  }

  final url = Uri.parse('${Config.baseUrl}/employeurs/$jobId/reopen');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'application_deadline': newDeadline,
      }),
    );

    if (response.statusCode == 200) {
      await _fetchUserJobs(); 
      _showSuccessSnackbar("Offre d'emploi réouverte avec succès.");
    } else {
      _showErrorSnackbar("modifier la date limite de candidature.");
    }
  } catch (e) {
    _showErrorSnackbar("Erreur réseau. Veuillez réessayer.");
  }
}

Future<String?> _showReopenDialog(String currentDeadline) async {
  final deadlineController = TextEditingController(
    text: currentDeadline.isNotEmpty ? currentDeadline : DateTime.now().add(Duration(days: 30)).toString().split(' ')[0]
  );
  DateTime? selectedDate;

  return await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Réouvrir l'offre"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Veuillez définir une nouvelle date limite de candidature:"),
            const SizedBox(height: 16),
            TextFormField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: 'Date limite',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now().add(Duration(days: 1)),
                  firstDate: DateTime.now().add(Duration(days: 1)),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  selectedDate = picked;
                  deadlineController.text = picked.toString().split(' ')[0];
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("ANNULER"),
          ),
          TextButton(
            onPressed: () {
              if (selectedDate == null && deadlineController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Veuillez sélectionner une date valide")),
                );
                return;
              }
              Navigator.of(context).pop(deadlineController.text);
            },
            child: const Text("CONFIRMER"),
          ),
        ],
      );
    },
  );
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
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isRefreshing = true);
          await _fetchUserJobs();
        },
        child: _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJobPage()),
          ).then((_) => _fetchUserJobs());
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

Widget _buildContent() {
  if (_isLoading) return const Center(child: CircularProgressIndicator());

  if (_hasError) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text("Erreur de chargement",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Impossible de charger vos offres d'emploi",
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _fetchUserJobs();
            },
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  if (_userJobs.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.work_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Aucune offre disponible",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Vous n'avez pas encore publié d'offres d'emploi",
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddJobPage()),
              ).then((_) => _fetchUserJobs());
            },
            child: const Text("Créer une offre"),
          ),
        ],
      ),
    );
  }

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterButton('Tous', 'all'),
              const SizedBox(width: 8),
              _buildFilterButton('En attente', 'pending'),
              const SizedBox(width: 8),
              _buildFilterButton('Acceptées', 'accepted'),
              const SizedBox(width: 8),
              _buildFilterButton('Fermées', 'closed'),
              const SizedBox(width: 8),
              _buildFilterButton('Rejetée', 'rejected'),
            ],
          ),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: _filteredJobs.length,
          itemBuilder: (context, index) {
            final job = _filteredJobs[index];
            final status = job['status'];
            final note = job['note'];
            return InkWell(
              onTap: () {
                if (job['status'] == 'accepted' || job['status'] == 'closed') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobRequestsPage(
                        jobId: job['id'],
                        jobTitle: job['job_title'],
                      ),
                    ),
                  );
                }
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job['job_title'] ?? 'Titre non spécifié',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusLabel(status),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildProfessionalActionMenu(context, job),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.category_outlined, 'Catégorie',
                          job['category_name']),
                      _buildInfoRow(Icons.work_outline, 'Type', job['job_type']),
                      _buildInfoRow(Icons.location_on_outlined, 'Lieu',
                          '${job['job_location'] ?? '-'} (${job['job_location_type'] ?? '-'})'),
                      _buildInfoRow(
                          Icons.attach_money_outlined,
                          'Salaire',
                          job['salary'] != null
                              ? '${job['salary']} DT'
                              : 'Non spécifié'),
                      _buildInfoRow(
                          Icons.email,
                          'Contact Email',
                          job['contact_email'] != null
                              ? '${job['contact_email']}'
                              : 'Non spécifié'),
                      _buildInfoRow(
                          Icons.description,
                          'Description',
                          job['job_description'] != null
                              ? '${job['job_description']}'
                              : 'Non spécifié'),
                      _buildInfoRow(Icons.calendar_today_outlined, 'Date limite',
                          job['application_deadline']),
                      if (note != null && note.isNotEmpty)
                        _buildInfoRow(Icons.note_outlined, 'Note',
                            _getStatusNote(status, note)),
                      if (job['employer_type'] == 'entreprise') ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        const Text(
                          'Informations Entreprise',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if ((job['company_name'] ?? '').toString().isNotEmpty)
                          _buildInfoRow(
                              Icons.business_outlined, 'Nom', job['company_name']),
                        if ((job['company_description'] ?? '')
                            .toString()
                            .isNotEmpty)
                          _buildInfoRow(Icons.description_outlined, 'Description',
                              job['company_description']),
                        if ((job['company_website'] ?? '').toString().isNotEmpty)
                          GestureDetector(
                            onTap: () => _launchURL(job['company_website']),
                            child: _buildInfoRow(Icons.language_outlined,
                                'Site web', job['company_website']),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildProfessionalActionMenu(BuildContext context, Map<String, dynamic> job) {
  return SizedBox(
    width: 32,
    height: 32,
    child: PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) => [
        if (job['status'] != 'closed') ...[
          PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Colors.blue, size: 18),
              ),
              title: const Text('Modifier', style: TextStyle(fontSize: 14)),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem<String>(
            value: 'close',
            child: ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outlined,
                    color: Colors.orange, size: 18),
              ),
              title: const Text('Fermer', style: TextStyle(fontSize: 14)),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ] else ...[
          PopupMenuItem<String>(
            value: 'reopen',
            child: ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_open_outlined,
                    color: Colors.green, size: 18),
              ),
              title: const Text('Réouvrir', style: TextStyle(fontSize: 14)),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outlined,
                  color: Colors.red, size: 18),
            ),
            title: const Text('Supprimer', style: TextStyle(fontSize: 14)),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) async {
if (value == 'edit') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddJobPage(
          job: job
        ),
      ),
    ).then((_) => _fetchUserJobs()); 
  } else if (value == 'close') {
          final confirm = await _showCloseConfirmationDialog(job['job_title'] ?? 'cette offre');
          if (confirm == true) {
            await _closeJobOffer(job['id'].toString());
          }
        } else if (value == 'reopen') {
          final currentDeadline = job['application_deadline'] ?? '';
          await _reopenJobOffer(job['id'].toString(), currentDeadline);
        } else if (value == 'delete') {
          final confirm = await _showDeleteConfirmationDialog(job['job_title'] ?? 'cette offre');
          if (confirm == true) {
            _deleteJobOffer(job['id'].toString());
          }
        }
      },
    ),
  );
}

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showCloseConfirmationDialog(String jobTitle) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirmer la fermeture"),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: "Êtes-vous sûr de vouloir fermer l'offre "),
              TextSpan(
                text: "'$jobTitle'",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: " ? Vous ne recevrez plus de candidatures."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text("ANNULER"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: const Text("FERMER"),
          ),
        ],
      );
    },
  );
}
Widget _buildFilterButton(String label, String filter) {
  final isActive = _currentFilter == filter;
  return OutlinedButton(
    onPressed: () => _applyFilter(filter),
    style: OutlinedButton.styleFrom(
      backgroundColor: isActive ? Colors.blue[50] : Colors.white,
      side: BorderSide(
        color: isActive ? Colors.blue : Colors.grey[300]!,
        width: isActive ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: isActive ? Colors.blue : Colors.grey[700],
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
    ),
  );
}
}
