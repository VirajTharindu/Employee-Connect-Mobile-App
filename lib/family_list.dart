import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'family_member.dart';
import 'family_profile.dart';

class FamilyList extends StatelessWidget {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  void navigateToFamilyProfile(
      BuildContext context, List<FamilyMember> members) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyProfile(
            familyMembers: members), // Ensure parameter name matches
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building FamilyList widget...');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family List'),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: databaseHelper.retrieveFamilyMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No family list found.'));
          } else {
            // Step 1: Group family members by household number
            Map<String, List<FamilyMember>> groupedByHousehold = {};
            for (var member in snapshot.data!) {
              if (!groupedByHousehold.containsKey(member.householdNumber)) {
                groupedByHousehold[member.householdNumber] = [];
              }
              groupedByHousehold[member.householdNumber]!.add(member);
            }

            // Step 2: Convert the Map into a list for ListView.builder
            List<String> householdNumbers = groupedByHousehold.keys.toList();

            return ListView.builder(
              itemCount: householdNumbers.length,
              itemBuilder: (context, index) {
                final householdNumber = householdNumbers[index];
                final members = groupedByHousehold[householdNumber]!;

                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Household Number: $householdNumber'),
                    subtitle: Text(
                        'Members: ${members.map((m) => m.name).join(", ")}'),
                    onTap: () {
                      // Navigate to FamilyProfile when the list item is tapped
                      navigateToFamilyProfile(context, members);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        if (kDebugMode) {
                          print(
                              'Delete button pressed for household $householdNumber');
                        }
                        // Add delete functionality if needed
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
