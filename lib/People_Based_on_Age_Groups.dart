import 'package:flutter/material.dart';
import 'family_member.dart'; // Import FamilyMember model
import 'database_helper.dart'; // Import DatabaseHelper to retrieve data

class PeopleBasedOnAgeGroups extends StatefulWidget {
  @override
  _PeopleBasedOnAgeGroupsState createState() => _PeopleBasedOnAgeGroupsState();
}

class _PeopleBasedOnAgeGroupsState extends State<PeopleBasedOnAgeGroups> {
  late Future<Map<String, Map<String, List<FamilyMember>>>> ageGroupsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch age groups data grouped by household number
    ageGroupsFuture = _fetchAgeGroupedFamilyMembers();
  }

  Future<Map<String, Map<String, List<FamilyMember>>>>
      _fetchAgeGroupedFamilyMembers() async {
    final ageGroups = await DatabaseHelper.instance.getPeopleBasedOnAgeGroups();

    // Group by household number within each age group
    Map<String, Map<String, List<FamilyMember>>> groupedAgeGroups = {};

    for (var ageGroup in ageGroups.keys) {
      groupedAgeGroups[ageGroup] = {};

      for (var member in ageGroups[ageGroup]!) {
        String householdNumber = member.householdNumber;

        if (!groupedAgeGroups[ageGroup]!.containsKey(householdNumber)) {
          groupedAgeGroups[ageGroup]![householdNumber] = [];
        }
        groupedAgeGroups[ageGroup]![householdNumber]!.add(member);
      }
    }

    return groupedAgeGroups;
  }

  String getOrdinal(int number) {
    if (number <= 0) return number.toString();
    switch (number % 10) {
      case 1:
        return (number % 100 == 11) ? '${number}th' : '${number}st';
      case 2:
        return (number % 100 == 12) ? '${number}th' : '${number}nd';
      case 3:
        return (number % 100 == 13) ? '${number}th' : '${number}rd';
      default:
        return '${number}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('People Based on Age Groups'),
      ),
      body: FutureBuilder<Map<String, Map<String, List<FamilyMember>>>>(
        future: ageGroupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available.'));
          }

          final ageGroups = snapshot.data!;

          return ListView.builder(
            itemCount: ageGroups.keys.length,
            itemBuilder: (context, index) {
              final ageGroup = ageGroups.keys.elementAt(index);
              final householdMap = ageGroups[ageGroup]!;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: householdMap.isEmpty
                    ? ListTile(
                        title: Text(
                          ageGroup,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("No members found for this age group"),
                      )
                    : ExpansionTile(
                        title: Text(ageGroup),
                        subtitle:
                            Text('Households: ${householdMap.keys.length}'),
                        children: householdMap.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          int householdIndex = entry.key + 1;
                          MapEntry<String, List<FamilyMember>> entryValue =
                              entry.value;
                          String householdNumber = entryValue.key;
                          List<FamilyMember> members = entryValue.value;

                          return ExpansionTile(
                            title: Text(
                              '${householdIndex}. Household Number: $householdNumber',
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
                                  'National ID: ${member.nationalId} | Age: ${member.age}',
                                ),
                              );
                            }).toList(),
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
