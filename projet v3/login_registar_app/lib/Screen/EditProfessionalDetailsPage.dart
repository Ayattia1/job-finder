import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';
import 'package:http_parser/http_parser.dart';

class EditProfessionalDetailsPage extends StatefulWidget {
  @override
  _EditProfessionalDetailsPageState createState() => _EditProfessionalDetailsPageState();
}

class _EditProfessionalDetailsPageState extends State<EditProfessionalDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _skillController = TextEditingController();
  List<String> _skills = [];
  List<Map<String, String>> _education = [];
  List<Map<String, String>> _professionalExperiences = [];
  File? _cvFile;
  File? _profileImage;
  String? _profileImageUrl;
  String? _cvFileUrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentDetails();
  }

Future<void> _loadCurrentDetails() async {
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
    setState(() {
      _bioController.text = data['bio'] ?? '';

      _skills = data['skills'] != null ? List<String>.from(data['skills']) : [];

      _education = [];
      if (data['education'] != null) {
        for (var edu in data['education']) {
          _education.add({
            'diplome': edu['diplome']?.toString() ?? '',
            'etablissement': edu['etablissement']?.toString() ?? '',
            'years': edu['years']?.toString() ?? '',
          });
        }
      }

      _professionalExperiences = [];
      if (data['professional_experiences'] != null) {
        for (var exp in data['professional_experiences']) {
          _professionalExperiences.add({
            'position': exp['position']?.toString() ?? '',
            'entreprise': exp['entreprise']?.toString() ?? '',
            'date_p': exp['date_p']?.toString() ?? '',
            'date_f': exp['date_f']?.toString() ?? '',
          });
        }
      }

      // Images / CV
      _profileImageUrl = data['profile_picture'] != null
          ? "${Config.baseStorageUrl}/${data['profile_picture']}"
          : null;

      _cvFileUrl = data['cv'] != null
          ? "${Config.baseStorageUrl}/${data['cv']}"
          : null;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors du chargement des détails')),
    );
  }
}


  Future<void> _pickCVFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _cvFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

Future<void> _saveChanges() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _loading = true;
  });

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  try {
    if (_profileImage != null || _cvFile != null) {
var request = http.MultipartRequest('POST', Uri.parse('${Config.baseUrl}/details'));
request.headers['Authorization'] = 'Bearer $token';

// Add fields as text
request.fields['bio'] = _bioController.text;
request.fields['skills'] = jsonEncode(_skills);
request.fields['education'] = jsonEncode(_education);
request.fields['professional_experiences'] = jsonEncode(_professionalExperiences);

// Add files if they are picked
if (_cvFile != null) {
  request.files.add(await http.MultipartFile.fromPath('cv', _cvFile!.path));
}
if (_profileImage != null) {
  String mimeType = 'jpeg'; // Default mime type, check based on file extension
  if (_profileImage!.path.endsWith('.png')) mimeType = 'png';

  request.files.add(await http.MultipartFile.fromPath(
    'profile_picture',
    _profileImage!.path,
    contentType: MediaType('image', mimeType),
  ));
}

final streamedResponse = await request.send();
final response = await http.Response.fromStream(streamedResponse);

if (response.statusCode == 200) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Détails professionnels mis à jour avec succès')));
  Navigator.pop(context, true);
} else {
  print(response.body);  // Log the response body for debugging
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la mise à jour')));
}

    } else {
      // No files, send normal JSON request
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/details'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bio': _bioController.text,
          'skills': _skills,
          'education': _education,
          'professional_experiences': _professionalExperiences,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Détails professionnels mis à jour avec succès')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la mise à jour')));
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
  } finally {
    setState(() {
      _loading = false;
    });
  }
}


  void _addEducation() {
    setState(() {
      _education.add({'diplome': '', 'etablissement': '', 'years': ''});
    });
  }

  void _addExperience() {
    setState(() {
      _professionalExperiences.add({'position': '', 'entreprise': '', 'date_p': '', 'date_f': ''});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier les détails professionnels'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🔥 Photo de profil
                    Center(
                      child: Column(
                        children: [
                          _profileImage != null
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage: FileImage(_profileImage!),
                                )
                              : _profileImageUrl != null
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(_profileImageUrl!),
                                    )
                                  : Icon(Icons.account_circle, size: 100, color: Colors.grey),
                          TextButton(
                            onPressed: _pickProfileImage,
                            child: Text('Changer la photo de profil'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    Text('Biographie', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Écrivez votre biographie...',
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'La biographie est requise' : null,
                    ),
                    SizedBox(height: 20),

                    Text('Compétences', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _skills
                          .map((skill) => Chip(
                                label: Text(skill),
                                deleteIcon: Icon(Icons.close),
                                onDeleted: () {
                                  setState(() {
                                    _skills.remove(skill);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skillController,
                            decoration: InputDecoration(
                              hintText: 'Ajouter une compétence',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_skillController.text.trim().isNotEmpty) {
                              setState(() {
                                _skills.add(_skillController.text.trim());
                                _skillController.clear();
                              });
                            }
                          },
                          child: Icon(Icons.add),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    Text('Éducation', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    ..._education.map((edu) => Column(
                          children: [
                            TextFormField(
                              initialValue: edu['diplome'],
                              decoration: InputDecoration(labelText: 'Diplôme'),
                              onChanged: (value) => edu['diplome'] = value,
                            ),
                            TextFormField(
                              initialValue: edu['etablissement'],
                              decoration: InputDecoration(labelText: 'Établissement'),
                              onChanged: (value) => edu['etablissement'] = value,
                            ),
                            TextFormField(
                              initialValue: edu['years'],
                              decoration: InputDecoration(labelText: 'Année'),
                              onChanged: (value) => edu['years'] = value,
                            ),
                            Divider(),
                          ],
                        )),
                    TextButton.icon(
                      onPressed: _addEducation,
                      icon: Icon(Icons.add),
                      label: Text('Ajouter une éducation'),
                    ),
                    SizedBox(height: 20),

                    Text('Expériences professionnelles', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    ..._professionalExperiences.map((exp) => Column(
                          children: [
                            TextFormField(
                              initialValue: exp['position'],
                              decoration: InputDecoration(labelText: 'Poste'),
                              onChanged: (value) => exp['position'] = value,
                            ),
                            TextFormField(
                              initialValue: exp['entreprise'],
                              decoration: InputDecoration(labelText: 'Entreprise'),
                              onChanged: (value) => exp['entreprise'] = value,
                            ),
                            TextFormField(
                              initialValue: exp['date_p'],
                              decoration: InputDecoration(labelText: 'Date début'),
                              onChanged: (value) => exp['date_p'] = value,
                            ),
                            TextFormField(
                              initialValue: exp['date_f'],
                              decoration: InputDecoration(labelText: 'Date fin'),
                              onChanged: (value) => exp['date_f'] = value,
                            ),
                            Divider(),
                          ],
                        )),
                    TextButton.icon(
                      onPressed: _addExperience,
                      icon: Icon(Icons.add),
                      label: Text('Ajouter une expérience professionnelle'),
                    ),
                    SizedBox(height: 20),

                    Text('CV', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    _cvFile != null
                        ? Text('Fichier sélectionné : ${_cvFile!.path.split('/').last}')
                        : _cvFileUrl != null
                            ? Text('CV existant : ${_cvFileUrl!.split('/').last}')
                            : Text('Aucun CV sélectionné'),
                    TextButton(
                      onPressed: _pickCVFile,
                      child: Text('Choisir un fichier CV'),
                    ),
                    SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: Icon(Icons.save),
                        label: Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
