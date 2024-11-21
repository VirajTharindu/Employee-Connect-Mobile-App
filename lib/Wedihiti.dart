import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class WedihitiFamiliesScreen extends StatefulWidget {
  @override
  _WedihitiFamiliesScreenState createState() => _WedihitiFamiliesScreenState();
}

class _WedihitiFamiliesScreenState extends State<WedihitiFamiliesScreen> {
  Map<String, List<FamilyMember>> groupedWedihitiFamilies = {};

  @override
  void initState() {
    super.initState();
    _fetchWedihitiFamilies();
  }

  Future<void> _fetchWedihitiFamilies() async {
    final dbHelper = DatabaseHelper(); // Instantiate your DatabaseHelper
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryWedihitiFamilies();

    final List<FamilyMember> familiesWithWedihiti =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Group family members by household number
    groupedWedihitiFamilies.clear(); // Clear previous data
    for (var familyMember in familiesWithWedihiti) {
      if (groupedWedihitiFamilies.containsKey(familyMember.householdNumber)) {
        groupedWedihitiFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedWedihitiFamilies[familyMember.householdNumber] = [familyMember];
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
        title: Text('Adult Aid receivers'),
      ),
      body: groupedWedihitiFamilies.isEmpty
          ? const Center(
              child: Text(
                'No data available for Wedihiti aid recipients.',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              itemCount: groupedWedihitiFamilies.keys.length,
              itemBuilder: (context, index) {
                String householdNumber =
                    groupedWedihitiFamilies.keys.elementAt(index);
                List<FamilyMember> members =
                    groupedWedihitiFamilies[householdNumber]!;

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
