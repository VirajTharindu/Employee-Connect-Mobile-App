import 'package:flutter/material.dart';
// Import the relevant job screens for navigation
import 'package:employee_connect/presentation/pages/reports/employment/government_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/private_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/semi_government_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/corporations_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/forces_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/police_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/self_employed_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/no_job_page.dart';

class JobsScreen extends StatelessWidget {
  // List of jobs with corresponding route information
  final List<Map<String, dynamic>> jobs = [
    {'name': 'Government', 'route': GovernmentScreen()},
    {'name': 'Private', 'route': PrivateScreen()},
    {'name': 'Semi-Government', 'route': SemiGovernmentScreen()},
    {'name': 'Corporations', 'route': CorporationsScreen()},
    {'name': 'Forces', 'route': ForcesScreen()},
    {'name': 'Police', 'route': PoliceScreen()},
    {'name': 'Self-Employed (Business)', 'route': SelfEmployedScreen()},
    {'name': 'No Job or Retired', 'route': NoJobScreen()},
  ];

  JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Types'),
      ),
      body: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(jobs[index]['name']),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to the relevant screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => jobs[index]['route'],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
