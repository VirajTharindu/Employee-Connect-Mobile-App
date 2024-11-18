import 'package:flutter/material.dart';
import 'package:village_officer_app/Update_family_Member_Data.dart';
import 'database_helper.dart';
import 'family_member.dart';
import 'family_profile.dart';
import 'Update_family_Member_Data.dart';

class FamilyList extends StatefulWidget {
  @override
  _FamilyListState createState() => _FamilyListState();
}

class _FamilyListState extends State<FamilyList> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  Future<List<FamilyMember>>? familyMembersFuture;
  List<FamilyMember> familyMembers = [];

  @override
  void initState() {
    super.initState();
    loadFamilyMembers();
  }

  // Method to load family members
  void loadFamilyMembers() {
    familyMembersFuture = databaseHelper.retrieveFamilyMembers();
  }

  // Navigation to FamilyProfile page
  void navigateToFamilyProfile(
      BuildContext context, List<FamilyMember> members) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyProfile(
          familyMembers: members,
        ),
      ),
    );
  }

  // Method to delete a household record and refresh the list
  // Method to delete a household record and refresh the list
  void deleteHousehold(String householdNumber) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete this household record?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await databaseHelper.deleteFamilyByHousehold(householdNumber);

      setState(() {
        loadFamilyMembers();
      });

      // Show a snackbar message after deletion is complete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Household record deleted successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Navigation to UpdateFamilyMemberData page with selected household data
  void navigateToUpdatePage(BuildContext context, String householdNumber,
      List<FamilyMember> members) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateFamilyMemberData(
          householdNumber: householdNumber,
          familyMembers: members,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        final updatedHouseholdNumber = result['householdNumber'];
        final updatedMembers = result['familyMembers'];

        // Remove old entries and add updated members to refresh the list
        familyMembers
            .removeWhere((member) => member.householdNumber == householdNumber);
        familyMembers.addAll(updatedMembers);

        loadFamilyMembers(); // Reload the future to trigger a re-render
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family List'),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: familyMembersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No family list found.'));
          } else {
            Map<String, List<FamilyMember>> groupedByHousehold = {};
            for (var member in snapshot.data!) {
              if (!groupedByHousehold.containsKey(member.householdNumber)) {
                groupedByHousehold[member.householdNumber] = [];
              }
              groupedByHousehold[member.householdNumber]!.add(member);
            }

            List<String> householdNumbers = groupedByHousehold.keys.toList();

            return ListView.builder(
              itemCount: householdNumbers.length,
              itemBuilder: (context, index) {
                final householdNumber = householdNumbers[index];
                final members = groupedByHousehold[householdNumber]!;

                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // Set the desired border radius
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          Colors.grey, // Choose your preferred color
                      child: Text(
                        (index + 1)
                            .toString(), // Display index as the number (1-based index)
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('Household Number: $householdNumber'),
                    subtitle: Text(
                      '${members.length} ${members.length == 1 ? 'Member' : 'Members'}: ${members.map((m) => m.name).join(", ")}',
                    ),
                    onTap: () {
                      navigateToFamilyProfile(context, members);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Update"),
                                content: const Text(
                                    "Are you sure you want to update this family details?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                      navigateToUpdatePage(
                                          context, householdNumber, members);
                                    },
                                    child: const Text("Confirm"),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteHousehold(householdNumber),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
