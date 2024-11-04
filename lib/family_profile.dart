import 'package:flutter/material.dart';
import 'family_member.dart';

class FamilyProfile extends StatelessWidget {
  final List<FamilyMember> familyMembers;

  const FamilyProfile({Key? key, required this.familyMembers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile of Household ${familyMembers[0].householdNumber}'),
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
                'Household Number: ${familyMembers[0].householdNumber}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 20),

              // Map through family members with custom labels
              ...familyMembers.asMap().entries.map((entry) {
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
                        // Use "Family Head" for the first member, "Member 2" and so on for others
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
                        // Display "Family Head Type" first for the family head
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

                        // Conditionally display "Relationship to Head" only for members other than the family head
                        if (index != 0)
                          Text(
                              'Relationship to Head: ${member.relationshipToHead}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87)),

                        // Conditional display of "Grade" field
                        if (member.grade != 'None')
                          Text('Grade: ${member.grade ?? "N/A"}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87)),

                        // Conditional display of "Education Qualification" and "Job Type"
                        if (member.grade == null || member.grade == 'None') ...[
                          // Remove space for the family head
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

                        // Display only aids that are marked as "Yes"
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
}
