import 'package:flutter/material.dart';
import 'package:employee_connect/domain/entities/family_member.dart';

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
              // Display household number and modified date
              Text(
                'Household Number: ${widget.familyMembers[0].householdNumber}',
                style: const TextStyle(
                  fontSize: 24, // Increased size
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Modified on: $formattedDate',
                style: const TextStyle(
                  fontSize: 16, // Increased size
                  color: Colors.black54,
                ),
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
                  'Tuberculosis Aid': member.isTuberculosisAid,
                  'Any Aid': member.isAnyAid,
                }..removeWhere((_, isAid) => !isAid);

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                            fontSize: 20, // Increased size
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (index == 0)
                          _buildProfileRow('Family Head Type', member.familyHeadType),
                        _buildProfileRow('Name', member.name),
                        _buildProfileRow(
                            'National ID',
                            index == 0 || member.age >= 16
                                ? (member.nationalId ?? "N/A")
                                : "Not Applicable"),
                        _buildProfileRow(
                            'Birthday',
                            member.birthday.toLocal().toString().split(' ')[0]),
                        _buildProfileRow('Age', member.age.toString()),
                        _buildProfileRow('Nationality', member.nationality),
                        _buildProfileRow('Religion', member.religion),
                        if (index != 0)
                          _buildProfileRow('Relationship to Head', member.relationshipToHead),
                        if (member.grade != 'None')
                          _buildProfileRow('Grade', member.grade ?? "N/A"),
                        if (member.grade == null || member.grade == 'None') ...[
                          _buildProfileRow('Education Qualification',
                              member.educationQualification ?? "N/A"),
                          _buildProfileRow('Job Type', member.jobType ?? "N/A"),
                        ],
                        if (aidDetails.isNotEmpty) ...[
                          const SizedBox(height: 15),
                          const Text(
                            'Aid Information:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...aidDetails.entries.map((aid) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  '${aid.key}: Yes',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              )),
                        ],
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

  // Function to build a styled row for a profile property
  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16, color: Colors.black87),
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
