import 'package:flutter/material.dart';
import 'package:login_registar_app/constants.dart';
import 'package:login_registar_app/models/job_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ItemsJobs extends StatefulWidget {
  final Job job;
  final bool themDark;
  final bool? isFavorite; // allow external control
  final VoidCallback? onFavoriteToggle; // allow external callback

  const ItemsJobs(
    this.job, {
    super.key,
    this.themDark = false,
    this.isFavorite,
    this.onFavoriteToggle,
  });

  @override
  State<ItemsJobs> createState() => _ItemsJobsState();
}

class _ItemsJobsState extends State<ItemsJobs> {
  bool _localFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFavorite != null) {
      _localFavorite = widget.isFavorite!;
    } else {
      loadFavoriteStatus();
    }
  }

  Future<void> loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('favoriteJobs') ?? [];
    bool found = saved.any(
        (item) => Job.fromJson(jsonDecode(item)).id == widget.job.id);
    setState(() {
      _localFavorite = found;
    });
  }

  Future<void> toggleFavorite() async {
    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('favoriteJobs') ?? [];

    final jobJson = jsonEncode(widget.job.toJson());

    setState(() {
      _localFavorite = !_localFavorite;
    });

    if (_localFavorite) {
      if (!saved.any((item) =>
          Job.fromJson(jsonDecode(item)).id == widget.job.id)) {
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
    final isDark = widget.themDark;

    final bgColor = isDark ? secondaryColor : Colors.white;
    final titleColor = isDark ? Colors.white : primaryColor;
    final textColor = isDark ? secondaryTextColor : Colors.grey[700];
    final iconBgColor = isDark ? Colors.grey[200] : Colors.grey[100];
    final isFavorite = widget.isFavorite ?? _localFavorite;

    return Padding(
      padding: const EdgeInsets.only(right: 15, bottom: 20, top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(3, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: job.logoUrl != null
                          ? Image.network(
                              job.logoUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                job.employerType == 'entreprise'
                                    ? Icons.business
                                    : Icons.person,
                                size: 40,
                                color: primaryColor,
                              ),
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: toggleFavorite,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFavorite
                            ? (isDark ? Colors.red[300] : Colors.red[100])
                            : Colors.transparent,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? Colors.red
                            : (isDark ? Colors.white70 : Colors.grey),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.categoryName ?? 'Catégorie inconnue',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.jobTitle,
                    style: TextStyle(
                      fontSize: 20,
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).highlightColor,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        job.jobLocation,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${job.salary} DT/${job.jobType == 'Travail journalier' ? 'jour' : 'mois'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w600,
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
