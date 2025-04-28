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

Widget _buildModernDrawer() {
  return Drawer(
    child: Container(
      color: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person, size: 36, color: primaryColor),
                ),
                SizedBox(width: 16),
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
                      SizedBox(height: 4),
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
              children: [
                _buildDrawerButton(Icons.home_outlined, 'Accueil', primaryColor, () {}),
                _buildDrawerButton(Icons.person_outline, 'Profil', primaryColor, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                }),
                _buildDrawerButton(Icons.settings_outlined, 'Paramètres', primaryColor, () {}),
              ],
            ),
          ),
          Divider(),
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  child: ElevatedButton.icon(
    icon: Icon(Icons.logout, color: Colors.white),
    label: Text(
      'Se déconnecter',
      style: TextStyle(color: Colors.black), // Set the text color to black
    ),
    onPressed: _logout,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent,
      minimumSize: Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),

          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

Widget _buildDrawerButton(
    IconData icon, String title, Color color, VoidCallback onTap) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                size: 26,
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
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