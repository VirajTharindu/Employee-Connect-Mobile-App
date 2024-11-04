import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class SamurdhiFamiliesScreen extends StatefulWidget {
  @override
  _SamurdhiFamiliesScreenState createState() => _SamurdhiFamiliesScreenState();
}

class _SamurdhiFamiliesScreenState extends State<SamurdhiFamiliesScreen> {
  Map<String, List<FamilyMember>> groupedSamurdhiFamilies = {};

  @override
  void initState() {
    super.initState();
    _fetchSamurdhiFamilies();
  }

  Future<void> _fetchSamurdhiFamilies() async {
    final dbHelper = DatabaseHelper(); // Instantiate your DatabaseHelper
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.querySamurdhiFamilies();

    final List<FamilyMember> familiesWithSamurdhi =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Group family members by household number
    groupedSamurdhiFamilies.clear(); // Clear previous data
    for (var familyMember in familiesWithSamurdhi) {
      if (groupedSamurdhiFamilies.containsKey(familyMember.householdNumber)) {
        groupedSamurdhiFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedSamurdhiFamilies[familyMember.householdNumber] = [familyMember];
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
        title: Text('Samurdhi Aid receivers'),
      ),
      body: ListView.builder(
        itemCount: groupedSamurdhiFamilies.keys.length,
        itemBuilder: (context, index) {
          String householdNumber =
              groupedSamurdhiFamilies.keys.elementAt(index);
          List<FamilyMember> members =
              groupedSamurdhiFamilies[householdNumber]!;

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: ExpansionTile(
              title: Text('${index + 1}. Household Number: $householdNumber'),
              subtitle: Text('Members: ${members.length}'),
              children: members.asMap().entries.map((entry) {
                int memberIndex = entry.key + 1;
                FamilyMember familyMember = entry.value;

                return ListTile(
                  title:
                      Text('${getOrdinal(memberIndex)}: ${familyMember.name}'),
                  subtitle: Text('National ID: ${familyMember.nationalId}'),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
