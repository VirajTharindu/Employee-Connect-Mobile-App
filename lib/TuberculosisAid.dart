import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class TuberculosisAidScreen extends StatefulWidget {
  @override
  _TuberculosisAidScreenState createState() => _TuberculosisAidScreenState();
}

class _TuberculosisAidScreenState extends State<TuberculosisAidScreen> {
  Map<String, List<FamilyMember>> groupedTuberculosisFamilies = {};

  @override
  void initState() {
    super.initState();
    _fetchTuberculosisAidFamilies();
  }

  Future<void> _fetchTuberculosisAidFamilies() async {
    final dbHelper = DatabaseHelper(); // Instantiate your DatabaseHelper
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryTuberculosisAidFamilies();

    final List<FamilyMember> familiesWithTuberculosisAid =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Group family members by household number
    groupedTuberculosisFamilies.clear(); // Clear previous data
    for (var familyMember in familiesWithTuberculosisAid) {
      if (groupedTuberculosisFamilies
          .containsKey(familyMember.householdNumber)) {
        groupedTuberculosisFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedTuberculosisFamilies[familyMember.householdNumber] = [
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
        title: const Text('Tuberculosis Aid Recipients'),
      ),
      body: groupedTuberculosisFamilies.isEmpty
          ? const Center(
              child: Text(
                'No data available for Tuberculosis Aid recipients.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: groupedTuberculosisFamilies.keys.length,
              itemBuilder: (context, index) {
                String householdNumber =
                    groupedTuberculosisFamilies.keys.elementAt(index);
                List<FamilyMember> members =
                    groupedTuberculosisFamilies[householdNumber]!;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
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
