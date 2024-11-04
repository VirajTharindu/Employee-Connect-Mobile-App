import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure you import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class SchoolStudentsScreen extends StatefulWidget {
  @override
  _SchoolStudentsScreenState createState() => _SchoolStudentsScreenState();
}

class _SchoolStudentsScreenState extends State<SchoolStudentsScreen> {
  Map<String, Map<String, List<FamilyMember>>> groupedSchoolStudents = {};

  @override
  void initState() {
    super.initState();
    _fetchSchoolStudents();
  }

  Future<void> _fetchSchoolStudents() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> familyMembersMap =
        await dbHelper.queryAllStudentFamilyMembers();

    final List<FamilyMember> allFamilyMembers =
        familyMembersMap.map((map) => FamilyMember.fromMap(map)).toList();

    groupedSchoolStudents.clear();

    for (var familyMember in allFamilyMembers) {
      if (familyMember.grade != null &&
          familyMember.grade != 'None' &&
          int.tryParse(familyMember.grade!) != null) {
        int grade = int.parse(familyMember.grade!);
        String category;

        if (grade >= 1 && grade <= 5) {
          category = 'Primary';
        } else if (grade >= 6 && grade <= 9) {
          category = 'Secondary';
        } else if (grade >= 10 && grade <= 11) {
          category = 'O/L';
        } else if (grade >= 12 && grade <= 13) {
          category = 'A/L';
        } else {
          continue;
        }

        if (!groupedSchoolStudents.containsKey(category)) {
          groupedSchoolStudents[category] = {};
        }

        if (groupedSchoolStudents[category]!
            .containsKey(familyMember.householdNumber)) {
          groupedSchoolStudents[category]![familyMember.householdNumber]!
              .add(familyMember);
        } else {
          groupedSchoolStudents[category]![familyMember.householdNumber] = [
            familyMember
          ];
        }
      }
    }

    setState(() {});
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
    final List<String> orderedCategories = [
      'Primary',
      'Secondary',
      'O/L',
      'A/L',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('School Students'),
      ),
      body: ListView.builder(
        itemCount: orderedCategories.length,
        itemBuilder: (context, index) {
          String category = orderedCategories[index];
          Map<String, List<FamilyMember>>? householdMembers =
              groupedSchoolStudents[category];

          // Check if there are no members for this category
          if (householdMembers == null || householdMembers.isEmpty) {
            return ListTile(
              title: Text(
                category,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("No members found for this education level"),
            );
          }

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: ExpansionTile(
              title: Text('$category Students'),
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
                          category == 'O/L' || category == 'A/L'
                              ? 'National ID: ${member.nationalId} | Grade: ${member.grade}'
                              : 'Grade: ${member.grade}',
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
