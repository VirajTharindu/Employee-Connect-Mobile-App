import 'package:flutter/material.dart';
import 'package:village_officer_app/TuberculosisAid.dart';
// Import the relevant aid screens for navigation
import 'Samurdhi.dart';
import 'Aswasuma.dart';
import 'Wedihiti.dart';
import 'Mahajanadara.dart';
import 'Abhadhitha.dart';
import 'Shishyadara.dart';
import 'Pilikadara.dart';
import 'AnyAid.dart';

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
