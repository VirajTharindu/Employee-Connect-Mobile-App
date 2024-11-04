import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'family_member.dart';

class NoJobScreen extends StatefulWidget {
  @override
  _NoJobScreenState createState() => _NoJobScreenState();
}

class _NoJobScreenState extends State<NoJobScreen> {
  late Future<List<FamilyMember>> _noJobFamilies;
  late Map<String, List<FamilyMember>> groupedNoJobFamilies;

  @override
  void initState() {
    super.initState();
    _noJobFamilies = _fetchNoJobFamilies();
  }

  Future<List<FamilyMember>> _fetchNoJobFamilies() async {
    final List<FamilyMember> familyMembers =
        await DatabaseHelper().queryNoJobEmployees();

    groupedNoJobFamilies = {};
    for (var familyMember in familyMembers) {
      if (groupedNoJobFamilies.containsKey(familyMember.householdNumber)) {
        groupedNoJobFamilies[familyMember.householdNumber]!.add(familyMember);
      } else {
        groupedNoJobFamilies[familyMember.householdNumber] = [familyMember];
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
        title: Text('No Job Employees'),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _noJobFamilies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No unemployed members found.'));
          }

          final householdNumbers = groupedNoJobFamilies.keys.toList();

          return ListView.builder(
            itemCount: householdNumbers.length,
            itemBuilder: (context, index) {
              final householdNumber = householdNumbers[index];
              final familyMembers = groupedNoJobFamilies[householdNumber]!;

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
