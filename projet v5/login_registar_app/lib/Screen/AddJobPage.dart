import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_registar_app/config.dart';

class AddJobPage extends StatefulWidget {
  final Map<String, dynamic>? job;

  const AddJobPage({super.key, this.job});

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _deadlineController;
  late TextEditingController _companyNameCt;
  late TextEditingController _companyDescCt;
  late TextEditingController _companyWebCt;
  late TextEditingController _jobTitleCt;
  late TextEditingController _jobDescCt;
  late TextEditingController _jobLocationCt;
  late TextEditingController _salaryCt;
  late TextEditingController _contactEmailCt;

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

  List<dynamic> _categories = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _deadlineController = TextEditingController();
    _companyNameCt = TextEditingController();
    _companyDescCt = TextEditingController();
    _companyWebCt = TextEditingController();
    _jobTitleCt = TextEditingController();
    _jobDescCt = TextEditingController();
    _jobLocationCt = TextEditingController();
    _salaryCt = TextEditingController();
    _contactEmailCt = TextEditingController();

    _fetchCategories().then((_) {
      if (widget.job != null) {
        _initializeFormWithJobData();
      }
    });
  }

void _initializeFormWithJobData() {
  final job = widget.job!;
  setState(() {
    employerType = job['employer_type'] ?? 'entreprise';
    companyName = job['company_name']?.toString();
    companyDescription = job['company_description']?.toString();
    companyWebsite = job['company_website']?.toString();
    jobTitle = job['job_title']?.toString();
    jobDescription = job['job_description']?.toString();
    jobLocationType = job['job_location_type']?.toString() ?? 'sur site';
    jobLocation = job['job_location']?.toString();
    salary = job['salary']?.toString();
    jobType = job['job_type']?.toString() ?? 'Temps plein';
    contactEmail = job['contact_email']?.toString();

    // Match category by name or use ID
    if (job.containsKey('category_name')) {
      final matched = _categories.firstWhere(
        (cat) => cat['name'] == job['category_name'],
        orElse: () => {},
      );
      if (matched.isNotEmpty) {
        categoryId = matched['id'].toString();
      }
    } else if (job.containsKey('category_id')) {
      categoryId = job['category_id'].toString();
    }

    _companyNameCt.text = companyName ?? '';
    _companyDescCt.text = companyDescription ?? '';
    _companyWebCt.text = companyWebsite ?? '';
    _jobTitleCt.text = jobTitle ?? '';
    _jobDescCt.text = jobDescription ?? '';
    _jobLocationCt.text = jobLocation ?? '';
    _salaryCt.text = salary ?? '';
    _contactEmailCt.text = contactEmail ?? '';

    if (job['application_deadline'] != null) {
      try {
        applicationDeadline = DateTime.tryParse(job['application_deadline'].toString());
        if (applicationDeadline != null) {
          _deadlineController.text = DateFormat('yyyy-MM-dd').format(applicationDeadline!);
        }
      } catch (_) {
        applicationDeadline = null;
      }
    }
  });
}


  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/categories'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _categories = jsonData['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _deadlineController.clear();
    _companyNameCt.clear();
    _companyDescCt.clear();
    _companyWebCt.clear();
    _jobTitleCt.clear();
    _jobDescCt.clear();
    _jobLocationCt.clear();
    _salaryCt.clear();
    _contactEmailCt.clear();
    
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
    });
  }

  Future<void> _submitJobOffer() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final jobData = {
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
    };

    try {
      final response = widget.job != null
          ? await http.put(
              Uri.parse('${Config.baseUrl}/employeurs/${widget.job!['id']}'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(jobData),
            )
          : await http.post(
              Uri.parse('${Config.baseUrl}/employeurs'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(jobData),
            );

      setState(() => _isSubmitting = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.job != null 
              ? 'Job offer updated successfully!' 
              : 'Job offer added successfully!')),
        );
        Navigator.pop(context);
      } else {
        final errors = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errors['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _deadlineController.dispose();
    _companyNameCt.dispose();
    _companyDescCt.dispose();
    _companyWebCt.dispose();
    _jobTitleCt.dispose();
    _jobDescCt.dispose();
    _jobLocationCt.dispose();
    _salaryCt.dispose();
    _contactEmailCt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCompanyFields = employerType == 'entreprise';

    return Scaffold(
appBar: AppBar(
  title: Text(widget.job != null ? 'Modifier une offre d\'emploi' : 'Ajouter une offre d\'emploi'),
  backgroundColor: const Color.fromARGB(255, 148, 91, 248),
),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                       decoration: const InputDecoration(labelText: 'Type d\'employeur'),
                      value: employerType,
                      items: ['entreprise', 'recruteur'].map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) => setState(() => employerType = val),
                      validator: (val) => val == null ? 'This field is required' : null,
                    ),

                    if (showCompanyFields) ...[
                      TextFormField(
                        controller: _companyNameCt,
                        decoration: const InputDecoration(labelText: 'Nom de l\'entreprise'),
                        onSaved: (val) => companyName = val,
                      ),
                      TextFormField(
                        controller: _companyDescCt,
                        decoration: const InputDecoration(labelText: 'Description de l\'entreprise'),
                        onSaved: (val) => companyDescription = val,
                      ),
                      TextFormField(
                        controller: _companyWebCt,
                        decoration: const InputDecoration(labelText: 'Site web'),
                        onSaved: (val) => companyWebsite = val,
                      ),
                    ],

                    DropdownButtonFormField<String>(
                      value: categoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Category'),
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
                      controller: _jobTitleCt,
                      decoration: const InputDecoration(labelText: 'Titre du poste'),
                      validator: (val) => val!.isEmpty ? 'This field is required' : null,
                      onSaved: (val) => jobTitle = val,
                    ),
                    TextFormField(
                      controller: _jobDescCt,
                      decoration: const InputDecoration(labelText: 'Description du poste'),
                      maxLines: 4,
                      validator: (val) => val!.isEmpty ? 'This field is required' : null,
                      onSaved: (val) => jobDescription = val,
                    ),
                    DropdownButtonFormField<String>(
                      value: jobLocationType,
                      decoration: const InputDecoration(labelText: 'Type de lieu de travail'),
                      items: ['sur site', 'téletravail', 'hybride'].map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) => setState(() => jobLocationType = val),
                      validator: (val) => val == null ? 'This field is required' : null,
                    ),
                    TextFormField(
                      controller: _jobLocationCt,
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (val) => val!.isEmpty ? 'This field is required' : null,
                      onSaved: (val) => jobLocation = val,
                    ),
                    TextFormField(
                      controller: _salaryCt,
                      decoration: const InputDecoration(labelText: 'Salaire'),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => salary = val,
                    ),
                    DropdownButtonFormField<String>(
                      value: jobType,
                      decoration: const InputDecoration(labelText: 'Type d\'emploi'),
                      items: ['Temps plein', 'Temps partiel', 'Contrat', 'Travail journalier']
                          .map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) => setState(() => jobType = val),
                      validator: (val) => val == null ? 'This field is required' : null,
                    ),
                    TextFormField(
                      controller: _deadlineController,
                      decoration: const InputDecoration(labelText: 'Date limite de candidature'),
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: applicationDeadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            applicationDeadline = picked;
                            _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      validator: (val) => val!.isEmpty ? 'This field is required' : null,
                    ),
                    TextFormField(
                      controller: _contactEmailCt,
                      decoration: const InputDecoration(labelText: 'Email de contact'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val!.isEmpty ? 'This field is required' : null,
                      onSaved: (val) => contactEmail = val,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearForm,
                            child: const Text('clair'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: const BorderSide(color: Colors.deepPurple),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitJobOffer,
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(widget.job != null ? 'Mettre à jour' : 'Soumettre',
                                    style: const TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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