import 'package:login_registar_app/config.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:login_registar_app/components/items_jobs.dart';
import 'package:login_registar_app/components/recent_items_list.dart';
import 'package:login_registar_app/constants.dart';
import 'package:svg_flutter/svg_flutter.dart';
import '../models/job_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'dart:convert';
import 'AddJobPage.dart';
import 'UserJobOffersPage.dart';
import '../components/custom_drawer.dart';
import 'job_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _userName;
  String? _userEmail;
  int _itemsPerPage = 10;
  int _currentMaxIndex = 10;
  int _forYouItemsPerPage = 5;
  int _forYouCurrentMaxIndex = 5;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Job> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Map<String, dynamic>? userData;
  List<Job> allJobs = [];
  List<Job> forYouJobs = [];

  @override
  void initState() {
    super.initState();
    _verifyToken();
    fetchAllJobs();
    fetchForYouJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final url = Uri.parse(Config.veriftokenUrl);
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _isAuthenticated = true;
          _userName = prefs.getString('first_name') ?? 'Utilisateur';
          _userEmail = prefs.getString('user_email') ?? 'email@example.com';
        });

        try {
          final fetchedUserData = await _fetchUserData();
          setState(() {
            userData = fetchedUserData;
          });
        } catch (e) {
          _showErrorDialog('Impossible de charger les données de l\'utilisateur.');
        }
      } else {
        setState(() {
          _isAuthenticated = false;
        });
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
      });
      _showErrorDialog('Une erreur s\'est produite.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshAllData() async {
    setState(() {
      _isLoading = true;
    });

    await _verifyToken();
    await fetchAllJobs();
    await fetchForYouJobs();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchAllJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/offres'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      setState(() {
        allJobs = data.map((jobJson) => Job.fromJson(jobJson)).toList();
      });
    } else {
      _showErrorDialog('Erreur lors du chargement des offres.');
    }
  }

  Future<void> fetchForYouJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/offres/for-you'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      setState(() {
        forYouJobs = data.map((jobJson) => Job.fromJson(jobJson)).toList();
      });
    } else {
      _showErrorDialog('Erreur lors du chargement des offres "Pour toi".');
    }
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

    final prefsRes = await http.get(
      Uri.parse('${Config.baseUrl}/candidat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    List<dynamic> jobPreferences = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final prefsData = jsonDecode(prefsRes.body)['data'];
      if (prefsData is List) {
        jobPreferences = prefsData;
      } else if (prefsData is Map) {
        jobPreferences = [prefsData];
      }
      return {
        'avatarUrl': data['profile_picture'] != null
            ? '${Config.baseStorageUrl}/${data['profile_picture']}'
            : 'https://randomuser.me/api/portraits/men/1.jpg',
        'joined': prefs.getString('user_joined') ?? 'Date inconnue',
        'bio': data['bio'] ?? 'Pas de biographie',
        'cv': data['cv'] ?? '',
        'professional_experiences': data['professional_experiences'] ?? [],
        'skills': data['skills'] ?? [],
        'education': data['education'] ?? [],
        'job_preferences': jobPreferences,
      };
    } else {
      throw Exception('Erreur de chargement du profil');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _searchJobs(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/offres/search?query=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _searchResults = data.map((jobJson) => Job.fromJson(jobJson)).toList();
        });
      } else {
        _showErrorDialog('Erreur lors de la recherche.');
      }
    } catch (e) {
      _showErrorDialog('Erreur de connexion lors de la recherche.');
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        userName: _userName,
        userEmail: _userEmail,
        userData: userData,
        onLogout: _logout,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAllData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildCustomAppBar(),
              if (_isSearching) _buildSearchResults() else ...[
                _buildWelcomeSection(),
                _buildForYouSection(),
                _buildRecentItems(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Résultats pour "$_searchQuery"',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: secondaryTextColor,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: _clearSearch,
              ),
            ],
          ),
        ),
        if (_searchResults.isEmpty)
          Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Text(
                'Aucun résultat trouvé',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final job = _searchResults[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailsPage(job: job),
                      ),
                    );
                  },
                  child: RecentItemsList(job),
                );
              },
            ),
          ),
      ],
    );
  }

Widget _buildCustomAppBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: SvgPicture.asset(
              "assets/icons/slider.svg",
              height: 30,
              color: primaryColor,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        if (!_isSearching) ...[
          Spacer(),
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/search.svg",
              height: 26,
              color: primaryColor,
            ),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
              FocusScope.of(context).requestFocus(_searchFocusNode);
            },
          ),
          SizedBox(width: 15),
        ] else ...[
          Expanded(
            child: Container(
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor, // Match page background
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3), // Subtle border
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Rechercher des emplois...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, 
                    color: Colors.grey.withOpacity(0.7),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close, 
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    onPressed: _clearSearch,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
                style: TextStyle(
                  color: Colors.grey[800], // Text color
                ),
                onChanged: _searchJobs,
                onSubmitted: _searchJobs,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bonjour, ${_userName ?? 'Utilisateur'} 👋",
            style: TextStyle(
              fontSize: 24,
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "Trouvez votre\nprochain emploi",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouSection() {
    List<Job> visibleForYouJobs = forYouJobs.take(_forYouCurrentMaxIndex).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, bottom: 15, right: 30),
          child: Text(
            "Pour toi",
            style: TextStyle(
              fontSize: 20,
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (forYouJobs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Aucune offre recommandée pour le moment.",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleForYouJobs.length,
                  itemBuilder: (context, index) {
                    final job = visibleForYouJobs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailsPage(job: job),
                          ),
                        );
                      },
                      child: ItemsJobs(job),
                    );
                  },
                ),
                if (_forYouCurrentMaxIndex < forYouJobs.length)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _forYouCurrentMaxIndex =
                              (_forYouCurrentMaxIndex + _forYouItemsPerPage)
                                  .clamp(0, forYouJobs.length);
                        });
                      },
                      child: Text(
                        "Voir plus",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentItems() {
    List<Job> visibleJobs = allJobs.take(_currentMaxIndex).toList();
    final bool hasMore = _currentMaxIndex < allJobs.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Récentes",
                style: TextStyle(
                  fontSize: 20,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: hasMore ? visibleJobs.length + 1 : visibleJobs.length,
            itemBuilder: (context, index) {
              if (index < visibleJobs.length) {
                final job = visibleJobs[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailsPage(job: job),
                      ),
                    );
                  },
                  child: RecentItemsList(job),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _currentMaxIndex = (_currentMaxIndex + _itemsPerPage)
                              .clamp(0, allJobs.length);
                        });
                      },
                      child: Text(
                        "Voir plus",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class JobCarousel extends StatelessWidget {
  final List<Job> jobs;
  JobCarousel(this.jobs, {super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: jobs
          .map((e) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: ItemsJobs(
                  e,
                  themDark: jobs.indexOf(e) == 0,
                ),
              ))
          .toList(),
      options: CarouselOptions(
        enableInfiniteScroll: false,
        reverse: false,
        viewportFraction: 0.86,
        height: 250,
        enlargeCenterPage: true,
        autoPlay: false,
        pageSnapping: true,
        scrollPhysics: const BouncingScrollPhysics(),
      ),
    );
  }
}