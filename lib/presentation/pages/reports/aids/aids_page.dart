import 'package:flutter/material.dart';
import 'package:employee_connect/presentation/pages/reports/aids/tuberculosis_aid_page.dart';
// Import the relevant aid screens for navigation
import 'package:employee_connect/presentation/pages/reports/aids/samurdhi_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/aswasuma_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/wedihiti_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/mahajanadara_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/abhadhitha_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/shishyadara_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/pilikadara_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/any_aid_page.dart';

class AidsScreen extends StatelessWidget {
  // List of aids with corresponding route information
  final List<Map<String, dynamic>> aids = [
    {'name': 'Samurdi Aid', 'route': SamurdhiFamiliesScreen()},
    {'name': 'Aswasuma Aid', 'route': AswasumaFamiliesScreen()},
    {'name': "Adults' Aid", 'route': WedihitiFamiliesScreen()},
    {'name': 'Mahajanadara Aid', 'route': MahajanadaraFamiliesScreen()},
    {'name': 'Disability Aid', 'route': AbhadithaFamiliesScreen()},
    {'name': "Students' Aid", 'route': ShishshyadaraFamiliesScreen()},
    {'name': 'Cancer Aid', 'route': PilikadaraFamiliesScreen()},
    {'name': 'Tuberculosis Aid', 'route': TuberculosisAidScreen()},
    {'name': 'Any Aid', 'route': AnyAidFamiliesScreen()},
  ];

  AidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aid Types'),
      ),
      body: ListView.builder(
        itemCount: aids.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(aids[index]['name']),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to the relevant screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => aids[index]['route'],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
