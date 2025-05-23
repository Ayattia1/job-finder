import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:login_registar_app/components/items_jobs.dart';
import 'package:login_registar_app/components/recent_items_list.dart';
import 'package:login_registar_app/constants.dart';
import 'package:svg_flutter/svg_flutter.dart';
import '../models/job_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();

}
class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  Future<void> _verifyToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      // No token, redirect to login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final url = Uri.parse('http://192.168.1.26:8001/api/verify-token');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _isAuthenticated = true;
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
      body: SafeArea(
        child: ListView(
          children: [
            // for menu , search and filter icon
            customAppBar(),
            // for welcome text
            welcomText(),
            // for you
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                "For You",
                style: TextStyle(
                  fontSize: 20,
                  color: secondaryTextColor,
                ),
              ),
            ),
            JobCarousel(forYou),
            // for recent
            recentItems()
          ],
        ),
      ),
    );
  }

  Column recentItems() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 5,
            bottom: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent",
                style: TextStyle(
                  fontSize: 20,
                  color: secondaryTextColor,
                ),
              ),
              Text(
                "See All",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
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
              return RecentItemsList(recent[index]);
            },
          ),
        ),
      ],
    );
  }

  Padding welcomText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi Jade",
            style: TextStyle(
              fontSize: 20,
              color: secondaryTextColor,
            ),
          ),
          Text(
            "Find your next",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Text(
            "design job",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Padding customAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/icons/slider.svg",
            height: 35,
          ),
          const Spacer(),
          SvgPicture.asset(
            "assets/icons/search.svg",
            height: 35,
          ),
          const SizedBox(
            width: 20,
          ),
          SvgPicture.asset(
            "assets/icons/filter.svg",
            height: 35,
          ),
        ],
      ),
    );
  }
}


class JobCarousel extends StatelessWidget {
  List<Job> jobs;
  JobCarousel(this.jobs, {super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: jobs
          .map((e) => ItemsJobs(
                e,
                themDark: jobs.indexOf(e) == 0,
              ))
          .toList(),
      options: CarouselOptions(
        enableInfiniteScroll: false,
        reverse: false,
        viewportFraction: 0.86,
        height: 230,
      ),
    );
  }
}
