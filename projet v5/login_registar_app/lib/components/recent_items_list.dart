import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:login_registar_app/models/job_model.dart';
import '../constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentItemsList extends StatefulWidget {
  final Job job;

  const RecentItemsList(this.job, {super.key});

  @override
  State<RecentItemsList> createState() => _RecentItemsListState();
}

class _RecentItemsListState extends State<RecentItemsList> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavoriteStatus();
  }

  Future<void> loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('favoriteJobs') ?? [];

    setState(() {
      isFavorite = saved.any(
        (item) => Job.fromJson(jsonDecode(item)).id == widget.job.id,
      );
    });
  }

  Future<void> toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('favoriteJobs') ?? [];
    final jobJson = jsonEncode(widget.job.toJson());

    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      if (!saved.any(
          (item) => Job.fromJson(jsonDecode(item)).id == widget.job.id)) {
        saved.add(jobJson);
      }
    } else {
      saved.removeWhere(
          (item) => Job.fromJson(jsonDecode(item)).id == widget.job.id);
    }

    await prefs.setStringList('favoriteJobs', saved);
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 8,
            ),
          ],
        ),
        height: 110,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: job.logoUrl != null
                  ? Image.network(job.logoUrl!, width: 50, height: 50)
                  : Icon(
                      job.employerType == 'entreprise'
                          ? Icons.business
                          : Icons.person,
                      size: 50,
                      color: primaryColor,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: recentDetail(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 10),
              child: GestureDetector(
                onTap: toggleFavorite,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recentDetail(BuildContext context) {
    final job = widget.job;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              job.jobTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: secondaryTextColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              job.categoryName ?? 'Catégorie inconnue',
              style: TextStyle(
                fontSize: 20,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Icon(Icons.location_on,
                color: Theme.of(context).highlightColor, size: 18),
            const SizedBox(width: 5),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  job.jobLocation,
                  style: TextStyle(
                    fontSize: 15,
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '${job.salary} DT/${job.jobType == 'Travail journalier' ? 'jour' : 'mois'}',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
