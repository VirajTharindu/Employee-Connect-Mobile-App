import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'family_member.dart';

class SemiGovernmentScreen extends StatefulWidget {
  @override
  _SemiGovernmentScreenState createState() => _SemiGovernmentScreenState();
}

class _SemiGovernmentScreenState extends State<SemiGovernmentScreen> {
  late Future<List<FamilyMember>> _semiGovernmentFamilies;
  late Map<String, List<FamilyMember>> groupedSemiGovernmentFamilies;

  @override
  void initState() {
    super.initState();
    _semiGovernmentFamilies = _fetchSemiGovernmentFamilies();
  }

  Future<List<FamilyMember>> _fetchSemiGovernmentFamilies() async {
    final List<FamilyMember> familyMembers =
        await DatabaseHelper().querySemiGovernmentEmployees();

    groupedSemiGovernmentFamilies = {};
    for (var familyMember in familyMembers) {
      if (groupedSemiGovernmentFamilies
          .containsKey(familyMember.householdNumber)) {
        groupedSemiGovernmentFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedSemiGovernmentFamilies[familyMember.householdNumber] = [
          familyMember
        ];
      }
    }

    return familyMembers;
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
        title: Text('Semi-Government Employees'),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _semiGovernmentFamilies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No semi-government employees found.'));
          }

          final householdNumbers = groupedSemiGovernmentFamilies.keys.toList();

          return ListView.builder(
            itemCount: householdNumbers.length,
            itemBuilder: (context, index) {
              final householdNumber = householdNumbers[index];
              final familyMembers =
                  groupedSemiGovernmentFamilies[householdNumber]!;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: ExpansionTile(
                  title:
                      Text('${index + 1}. Household Number: $householdNumber'),
                  subtitle: Text('Members: ${familyMembers.length}'),
                  children: familyMembers.asMap().entries.map((entry) {
                    int memberIndex = entry.key + 1;
                    FamilyMember familyMember = entry.value;

                    return ListTile(
                      title: Text(
                          '${getOrdinal(memberIndex)}: ${familyMember.name}'),
                      subtitle: Text('National ID: ${familyMember.nationalId}'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
