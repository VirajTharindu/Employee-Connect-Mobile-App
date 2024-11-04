import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import your DatabaseHelper
import 'family_member.dart'; // Import your FamilyMember model

class PrivateScreen extends StatefulWidget {
  @override
  _PrivateScreenState createState() => _PrivateScreenState();
}

class _PrivateScreenState extends State<PrivateScreen> {
  late Future<List<FamilyMember>> _privateFamilies;
  late Map<String, List<FamilyMember>> groupedPrivateFamilies;

  @override
  void initState() {
    super.initState();
    _privateFamilies = _fetchPrivateFamilies();
  }

  Future<List<FamilyMember>> _fetchPrivateFamilies() async {
    final List<FamilyMember> familyMembers =
        await DatabaseHelper().queryPrivateEmployees();

    // Group family members by householdNumber
    groupedPrivateFamilies = {};
    for (var familyMember in familyMembers) {
      if (groupedPrivateFamilies.containsKey(familyMember.householdNumber)) {
        groupedPrivateFamilies[familyMember.householdNumber]!.add(familyMember);
      } else {
        groupedPrivateFamilies[familyMember.householdNumber] = [familyMember];
      }
    }

    return familyMembers; // Return the full list
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
        title: Text('Private Employees'),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _privateFamilies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No private employees found.'));
          }

          final householdNumbers = groupedPrivateFamilies.keys.toList();

          return ListView.builder(
            itemCount: householdNumbers.length,
            itemBuilder: (context, index) {
              final householdNumber = householdNumbers[index];
              final familyMembers = groupedPrivateFamilies[householdNumber]!;

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
