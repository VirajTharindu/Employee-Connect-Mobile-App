import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'family_member.dart';

class CorporationsScreen extends StatefulWidget {
  @override
  _CorporationsScreenState createState() => _CorporationsScreenState();
}

class _CorporationsScreenState extends State<CorporationsScreen> {
  late Future<List<FamilyMember>> _corporationFamilies;
  late Map<String, List<FamilyMember>> groupedCorporationFamilies;

  @override
  void initState() {
    super.initState();
    _corporationFamilies = _fetchCorporationFamilies();
  }

  Future<List<FamilyMember>> _fetchCorporationFamilies() async {
    final List<FamilyMember> familyMembers =
        await DatabaseHelper().queryCorporationEmployees();

    groupedCorporationFamilies = {};
    for (var familyMember in familyMembers) {
      if (groupedCorporationFamilies
          .containsKey(familyMember.householdNumber)) {
        groupedCorporationFamilies[familyMember.householdNumber]!
            .add(familyMember);
      } else {
        groupedCorporationFamilies[familyMember.householdNumber] = [
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
        title: Text('Corporation Employees'),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _corporationFamilies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No corporation employees found.'));
          }

          final householdNumbers = groupedCorporationFamilies.keys.toList();

          return ListView.builder(
            itemCount: householdNumbers.length,
            itemBuilder: (context, index) {
              final householdNumber = householdNumbers[index];
              final familyMembers =
                  groupedCorporationFamilies[householdNumber]!;

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
