import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class PilikadaraFamiliesScreen extends StatefulWidget {
  @override
  _PilikadaraFamiliesScreenState createState() =>
      _PilikadaraFamiliesScreenState();
}

class _PilikadaraFamiliesScreenState extends State<PilikadaraFamiliesScreen> {
  Map<String, List<FamilyMember>> groupedPilikadaraFamilies = {};

  @override
  void initState() {
    super.initState();
    _fetchPilikadaraFamilies();
  }

  Future<void> _fetchPilikadaraFamilies() async {
    final dbHelper = DatabaseHelper(); // Instantiate your DatabaseHelper
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryPilikadaraFamilies();

    final List<FamilyMember> familiesWithPilikadara =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Group family members by household number
    groupedPilikadaraFamilies.clear(); // Clear previous data
    for (var familyMember in familiesWithPilikadara) {
      if (groupedPilikadaraFamilies.containsKey(familyMember.householdNumber)) {
        groupedPilikadaraFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedPilikadaraFamilies[familyMember.householdNumber] = [
          familyMember
        ];
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
        title: Text('Cancer Aid receivers'),
      ),
      body: ListView.builder(
        itemCount: groupedPilikadaraFamilies.keys.length,
        itemBuilder: (context, index) {
          String householdNumber =
              groupedPilikadaraFamilies.keys.elementAt(index);
          List<FamilyMember> members =
              groupedPilikadaraFamilies[householdNumber]!;

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
