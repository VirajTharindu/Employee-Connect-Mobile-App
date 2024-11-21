import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class MahajanadaraFamiliesScreen extends StatefulWidget {
  @override
  _MahajanadaraFamiliesScreenState createState() =>
      _MahajanadaraFamiliesScreenState();
}

class _MahajanadaraFamiliesScreenState
    extends State<MahajanadaraFamiliesScreen> {
  Map<String, List<FamilyMember>> groupedMahajanadaraFamilies = {};

  @override
  void initState() {
    super.initState();
    _fetchMahajanadaraFamilies();
  }

  Future<void> _fetchMahajanadaraFamilies() async {
    final dbHelper = DatabaseHelper(); // Instantiate your DatabaseHelper
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryMahajanadaraFamilies();

    final List<FamilyMember> familiesWithMahajanadara =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Group family members by household number
    groupedMahajanadaraFamilies.clear(); // Clear previous data
    for (var familyMember in familiesWithMahajanadara) {
      if (groupedMahajanadaraFamilies
          .containsKey(familyMember.householdNumber)) {
        groupedMahajanadaraFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedMahajanadaraFamilies[familyMember.householdNumber] = [
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
        title: Text('Mahajanadara Aid receivers'),
      ),
      body: groupedMahajanadaraFamilies.isEmpty
          ? const Center(
              child: Text(
                'No data available for Mahajanadara aid receivers.',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              itemCount: groupedMahajanadaraFamilies.keys.length,
              itemBuilder: (context, index) {
                String householdNumber =
                    groupedMahajanadaraFamilies.keys.elementAt(index);
                List<FamilyMember> members =
                    groupedMahajanadaraFamilies[householdNumber]!;

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
