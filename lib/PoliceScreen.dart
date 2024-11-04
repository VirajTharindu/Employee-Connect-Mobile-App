import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'family_member.dart';

class PoliceScreen extends StatefulWidget {
  @override
  _PoliceScreenState createState() => _PoliceScreenState();
}

class _PoliceScreenState extends State<PoliceScreen> {
  late Future<List<FamilyMember>> _policeFamilies;
  late Map<String, List<FamilyMember>> groupedPoliceFamilies;

  @override
  void initState() {
    super.initState();
    _policeFamilies = _fetchPoliceFamilies();
  }

  Future<List<FamilyMember>> _fetchPoliceFamilies() async {
    final List<FamilyMember> familyMembers =
        await DatabaseHelper().queryPoliceEmployees();

    groupedPoliceFamilies = {};
    for (var familyMember in familyMembers) {
      if (groupedPoliceFamilies.containsKey(familyMember.householdNumber)) {
        groupedPoliceFamilies[familyMember.householdNumber]!.add(familyMember);
      } else {
        groupedPoliceFamilies[familyMember.householdNumber] = [familyMember];
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
        title: Text('Police Employees'),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _policeFamilies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No police employees found.'));
          }

          final householdNumbers = groupedPoliceFamilies.keys.toList();

          return ListView.builder(
            itemCount: householdNumbers.length,
            itemBuilder: (context, index) {
              final householdNumber = householdNumbers[index];
              final familyMembers = groupedPoliceFamilies[householdNumber]!;

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
