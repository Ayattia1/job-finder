import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:login_registar_app/components/items_jobs.dart';
import 'package:login_registar_app/components/recent_items_list.dart';
import 'package:login_registar_app/constants.dart';
import 'package:svg_flutter/svg_flutter.dart';
import '../models/job_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';
import 'profile_page.dart';
import 'dart:convert';
import 'AddJobPage.dart';
import 'UserJobOffersPage.dart';

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
  Map<String, dynamic>? userData;

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
          _showErrorDialog(
              'Impossible de charger les données de l\'utilisateur.');
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
            ? 'http://192.168.1.24:8001/storage/${data['profile_picture']}'
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

  @override
  void initState() {
    super.initState();
    _verifyToken();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildModernDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _verifyToken,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildCustomAppBar(),
              _buildWelcomeSection(),
              _buildForYouSection(),
              JobCarousel(forYou),
              _buildRecentItems(),
            ],
          ),
        ),
      ),
    );
  }

  bool _showJobOfferOptions = false;

  Widget _buildModernDrawer() {
    return Drawer(
      child: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: userData != null
                        ? NetworkImage(userData!['avatarUrl'])
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName ?? 'Utilisateur',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail ?? 'email@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerButton(
                      Icons.home_outlined, 'Accueil', primaryColor, () {}),
                  _buildDrawerButton(
                      Icons.person_outline, 'Profil', primaryColor, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProfilePage()));
                  }),
                  _buildDrawerButton(
                    _showJobOfferOptions
                        ? Icons.expand_less
                        : Icons.expand_more,
                    'Offre d\'emploi',
                    primaryColor,
                    () {
                      setState(() {
                        _showJobOfferOptions = !_showJobOfferOptions;
                      });
                    },
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Column(
                        children: [
                          _buildDrawerButton(
                            Icons.list_alt_outlined,
                            'Votre offre d\'emploi',
                            primaryColor,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const UserJobOffersPage()),
                              );
                            },
                          ),
                          _buildDrawerButton(
                            Icons.add_circle_outline,
                            'Ajouter une offre d\'emploi',
                            primaryColor,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddJobPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _showJobOfferOptions
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerButton(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 5, horizontal: 0), // avoid extra width
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
          Spacer(),
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/search.svg",
              height: 26,
              color: primaryColor,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 15),
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/filter.svg",
              height: 26,
              color: primaryColor,
            ),
            onPressed: () {},
          ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 15),
      child: Text(
        "Pour toi",
        style: TextStyle(
          fontSize: 20,
          color: secondaryTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecentItems() {
    return Column(
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
              TextButton(
                onPressed: () {},
                child: Text(
                  "Voir tout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recent.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: RecentItemsList(recent[index]),
              );
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
        // Remove autoCurve and use valid properties:
        autoPlay: false,
        pageSnapping: true,
        scrollPhysics: const BouncingScrollPhysics(),
      ),
    );
  }
}
