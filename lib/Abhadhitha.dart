import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class AbhadithaFamiliesScreen extends StatefulWidget {
  @override
  _AbhadithaFamiliesScreenState createState() =>
      _AbhadithaFamiliesScreenState();
}

class _AbhadithaFamiliesScreenState extends State<AbhadithaFamiliesScreen> {
  Map<String, List<FamilyMember>> groupedAbhadithaFamilies = {};

  @override
  void initState() {
    super.initState();
    _fetchAbhadithaFamilies();
  }

  Future<void> _fetchAbhadithaFamilies() async {
    final dbHelper = DatabaseHelper(); // Instantiate your DatabaseHelper
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryAbhadithaFamilies();

    final List<FamilyMember> familiesWithAbhaditha =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Group family members by household number
    groupedAbhadithaFamilies.clear(); // Clear previous data
    for (var familyMember in familiesWithAbhaditha) {
      if (groupedAbhadithaFamilies.containsKey(familyMember.householdNumber)) {
        groupedAbhadithaFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedAbhadithaFamilies[familyMember.householdNumber] = [familyMember];
      }
    }

    setState(() {
      // Refresh UI
    });
  }

  String getOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
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
        title: Text('Disability Aid receivers'),
      ),
      body: groupedAbhadithaFamilies.isEmpty
          ? const Center(
              child: Text(
                'No data available for Disability Aid recipients.',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              itemCount: groupedAbhadithaFamilies.keys.length,
              itemBuilder: (context, index) {
                String householdNumber =
                    groupedAbhadithaFamilies.keys.elementAt(index);
                List<FamilyMember> members =
                    groupedAbhadithaFamilies[householdNumber]!;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                  child: ExpansionTile(
                    title: Text(
                        '${index + 1}. Household Number: $householdNumber'),
                    subtitle: Text('Members: ${members.length}'),
                    children: members.asMap().entries.map((entry) {
                      int memberIndex = entry.key + 1;
                      FamilyMember familyMember = entry.value;

                      return ListTile(
                        title: Text(
                            '${getOrdinal(memberIndex)}: ${familyMember.name}'),
                        subtitle:
                            Text('National ID: ${familyMember.nationalId}'),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
