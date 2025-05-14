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
import '../components/custom_drawer.dart';

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

  List<Job> allJobs = [];
  List<Job> forYouJobs = [];

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
            ? 'http://192.168.1.19:8001/storage/${data['profile_picture']}'
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
    fetchAllJobs();
    fetchForYouJobs();
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
              _buildWelcomeSection(),
              _buildForYouSection(),
              //JobCarousel(forYou),
              _buildRecentItems(),
            ],
          ),
        ),
      ),
    );
  }

  bool _showJobOfferOptions = false;

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
  List<Job> visibleForYouJobs =
      forYouJobs.take(_forYouCurrentMaxIndex).toList();

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
                  return ItemsJobs(job);
                },
              ),
              if (_forYouCurrentMaxIndex < forYouJobs.length)
                Center(
                  //alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _forYouCurrentMaxIndex = (_forYouCurrentMaxIndex +
                                _forYouItemsPerPage)
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
              return RecentItemsList(job);
            } else {
              // This is the "Voir plus" button shown after the last item
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
