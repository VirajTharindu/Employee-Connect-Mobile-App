import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class PeopleBasedOnEthnicityScreen extends StatefulWidget {
  @override
  _PeopleBasedOnEthnicityScreenState createState() =>
      _PeopleBasedOnEthnicityScreenState();
}

class _PeopleBasedOnEthnicityScreenState
    extends State<PeopleBasedOnEthnicityScreen> {
  Map<String, Map<String, List<FamilyMember>>> groupedEthnicities = {};

  @override
  void initState() {
    super.initState();
    _fetchEthnicityFamilyMembers();
  }

  Future<void> _fetchEthnicityFamilyMembers() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> familyMembersMap = await dbHelper
        .queryNationalityFamilyMembers(); // Ensure this method is defined in DatabaseHelper

    final List<FamilyMember> allFamilyMembers =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Clear previous data
    groupedEthnicities.clear();

    for (var familyMember in allFamilyMembers) {
      String ethnicity = familyMember.nationality; // Handle null case
      String householdNumber = familyMember.householdNumber;

      // Group by ethnicity, then by household number
      if (!groupedEthnicities.containsKey(ethnicity)) {
        groupedEthnicities[ethnicity] = {};
      }

      if (groupedEthnicities[ethnicity]!.containsKey(householdNumber)) {
        groupedEthnicities[ethnicity]![householdNumber]!.add(familyMember);
      } else {
        groupedEthnicities[ethnicity]![householdNumber] = [familyMember];
      }
    }

    setState(() {
      // Refresh UI
    });
  }

  // Define the ordered list of ethnicities as specified
  final List<String> _orderedEthnicities = [
    'Sinhala',
    'Tamil',
    'Muslim',
    'Burgher',
    'Other',
  ];

  String getOrdinal(int number) {
    if (number <= 0) return number.toString();
    switch (number % 10) {
      case 1:
        return (number % 100 == 11) ? '${number}th' : '${number}st';
      case 2:
        return (number % 100 == 12) ? '${number}th' : '${number}nd';
      case 3:
        return (number % 100 == 13) ? '${number}th' : '${number}rd';
      default:
        return '${number}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Family Members by Ethnicity'),
      ),
      body: ListView.builder(
        itemCount: _orderedEthnicities.length,
        itemBuilder: (context, index) {
          String ethnicity = _orderedEthnicities[index];
          Map<String, List<FamilyMember>> householdMap =
              groupedEthnicities[ethnicity] ?? {};

          // Show a placeholder if no household members are found for this ethnicity
          if (householdMap.isEmpty) {
            return ListTile(
              title: Text(
                ethnicity,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("No members found for this ethnicity"),
            );
          }

          // Display the households grouped by ethnicity
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: ExpansionTile(
              title: Text('$ethnicity'),
              subtitle: Text('Households: ${householdMap.keys.length}'),
              children:
                  householdMap.entries.toList().asMap().entries.map((entry) {
                int householdIndex =
                    entry.key + 1; // Numbering household numbers
                MapEntry<String, List<FamilyMember>> entryValue = entry.value;
                String householdNumber = entryValue.key;
                List<FamilyMember> members = entryValue.value;

                return ExpansionTile(
                  title: Text(
                    '${householdMap.keys.toList().indexOf(householdNumber) + 1}. Household Number: $householdNumber',
                  ),
                  subtitle: Text('Members: ${members.length}'),
                  children: members.asMap().entries.map((entry) {
                    int memberIndex = entry.key + 1; // Numbering family members
                    FamilyMember member = entry.value;

                    return ListTile(
                      title: Text(
                        '${getOrdinal(memberIndex)}: ${member.name}',
                      ),
                      subtitle: Text(
                        'National ID: ${member.nationalId}',
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
