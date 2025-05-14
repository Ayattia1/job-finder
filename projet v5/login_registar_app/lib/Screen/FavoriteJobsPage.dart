import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/models/job_model.dart';
import 'package:login_registar_app/components/items_jobs.dart';

class FavoriteJobsPage extends StatefulWidget {
  const FavoriteJobsPage({super.key});

  @override
  State<FavoriteJobsPage> createState() => _FavoriteJobsPageState();
}

class _FavoriteJobsPageState extends State<FavoriteJobsPage> {
  List<Job> favoriteJobs = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('favoriteJobs') ?? [];

    setState(() {
      favoriteJobs = jsonList
          .map((json) => Job.fromJson(jsonDecode(json)))
          .toList();
    });
  }

  Future<void> toggleFavorite(Job job) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('favoriteJobs') ?? [];

    saved.removeWhere((item) =>
        Job.fromJson(jsonDecode(item)).id == job.id);

    await prefs.setStringList('favoriteJobs', saved);

    setState(() {
      favoriteJobs.removeWhere((j) => j.id == job.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offres favorites')),
      body: favoriteJobs.isEmpty
          ? const Center(child: Text("Aucune offre favorite."))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favoriteJobs.length,
              itemBuilder: (context, index) {
                return ItemsJobs(
  favoriteJobs[index],
  isFavorite: true,
  onFavoriteToggle: () => toggleFavorite(favoriteJobs[index]),
);

              },
            ),
    );
  }
}
