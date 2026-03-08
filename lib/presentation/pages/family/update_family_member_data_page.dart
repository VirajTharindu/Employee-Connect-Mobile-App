import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:employee_connect/core/service_locator.dart';
import 'package:employee_connect/domain/entities/family_member.dart';

class UpdateFamilyMemberData extends StatefulWidget {
  final String householdNumber;
  final List<FamilyMember> familyMembers;

  const UpdateFamilyMemberData({
    Key? key,
    required this.householdNumber,
    required this.familyMembers,
  }) : super(key: key);

  @override
  _UpdateFamilyMemberDataState createState() => _UpdateFamilyMemberDataState();
}

class _UpdateFamilyMemberDataState extends State<UpdateFamilyMemberData> {
  final _formKey = GlobalKey<FormState>();
  List<FamilyMember> familyMembers = [];
  List<FamilyMember> initialFamilyMembersBackup = [];
  String familyHouseholdNumber = '';
  bool isSubmitPressed = false;
  int familyMemberCount = 1; // Default to 1 family member (Family Head)

  // Variable to track selected Family Head Type
  String? selectedFamilyHeadType;

  final TextEditingController _memberCountController = TextEditingController();

  String? originalHouseholdNumber; // Store the original household number
  List<String?> originalNationalIds = []; // Store the original national IDs

  @override
  void initState() {
    super.initState();
    familyHouseholdNumber = widget.householdNumber;
    familyMembers =
        List.from(widget.familyMembers); // Initialize with passed data
    initialFamilyMembersBackup =
        List.from(widget.familyMembers); // Backup initial data

    // Initialize selectedFamilyHeadType from the family head data
    selectedFamilyHeadType =
        familyMembers.isNotEmpty ? familyMembers[0].familyHeadType : null;

    familyMemberCount = familyMembers.length;

    _memberCountController.text = familyMemberCount.toString();

    // Initialize original values when the family data is first loaded
    originalHouseholdNumber = familyHouseholdNumber;
    originalNationalIds = familyMembers.map((m) => m.nationalId).toList();
  }

  @override
  void dispose() {
    _memberCountController.dispose();
    super.dispose();
  }

  // Update family member count while preserving initial values
  void _updateFamilyMembersList(int count) {
    setState(() {
      familyMemberCount = count;

      // If count is greater, restore members from backup if available
      if (familyMembers.length < count) {
        for (int i = familyMembers.length; i < count; i++) {
          if (i < initialFamilyMembersBackup.length) {
            // Restore from backup if initial member data exists
            familyMembers.add(initialFamilyMembersBackup[i]);
          } else {
            // Otherwise, add a new blank member
            familyMembers.add(FamilyMember(
                name: '',
                nationalId: '',
                birthday: DateTime(2000, 1, 1),
                age: 0,
                nationality: '',
                religion: '',
                educationQualification: '',
                jobType: '',
                familyHeadType: '',
                relationshipToHead: '',
                householdNumber: '',
                grade: 'None',
                dateOfModified: '' // Add dateOfModified;
                ));
          }
        }
      } else if (familyMembers.length > count) {
        // Trim the list if count is reduced
        familyMembers = familyMembers.sublist(0, count);
      }
    });
  }

  // Show confirmation dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController countController = TextEditingController();
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How many members does your family have?'),
              const SizedBox(height: 10),
              TextFormField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter Number of Members',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final count = int.tryParse(countController.text);
                final currentCount =
                    int.tryParse(_memberCountController.text) ?? 0;

