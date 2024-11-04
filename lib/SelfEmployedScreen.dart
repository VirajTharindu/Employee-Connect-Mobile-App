import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'family_member.dart';

class SelfEmployedScreen extends StatefulWidget {
  @override
  _SelfEmployedScreenState createState() => _SelfEmployedScreenState();
}

class _SelfEmployedScreenState extends State<SelfEmployedScreen> {
  late Future<List<FamilyMember>> _selfEmployedFamilies;
  late Map<String, List<FamilyMember>> groupedSelfEmployedFamilies;

  @override
  void initState() {
    super.initState();
    _selfEmployedFamilies = _fetchSelfEmployedFamilies();
  }

  Future<List<FamilyMember>> _fetchSelfEmployedFamilies() async {
    final List<FamilyMember> familyMembers =
        await DatabaseHelper().querySelfEmployedEmployees();

    groupedSelfEmployedFamilies = {};
    for (var familyMember in familyMembers) {
      if (groupedSelfEmployedFamilies
          .containsKey(familyMember.householdNumber)) {
        groupedSelfEmployedFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedSelfEmployedFamilies[familyMember.householdNumber] = [
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
        title: Text('Self-Employed Employees'),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _selfEmployedFamilies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No self-employed employees found.'));
          }

          final householdNumbers = groupedSelfEmployedFamilies.keys.toList();

          return ListView.builder(
            itemCount: householdNumbers.length,
            itemBuilder: (context, index) {
              final householdNumber = householdNumbers[index];
              final familyMembers =
                  groupedSelfEmployedFamilies[householdNumber]!;

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
