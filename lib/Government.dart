import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class GovernmentScreen extends StatefulWidget {
  @override
  _GovernmentScreenState createState() => _GovernmentScreenState();
}

class _GovernmentScreenState extends State<GovernmentScreen> {
  late Future<List<FamilyMember>> _governmentFamilies;
  late Map<String, List<FamilyMember>> groupedGovernmentFamilies;

  @override
  void initState() {
    super.initState();
    _governmentFamilies = _fetchGovernmentFamilies();
  }

  Future<List<FamilyMember>> _fetchGovernmentFamilies() async {
    final List<FamilyMember> familyMembers =
        await DatabaseHelper().queryGovernmentEmployees();

    // Group family members by householdNumber
    groupedGovernmentFamilies = {};
    for (var familyMember in familyMembers) {
      if (groupedGovernmentFamilies.containsKey(familyMember.householdNumber)) {
        groupedGovernmentFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedGovernmentFamilies[familyMember.householdNumber] = [
          familyMember
        ];
      }
    }

    return familyMembers; // Return the full list
  }

  String getOrdinal(int number) {
    // Function to get the ordinal suffix
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th'; // Special case for 11th, 12th, 13th
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Government Employees'),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _governmentFamilies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No government employees found.'));
          }

          // Create a list of keys from groupedGovernmentFamilies
          final householdNumbers = groupedGovernmentFamilies.keys.toList();

          return ListView.builder(
            itemCount: householdNumbers.length,
            itemBuilder: (context, index) {
              final householdNumber = householdNumbers[index];
              final familyMembers = groupedGovernmentFamilies[householdNumber]!;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: ExpansionTile(
                  title: Text(
                      '${index + 1}. Household Number: $householdNumber'), // Numbering starts from 1
                  subtitle: Text('Members: ${familyMembers.length}'),
                  children: familyMembers.asMap().entries.map((entry) {
                    int memberIndex = entry.key + 1; // Get 1-based index
                    FamilyMember familyMember =
                        entry.value; // The family member

                    return ListTile(
                      title: Text(
                          '${getOrdinal(memberIndex)}: ${familyMember.name}'), // Display the name with ordinal
                      subtitle: Text(
                          'National ID: ${familyMember.nationalId}'), // Display the national ID
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