                if (count != null && count > 0) {
                  if (count > currentCount) {
                    setState(() {
                      _memberCountController.text =
                          count.toString(); // Update displayed text
                      _updateFamilyMembersList(
                          count); // Update members list if needed
                    });
                    Navigator.of(context)
                        .pop(); // Dismiss dialog after setting state
                  } else {
                    // Show validation message if the entered number is less than or equal to current count
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter a number greater than the existing family members count',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid number',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a family member based on their national ID
  Future<void> deleteFamilyMemberById(int Id) async {
    try {
      // Delete the family member from the database
      await locator.familyRepository.deleteFamilyMemberById(Id);

      // Remove the family member from the local list
      setState(() {
        familyMembers.removeWhere((member) => member.id == Id);
        familyMemberCount = familyMembers.length; // Update the count
        _memberCountController.text =
            familyMemberCount.toString(); // Update the displayed count
        // After deletion, fetch updated family members
        // Assuming _loadFamilyMembers fetches updated list
      });

      // Update the 'dateOfModified' field for the family (assumes householdNumber)
      await locator.familyRepository
          .updateFamilyDateOfModified(familyHouseholdNumber);

      Navigator.pop(context, {
        'householdNumber': familyHouseholdNumber,
        'familyMembers': familyMembers,
      });

      // Show a message that the family member was deleted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Family member deleted successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(
          "Error deleting family member: $e",
        );
      }
      // Show an error message if the deletion failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              "Failed to delete family member",
            ),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Family Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input field for household number
              TextFormField(
                initialValue: familyHouseholdNumber,
                decoration:
                    const InputDecoration(labelText: 'Household Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a unique household number';
                  }
                  return null;
                },
                onSaved: (value) {
                  familyHouseholdNumber = value!;
                },
              ),

              // Number of Family Members field with confirmation
              TextFormField(
                controller: _memberCountController, // Use the controller here
                decoration: const InputDecoration(
                    labelText: 'Number of Family Members'),
                readOnly: true,
                onTap: _showConfirmationDialog, // Trigger dialog on tap
              ),

              const SizedBox(height: 20),

              // Generate form for each family member
              for (int i = 0; i < familyMembers.length; i++)
                _buildFamilyMemberForm(i),

              const SizedBox(height: 20),

