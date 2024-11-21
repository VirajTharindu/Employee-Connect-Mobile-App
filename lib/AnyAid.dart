import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class AnyAidFamiliesScreen extends StatefulWidget {
  @override
  _AnyAidFamiliesScreenState createState() => _AnyAidFamiliesScreenState();
}

class _AnyAidFamiliesScreenState extends State<AnyAidFamiliesScreen> {
  Map<String, List<FamilyMember>> groupedAnyAidFamilies = {};

  @override
  void initState() {
    super.initState();
    _fetchAnyAidFamilies();
  }

  Future<void> _fetchAnyAidFamilies() async {
    final dbHelper = DatabaseHelper(); // Instantiate your DatabaseHelper
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryAnyAidFamilies();

    final List<FamilyMember> familiesWithAnyAid =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Group family members by household number
    groupedAnyAidFamilies.clear(); // Clear previous data
    for (var familyMember in familiesWithAnyAid) {
      if (groupedAnyAidFamilies.containsKey(familyMember.householdNumber)) {
        groupedAnyAidFamilies[familyMember.householdNumber]!.add(familyMember);
      } else {
        groupedAnyAidFamilies[familyMember.householdNumber] = [familyMember];
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
        title: Text('Any Aid receivers'),
      ),
      body: groupedAnyAidFamilies.isEmpty
          ? const Center(
              child: Text(
                'No data available for Any Aid recipients.',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              itemCount: groupedAnyAidFamilies.keys.length,
              itemBuilder: (context, index) {
                String householdNumber =
                    groupedAnyAidFamilies.keys.elementAt(index);
                List<FamilyMember> members =
                    groupedAnyAidFamilies[householdNumber]!;

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
