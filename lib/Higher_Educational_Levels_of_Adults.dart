import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class HigherEducationalLevelsOfAdultsScreen extends StatefulWidget {
  @override
  _HigherEducationalLevelsOfAdultsScreenState createState() =>
      _HigherEducationalLevelsOfAdultsScreenState();
}

class _HigherEducationalLevelsOfAdultsScreenState
    extends State<HigherEducationalLevelsOfAdultsScreen> {
  Map<String, Map<String, List<FamilyMember>>> groupedEducationLevels = {};

  @override
  void initState() {
    super.initState();
    _fetchHigherEducationLevels();
  }

  Future<void> _fetchHigherEducationLevels() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryHigherEducationFamilyMembers();

    final List<FamilyMember> allFamilyMembers =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    // Clear previous data
    groupedEducationLevels.clear();

    for (var familyMember in allFamilyMembers) {
      String educationLevel = familyMember.educationQualification ?? 'Unknown';

      // Group by education level, then by household number
      if (!groupedEducationLevels.containsKey(educationLevel)) {
        groupedEducationLevels[educationLevel] = {};
      }

      if (groupedEducationLevels[educationLevel]!
          .containsKey(familyMember.householdNumber)) {
        groupedEducationLevels[educationLevel]![familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedEducationLevels[educationLevel]![familyMember.householdNumber] =
            [familyMember];
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
    final List<String> orderedQualifications = [
      'Primary (1-5)',
      'Junior Secondary (6-9)',
      'Senior Secondary (10-11)',
      'O/L passed',
      'Collegiate Level (12-13)',
      'A/L passed',
      'Diploma',
      'Degree',
      'Higher Studies',
      'No Schooling'
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text('Higher Educational Levels of Adults'),
        ),
        body: ListView.builder(
          itemCount: orderedQualifications.length,
          itemBuilder: (context, index) {
            String educationLevel = orderedQualifications[index];

            // Attempt to retrieve household members based on the education level
            Map<String, List<FamilyMember>>? householdMembers =
                groupedEducationLevels[educationLevel];

            // If no members are found for this education level, show a placeholder
            if (householdMembers == null || householdMembers.isEmpty) {
              return ListTile(
                title: Text(
                  educationLevel,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("No members found for this education level"),
              );
            }

            // Otherwise, display the members grouped by household as usual
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: ExpansionTile(
                title: Text('$educationLevel'),
                subtitle: Text('Households: ${householdMembers.keys.length}'),
                children: householdMembers.entries.map((entry) {
                  String householdNumber = entry.key;
                  List<FamilyMember> members = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ExpansionTile(
                      title: Text(
                        '${householdMembers.keys.toList().indexOf(householdNumber) + 1}. Household Number: $householdNumber',
                      ),
                      subtitle: Text('Members: ${members.length}'),
                      children: members.asMap().entries.map((entry) {
                        int memberIndex = entry.key + 1;
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
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ));
  }
}