              // Save button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  setState(() {
                    isSubmitPressed = true; // Track submit press for validation
                  });

                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    try {
                      // Check if household number is unique (only if it has changed)
                      if (familyHouseholdNumber != originalHouseholdNumber) {
                        bool isHouseholdUnique = await locator.familyRepository
                            .isHouseholdNumberUnique(familyHouseholdNumber);
                        if (!isHouseholdUnique) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Household number already exists'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return; // Stop execution if household number is not unique
                        }
                      }

                      // Check if all national IDs are unique (only for changed IDs)
                      bool allNationalIdsUnique = true;
                      for (int i = 0; i < familyMembers.length; i++) {
                        var member = familyMembers[i];
                        // Check if this is a new member or an existing member with changed national ID
                        if (i >= originalNationalIds.length ||
                            member.nationalId != originalNationalIds[i]) {
                          bool isNationalIdUnique = await locator.familyRepository
                              .isNationalIdUnique(member.nationalId);
                          if (!isNationalIdUnique) {
                            allNationalIdsUnique = false;
                            break;
                          }
                        }
                      }

                      if (!allNationalIdsUnique) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('One or more National IDs already exist'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Stop execution if any national ID is not unique
                      }

                      // Insert or update family members
                      for (var member in familyMembers) {
                        // Assign the family household number to each member
                        member.householdNumber = familyHouseholdNumber;

                        if (member.id == null) {
                          // If the member does not have an id (it's a new member), insert it into the database
                          await locator.familyRepository.insertFamilyMember(member);
                        } else {
                          // If the member has an id (it's an existing member), update it in the database
                          await locator.familyRepository.updateFamilyMember(member);
                        }
                      }

                      // Show success message and return updated data to FamilyList
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Family details updated!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pop(context, {
                        'householdNumber': familyHouseholdNumber,
                        'familyMembers': familyMembers,
                      });
                    } catch (e) {
                      // Display an error message if there is a failure during the process
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update family details: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.update, size: 24), // Add a save icon
                    SizedBox(width: 8), // Space between icon and text
                    Text('Update'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the form for each family member
  Widget _buildFamilyMemberForm(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          index == 0 ? 'Family Head' : 'Family Member ${index + 1}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        // Family Head Type dropdown for the family head only
        if (index == 0) _buildFamilyHeadTypeDropdown(),

        // Name field
        TextFormField(
          initialValue: familyMembers[index].name,
          decoration: _buildInputDecoration('Name'),
          validator: (value) => value!.isEmpty ? 'Enter name' : null,
          onSaved: (value) => familyMembers[index].name = value!,
        ),
        const SizedBox(height: 15),

        // Birthday picker
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: familyMembers[index].birthday,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                familyMembers[index].birthday = pickedDate;
                familyMembers[index].age =
                    DateTime.now().year - pickedDate.year;
              });
            }
          },
          child: InputDecorator(
            decoration: _buildInputDecoration('Birthday'),
            child: Text(
              "${familyMembers[index].birthday.toLocal()}".split(' ')[0],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        TextFormField(
          initialValue: familyMembers[index].nationalId,
          decoration: _buildInputDecoration('National ID'),
          validator: (value) {
            if (familyMembers[index].age < 17) {
              return null;
            }
            return value!.isEmpty ? 'Enter National ID' : null;
          },
          onSaved: (value) {
            familyMembers[index].nationalId = value ?? '';
          },
        ),
        const SizedBox(height: 15),

        // Nationality dropdown
        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Nationality'),
          initialValue: familyMembers[index].nationality.isNotEmpty
              ? familyMembers[index].nationality
              : null,
          items: ['Sinhala', 'Tamil', 'Muslim', 'Malay', 'Burgher', 'Other']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              familyMembers[index].nationality = value!;
            });
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Select nationality' : null,
          onSaved: (value) => familyMembers[index].nationality = value ?? '',
        ),
        const SizedBox(height: 15),

        // Religion dropdown
        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Religion'),
          initialValue: familyMembers[index].religion.isNotEmpty
              ? familyMembers[index].religion
              : null,
          items: ['Buddhism', 'Hinduism', 'Islam', 'Christianity', 'Other']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              familyMembers[index].religion = value!;
            });
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Select religion' : null,
          onSaved: (value) => familyMembers[index].religion = value ?? '',
        ),
        const SizedBox(height: 15),

        // Education Qualification dropdown
        if (familyMembers[index].grade == 'None') ...[
          DropdownButtonFormField<String>(
            decoration: _buildInputDecoration('Education Qualification'),
            initialValue: familyMembers[index].educationQualification != null &&
                    familyMembers[index].educationQualification!.isNotEmpty
                ? familyMembers[index].educationQualification
                : null,
            items: [
              'Primary (1-5)',
              'Junior Secondary (6-9)',
              'Senior Secondary (10-11)',
              'O/L passed',
              'Collegiate Level (12-13)',
              'A/L passed',
              'Diploma',
              'Degree',
              'Higher Studies',
              'No Schooling'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                familyMembers[index].educationQualification = value!;
              });
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Select education qualification'
                : null,
            onSaved: (value) =>
                familyMembers[index].educationQualification = value ?? '',
          ),
          const SizedBox(height: 15),
          // Job Type dropdown
          DropdownButtonFormField<String>(
            decoration: _buildInputDecoration('Job Type'),
            initialValue: familyMembers[index].jobType != null &&
                    familyMembers[index].jobType!.isNotEmpty
                ? familyMembers[index].jobType
                : null,
            items: [
              'Government',
              'Private',
              'Semi-Government',
              'Corporations',
              'Forces',
              'Police',
              'Self-Employed (Business)',
              'No Job'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                familyMembers[index].jobType = value!;
              });
            },
            validator: (value) =>
                value == null || value.isEmpty ? 'Select job type' : null,
            onSaved: (value) => familyMembers[index].jobType = value ?? '',
          ),
          const SizedBox(height: 15),
        ],

        // Call the grade dropdown here
        if (index != 0) _buildGradeDropdown(familyMembers[index], index),

        if (index != 0) ...[
          _buildRelationshipToHeadField(index),
          const SizedBox(height: 15),
        ],

        _buildAidCheckboxes(index),

        // Delete button for non-family-head members
        if (index != 0) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                deleteFamilyMemberById(familyMembers[index].id ?? 0);
              },
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text("Delete Member"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 15),
        const Divider(thickness: 1.5),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2.0),
      ),
    );
  }

  // Dropdown for family head type
  Widget _buildFamilyHeadTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _buildInputDecoration('Family Head Type'),
      initialValue: selectedFamilyHeadType,
      hint: const Text('Select Family Head Type'),
      items: const [
        DropdownMenuItem(
            value: 'Family Head - Male', child: Text('Family Head - Male')),
        DropdownMenuItem(
            value: 'Family Head - Female', child: Text('Family Head - Female')),
      ],
      onChanged: (value) {
        setState(() {
          selectedFamilyHeadType = value;
          familyMembers[0].familyHeadType = value ?? '';
        });
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Select family head type' : null,
      onSaved: (value) => familyMembers[0].familyHeadType = value ?? '',
    );
  }

  // Builds relationship to Family Head field
  Widget _buildRelationshipToHeadField(int index) {
    return TextFormField(
      initialValue:
          familyMembers[index].relationshipToHead, // Set initial value
      decoration: _buildInputDecoration('Relationship to Family Head'),
      validator: (value) => value!.isEmpty ? 'Enter relationship' : null,
      onSaved: (value) => familyMembers[index].relationshipToHead = value!,
    );
  }

  // Grade dropdown for family members
  Widget _buildGradeDropdown(FamilyMember member, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '* If a student?', // Add the sub-label here
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Grade'),
          initialValue: member.grade,
          items: const [
            DropdownMenuItem(value: 'None', child: Text('None')),
            DropdownMenuItem(value: 'Preschool', child: Text('Preschool')),
            DropdownMenuItem(value: '1', child: Text('1')),
            DropdownMenuItem(value: '2', child: Text('2')),
            DropdownMenuItem(value: '3', child: Text('3')),
            DropdownMenuItem(value: '4', child: Text('4')),
            DropdownMenuItem(value: '5', child: Text('5')),
            DropdownMenuItem(value: '6', child: Text('6')),
            DropdownMenuItem(value: '7', child: Text('7')),
            DropdownMenuItem(value: '8', child: Text('8')),
            DropdownMenuItem(value: '9', child: Text('9')),
            DropdownMenuItem(value: '10', child: Text('10')),
            DropdownMenuItem(value: '11', child: Text('11')),
            DropdownMenuItem(value: '12', child: Text('12')),
            DropdownMenuItem(value: '13', child: Text('13')),
          ],
          onChanged: (value) {
            setState(() {
              member.grade = value;
              // Update the UI to conditionally display the education field
            });
          },
          validator: (value) => value == null ? 'Select a grade' : null,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Builds checkboxes for each type of aid
  Widget _buildAidCheckboxes(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Aid Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        _buildCheckbox('Receiving Samurdi Aid', familyMembers[index].isSamurdiAid, (val) {
          setState(() => familyMembers[index].isSamurdiAid = val!);
        }),
        _buildCheckbox('Receiving Aswasuma Aid', familyMembers[index].isAswasumaAid, (val) {
          setState(() => familyMembers[index].isAswasumaAid = val!);
        }),
        _buildCheckbox('Receiving Adult Aid', familyMembers[index].isWedihitiAid, (val) {
          setState(() => familyMembers[index].isWedihitiAid = val!);
        }),
        _buildCheckbox('Receiving Mahajanadara Aid', familyMembers[index].isMahajanadaraAid, (val) {
          setState(() => familyMembers[index].isMahajanadaraAid = val!);
        }),
        _buildCheckbox('Receiving Disability Aid', familyMembers[index].isAbhadithaAid, (val) {
          setState(() => familyMembers[index].isAbhadithaAid = val!);
        }),
        _buildCheckbox('Receiving Student Aid', familyMembers[index].isShishshyadaraAid, (val) {
          setState(() => familyMembers[index].isShishshyadaraAid = val!);
        }),
        _buildCheckbox('Receiving Cancer Aid', familyMembers[index].isPilikadaraAid, (val) {
          setState(() => familyMembers[index].isPilikadaraAid = val!);
        }),
        _buildCheckbox('Receiving Tuberculosis Aid', familyMembers[index].isTuberculosisAid, (val) {
          setState(() => familyMembers[index].isTuberculosisAid = val!);
        }),
        _buildCheckbox('Receiving Any Aid', familyMembers[index].isAnyAid, (val) {
          setState(() => familyMembers[index].isAnyAid = val!);
        }),
      ],
    );
  }

  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
      activeColor: Colors.green,
    );
  }
}
