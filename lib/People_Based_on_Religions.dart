import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class PeopleBasedOnReligionsScreen extends StatefulWidget {
  @override
  _PeopleBasedOnReligionsScreenState createState() =>
      _PeopleBasedOnReligionsScreenState();
}

class _PeopleBasedOnReligionsScreenState
    extends State<PeopleBasedOnReligionsScreen> {
  Map<String, Map<String, List<FamilyMember>>> groupedReligions = {};

  @override
  void initState() {
    super.initState();
    _fetchReligionFamilyMembers();
  }

  Future<void> _fetchReligionFamilyMembers() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryReligionFamilyMembers();

    final List<FamilyMember> allFamilyMembers =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Clear previous data
    groupedReligions.clear();

    for (var familyMember in allFamilyMembers) {
      String religion = familyMember.religion; // Handle null case
      String householdNumber = familyMember.householdNumber;

      // Group by religion, then by household number
      if (!groupedReligions.containsKey(religion)) {
        groupedReligions[religion] = {};
      }

      if (groupedReligions[religion]!.containsKey(householdNumber)) {
        groupedReligions[religion]![householdNumber]!.add(familyMember);
      } else {
        groupedReligions[religion]![householdNumber] = [familyMember];
      }
    }

    setState(() {
      // Refresh UI
    });
  }

  // Define the ordered list of religions as specified
  final List<String> _orderedReligions = [
    'Buddhism',
    'Hinduism',
    'Islam',
    'Christianity',
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
        title: Text('Family Members by Religion'),
      ),
      body: ListView.builder(
        itemCount: _orderedReligions.length,
        itemBuilder: (context, index) {
          String religion = _orderedReligions[index];
          Map<String, List<FamilyMember>> householdMap =
              groupedReligions[religion] ?? {};

          // Show a placeholder if no household members are found for this religion
          if (householdMap.isEmpty) {
            return ListTile(
              title: Text(
                religion,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("No members found for this religion"),
            );
          }

          // Display the households grouped by religion
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: ExpansionTile(
              title: Text('$religion'),
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
