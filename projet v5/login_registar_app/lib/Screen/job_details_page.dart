import 'package:flutter/material.dart';
import '../models/job_model.dart';

class JobDetailsPage extends StatelessWidget {
  final Job job;

  const JobDetailsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job.jobTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.jobTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Entreprise/Recruteur: ${job.categoryName}"),
            const SizedBox(height: 10),
            Text("Lieu: ${job.jobLocation}"),
            const SizedBox(height: 10),
            Text("Salaire: ${job.salary}"),
            const SizedBox(height: 10),
            Text("Description:\n${job.description}"),
          ],
        ),
      ),
    );
  }
}
