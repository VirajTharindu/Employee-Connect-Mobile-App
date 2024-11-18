import 'package:flutter/material.dart';
import 'family_member.dart';
import 'package:intl/intl.dart';

class FamilyProfile extends StatefulWidget {
  final List<FamilyMember> familyMembers;

  const FamilyProfile({Key? key, required this.familyMembers})
      : super(key: key);

  @override
  _FamilyProfileState createState() => _FamilyProfileState();
}

class _FamilyProfileState extends State<FamilyProfile> {
  late String dateOfModified; // Local variable to track the modified date

  @override
  void initState() {
    super.initState();
    dateOfModified = widget.familyMembers[0]
        .dateOfModified; // Initialize with the first member's date
  }

  void updateModifiedDate(String newDate) {
    setState(() {
      dateOfModified = newDate; // Update the state with the new date
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format the date of the family head to a more readable format
    String formattedDate = _formatDate(widget.familyMembers[0].dateOfModified);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Profile of Household ${widget.familyMembers[0].householdNumber}'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display household number only once
              Text(
                'Household Number: ${widget.familyMembers[0].householdNumber}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 5),
              Text(
                'Modified on: $formattedDate',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Map through family members with custom labels
              ...widget.familyMembers.asMap().entries.map((entry) {
                int index = entry.key;
                FamilyMember member = entry.value;

                // Store only aids marked as "Yes" in a map
                final aidDetails = {
                  'Samurdhi Aid': member.isSamurdiAid,
                  'Aswasuma Aid': member.isAswasumaAid,
                  'Wedihiti Aid': member.isWedihitiAid,
                  'Mahajanadara Aid': member.isMahajanadaraAid,
                  'Abhaditha Aid': member.isAbhadithaAid,
                  'Shishshyadara Aid': member.isShishshyadaraAid,
                  'Pilikadara Aid': member.isPilikadaraAid,
                  'Any Aid': member.isAnyAid,
                }..removeWhere((_, isAid) => !isAid);

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          index == 0
                              ? 'Family Head'
                              : 'Member ${index + 1} (${member.relationshipToHead})',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        const SizedBox(height: 10),
                        if (index == 0)
                          Text('Family Head Type: ${member.familyHeadType}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87)),
                        Text('Name: ${member.name}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87)),
                        Text('National ID: ${member.nationalId}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87)),
                        Text(
                            'Birthday: ${member.birthday.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87)),
                        Text('Age: ${member.age}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87)),
                        Text('Nationality: ${member.nationality}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87)),
                        Text('Religion: ${member.religion}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87)),
                        if (index != 0)
                          Text(
                              'Relationship to Head: ${member.relationshipToHead}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87)),
                        if (member.grade != 'None')
                          Text('Grade: ${member.grade ?? "N/A"}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87)),
                        if (member.grade == null || member.grade == 'None') ...[
                          if (index == 0)
                            Text(
                                'Education Qualification: ${member.educationQualification ?? "N/A"}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87)),
                          if (index != 0) ...[
                            Text(
                                'Education Qualification: ${member.educationQualification ?? "N/A"}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87)),
                          ],
                          Text('Job Type: ${member.jobType ?? "N/A"}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87)),
                        ],
                        if (aidDetails.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          const Text('Aid Information:',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                          ...aidDetails.entries.map((aid) => Text(
                              '${aid.key}: Yes',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87))),
                        ],
                        const Divider(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Function to format the date
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return "${parsedDate.day}-${parsedDate.month}-${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute}";
    } catch (e) {
      return "N/A"; // Return "N/A" if the date parsing fails
    }
  }
}
