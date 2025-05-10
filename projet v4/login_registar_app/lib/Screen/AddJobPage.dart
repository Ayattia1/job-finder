import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_registar_app/config.dart'; 

class AddJobPage extends StatefulWidget {
  const AddJobPage({super.key});

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deadlineController = TextEditingController();

  String? employerType;
  String? companyName;
  String? companyDescription;
  String? companyWebsite;
  String? categoryId;
  String? jobTitle;
  String? jobDescription;
  String? jobLocationType;
  String? jobLocation;
  String? salary;
  String? jobType;
  String? contactEmail;
  DateTime? applicationDeadline;
  String? note;

  List<dynamic> _categories = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/categories'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _categories = jsonData['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des catégories')),
      );
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _deadlineController.clear();
    setState(() {
      employerType = null;
      companyName = null;
      companyDescription = null;
      companyWebsite = null;
      categoryId = null;
      jobTitle = null;
      jobDescription = null;
      jobLocationType = null;
      jobLocation = null;
      salary = null;
      jobType = null;
      contactEmail = null;
      applicationDeadline = null;
      note = null;
    });
  }

  Future<void> _submitJobOffer() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur non authentifié.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/employeurs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'employer_type': employerType,
        'company_name': companyName,
        'company_description': companyDescription,
        'company_website': companyWebsite,
        'category_job_id': categoryId,
        'job_title': jobTitle,
        'job_description': jobDescription,
        'job_location_type': jobLocationType,
        'job_location': jobLocation,
        'salary': salary != null ? double.tryParse(salary!) : null,
        'job_type': jobType,
        'application_deadline': applicationDeadline?.toIso8601String(),
        'contact_email': contactEmail,
      }),
    );

    setState(() => _isSubmitting = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Offre d\'emploi ajoutée avec succès!')),
      );
      Navigator.pop(context);
    } else {
      final errors = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${errors['message'] ?? 'Inconnue'}')),
      );
    }
  }

  @override
  void dispose() {
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCompanyFields = employerType == 'entreprise';

    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter une offre d'emploi"),
        backgroundColor: const Color.fromARGB(255, 148, 91, 248),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Type d\'employeur'),
                items: ['entreprise', 'recruteur'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => employerType = val),
                validator: (val) => val == null ? 'Ce champ est requis' : null,
              ),

              if (showCompanyFields) ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nom de la société'),
                  onSaved: (val) => companyName = val,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description de la société'),
                  onSaved: (val) => companyDescription = val,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Site web'),
                  onSaved: (val) => companyWebsite = val,
                ),
              ],

              DropdownButtonFormField<String>(
                value: categoryId,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: _categories
                    .map<DropdownMenuItem<String>>(
                      (cat) => DropdownMenuItem(
                        value: cat['id'].toString(),
                        child: Text(cat['name'], overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => categoryId = value),
                validator: (value) => value == null ? 'Veuillez sélectionner une catégorie' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Titre du poste'),
                validator: (val) => val!.isEmpty ? 'Champ requis' : null,
                onSaved: (val) => jobTitle = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description du poste'),
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'Champ requis' : null,
                onSaved: (val) => jobDescription = val,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Type de localisation'),
                items: ['sur site', 'téletravail', 'hybride'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => jobLocationType = val,
                validator: (val) => val == null ? 'Ce champ est requis' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Localisation'),
                validator: (val) => val!.isEmpty ? 'Champ requis' : null,
                onSaved: (val) => jobLocation = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Salaire'),
                keyboardType: TextInputType.number,
                onSaved: (val) => salary = val,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Type d\'emploi'),
                items: ['Temps plein', 'Temps partiel', 'Contrat', 'Travail journalier'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => jobType = val,
                validator: (val) => val == null ? 'Ce champ est requis' : null,
              ),
              TextFormField(
                controller: _deadlineController,
                decoration: InputDecoration(labelText: 'Date limite de candidature'),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      applicationDeadline = picked;
                      _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
                    });
                  }
                },
                validator: (val) => val!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email de contact'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty ? 'Champ requis' : null,
                onSaved: (val) => contactEmail = val,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      child: Text('Effacer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: BorderSide(color: Colors.deepPurple),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitJobOffer,
                      child: _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Publier l\'offre', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
