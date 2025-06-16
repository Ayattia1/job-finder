import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';

class AddJobPreferencesPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? preferenceData;

  AddJobPreferencesPage({this.isEdit = false, this.preferenceData});

  @override
  _AddJobPreferencesPageState createState() => _AddJobPreferencesPageState();
}

class _AddJobPreferencesPageState extends State<AddJobPreferencesPage> {
  final _formKey = GlobalKey<FormState>();

  String? _jobTitle;
  String? _type;
  String? _salary;
  String? _category;

  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.isEdit && widget.preferenceData != null) {
      final data = widget.preferenceData!;
      _jobTitle = data['job_title'];
      _type = data['type'];
      _salary = data['salary'];
      _category = data['category_id'].toString();
    }
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/categories'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _categories = jsonData['data'];
        _isLoading = false;
        // Ensure the category is valid, set to the first one if not found.
        if (_category != null && !_categories.any((cat) => cat['id'].toString() == _category)) {
          _category = _categories.isNotEmpty ? _categories[0]['id'].toString() : null;
        }
        if (_type != null && !['Temps plein', 'Temps partiel', 'Contrat', 'Travail journalier'].contains(_type)) {
          _type = 'Temps plein';
        }
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des catégories')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non authentifié.')),
        );
        return;
      }

      final isEditing = widget.isEdit && widget.preferenceData != null;
      final url = isEditing
          ? Uri.parse('${Config.baseUrl}/candidat/${widget.preferenceData!['id']}')
          : Uri.parse('${Config.baseUrl}/candidat');

      final response = await (isEditing
          ? http.put(url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'categoryJob': _category,
                'job_title': _jobTitle,
                'salary': _salary,
                'type': _type,
              }),
            )
          : http.post(url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'categoryJob': _category,
                'job_title': _jobTitle,
                'salary': _salary,
                'type': _type,
              }),
            ));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Succès')),
        );
        Navigator.pop(context, true);
      } else {
        try {
          final errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? 'Erreur inconnue')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'envoi des données')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? "Modifier Préférence d'Emploi" : "Ajouter Préférence d'Emploi")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _category,
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
                      onChanged: (value) => setState(() => _category = value),
                      validator: (value) => value == null
                          ? 'Veuillez sélectionner une catégorie'
                          : null,
                    ),
                    TextFormField(
                      initialValue: _jobTitle,
                      decoration: InputDecoration(labelText: 'Titre du poste'),
                      onSaved: (value) => _jobTitle = value,
                      validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _type,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: 'Type de travail'),
                      items: [
                        'Temps plein',
                        'Temps partiel',
                        'Contrat',
                        'Travail journalier'
                      ]
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _type = value),
                      validator: (value) => value == null
                          ? 'Veuillez sélectionner un type de travail'
                          : null,
                    ),
                    TextFormField(
                      initialValue: _salary,
                      decoration: InputDecoration(labelText: 'Salaire souhaité'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _salary = value,
                      validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
                    ),
                    
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(widget.isEdit ? 'Mettre à jour' : 'Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
